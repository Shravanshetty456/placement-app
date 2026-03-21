const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

// Debug: Check if env vars are loaded
console.log('DB_HOST loaded:', process.env.DB_HOST ? 'Yes' : 'No');

const app = express();

// Allow all origins for public access
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Serve static files for the PWA quiz app
app.use(express.static('public'));

// Database connection using individual parameters
const db = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT) || 5432,
  database: process.env.DB_DATABASE,
  connectionTimeoutMillis: 10000,
  ssl: {
    rejectUnauthorized: false
  }
});

// Test database connection
db.connect((err) => {
  if (err) {
    console.error('❌ Database connection error:', err);
  } else {
    console.log('✅ Connected to PostgreSQL');
  }
});

// Catch pool errors
db.on('error', (err) => {
  console.error('❌ Unexpected database error:', err);
});

// ============== ADD THESE TWO ENDPOINTS ==============

// Health check endpoint (for Render)
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Test endpoint
app.get('/test', (req, res) => {
  res.json({ 
    message: 'Backend is running on Render!',
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Placement App API',
    endpoints: [
      'POST /signup',
      'POST /signin',
      'GET /profile',
      'GET /todos',
      'POST /todos',
      'PATCH /todos/:id/toggle',
      'DELETE /todos/:id',
      'GET /todos/stats',
      'GET /quiz/questions',
      'POST /quiz/results',
      'GET /quiz/history',
      'GET /quiz/stats',
      'GET /test',
      'GET /health'
    ]
  });
});

// ============== AUTH MIDDLEWARE ==============

const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// ============== AUTH ROUTES ==============

// SIGNUP
app.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields required' });
    }

    const existing = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const hash = await bcrypt.hash(password, 10);
    const newUser = await db.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email',
      [name, email, hash]
    );

    const user = newUser.rows[0];
    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET);

    res.json({ user, token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// SIGNIN
app.post('/signin', async (req, res) => {
  try {
    const { email, password } = req.body;

    const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    const user = result.rows[0];
    
    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET);
    
    res.json({
      user: { id: user.id, name: user.name, email: user.email },
      token
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PROFILE
app.get('/profile', auth, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT id, name, email, created_at FROM users WHERE id = $1',
      [req.user.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============== TODO ROUTES ==============

// GET TODOS
app.get('/todos', auth, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM todos WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CREATE TODO
app.post('/todos', auth, async (req, res) => {
  try {
    const { title, start_hour, start_minute, duration_minutes } = req.body;
    
    const result = await db.query(
      'INSERT INTO todos (user_id, title, start_hour, start_minute, duration_minutes) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.user.id, title, start_hour, start_minute, duration_minutes || 0]
    );
    
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// TOGGLE TODO
app.patch('/todos/:id/toggle', auth, async (req, res) => {
  try {
    // First get current state
    const current = await db.query(
      'SELECT is_completed FROM todos WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.id]
    );

    if (current.rows.length === 0) {
      return res.status(404).json({ error: 'Todo not found' });
    }

    const wasCompleted = current.rows[0].is_completed;
    const newCompletedAt = wasCompleted ? null : new Date().toISOString();

    const result = await db.query(
      `UPDATE todos
       SET is_completed = NOT is_completed, completed_at = $3
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [req.params.id, req.user.id, newCompletedAt]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE TODO
app.delete('/todos/:id', auth, async (req, res) => {
  try {
    await db.query('DELETE FROM todos WHERE id = $1 AND user_id = $2', [req.params.id, req.user.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET TODO STATS
app.get('/todos/stats', auth, async (req, res) => {
  try {
    const userId = req.user.id;

    // Use client's current time if provided, otherwise use server time
    let currentMinutes;
    if (req.query.currentMinutes) {
      currentMinutes = parseInt(req.query.currentMinutes);
    } else {
      const now = new Date();
      currentMinutes = now.getHours() * 60 + now.getMinutes();
    }

    console.log('Stats calculation using currentMinutes:', currentMinutes);

    // Get basic stats with proper separation of pending and missed
    // Using 24-hour format: missed = end time < current time, pending = end time >= current time
    const statsResult = await db.query(`
      SELECT
        COUNT(*) as total_tasks,
        COUNT(CASE WHEN is_completed = true THEN 1 END) as completed_count,
        COUNT(CASE WHEN is_completed = false
                   AND start_hour IS NOT NULL
                   AND start_minute IS NOT NULL
                   AND ((start_hour * 60 + start_minute + COALESCE(duration_minutes, 0)) < $2)
              THEN 1 END) as missed_count,
        COUNT(CASE WHEN is_completed = false
                   AND (start_hour IS NULL
                        OR start_minute IS NULL
                        OR (start_hour * 60 + start_minute + COALESCE(duration_minutes, 0)) >= $2)
              THEN 1 END) as pending_count
      FROM todos WHERE user_id = $1
    `, [userId, currentMinutes]);

    // Get completion dates for streak calculation
    const streakResult = await db.query(`
      SELECT DATE(completed_at) as completion_date
      FROM todos
      WHERE user_id = $1
        AND is_completed = true
        AND completed_at IS NOT NULL
      GROUP BY DATE(completed_at)
      ORDER BY completion_date DESC
    `, [userId]);

    // Calculate current streak
    let currentStreak = 0;
    let checkDate = new Date();
    checkDate.setHours(0, 0, 0, 0);

    const completionDates = streakResult.rows.map(r => {
      const d = new Date(r.completion_date);
      d.setHours(0, 0, 0, 0);
      return d.getTime();
    });

    // Check if today has completions, if not check yesterday
    if (!completionDates.includes(checkDate.getTime())) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    for (let i = 0; i < 365; i++) {
      if (completionDates.includes(checkDate.getTime())) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    // Calculate longest streak
    let longestStreak = 0;
    let tempStreak = 0;
    const sortedDates = [...new Set(completionDates)].sort((a, b) => a - b);

    for (let i = 0; i < sortedDates.length; i++) {
      if (i === 0) {
        tempStreak = 1;
      } else {
        const dayDiff = (sortedDates[i] - sortedDates[i-1]) / (1000 * 60 * 60 * 24);
        if (dayDiff === 1) {
          tempStreak++;
        } else {
          longestStreak = Math.max(longestStreak, tempStreak);
          tempStreak = 1;
        }
      }
    }
    longestStreak = Math.max(longestStreak, tempStreak);

    // Get weekly data for chart
    const weeklyResult = await db.query(`
      SELECT
        DATE(created_at) as date,
        COUNT(CASE WHEN is_completed = true THEN 1 END) as completed,
        COUNT(CASE WHEN is_completed = false THEN 1 END) as pending
      FROM todos
      WHERE user_id = $1
        AND created_at >= CURRENT_DATE - INTERVAL '7 days'
      GROUP BY DATE(created_at)
      ORDER BY date
    `, [userId]);

    res.json({
      total_tasks: parseInt(statsResult.rows[0].total_tasks) || 0,
      completed_count: parseInt(statsResult.rows[0].completed_count) || 0,
      pending_count: parseInt(statsResult.rows[0].pending_count) || 0,
      missed_today: parseInt(statsResult.rows[0].missed_count) || 0,
      current_streak: currentStreak,
      longest_streak: longestStreak,
      weekly_data: weeklyResult.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============== MCQ QUIZ ROUTES ==============

// GET QUIZ QUESTIONS
// Uses Open Trivia Database API - Free CS questions
app.get('/quiz/questions', auth, async (req, res) => {
  try {
    const { amount = 10, difficulty = 'medium' } = req.query;

    // Fetch questions from Open Trivia Database
    // Category 18 = Science: Computers
    const fetch = (await import('node-fetch')).default;
    const response = await fetch(
      `https://opentdb.com/api.php?amount=${amount}&category=18&difficulty=${difficulty}&type=multiple`
    );

    const data = await response.json();

    if (data.response_code !== 0) {
      return res.status(400).json({ error: 'Failed to fetch questions' });
    }

    // Format questions for easier frontend use
    const formattedQuestions = data.results.map((q, index) => ({
      id: index + 1,
      question: q.question,
      correct_answer: q.correct_answer,
      options: [...q.incorrect_answers, q.correct_answer].sort(() => Math.random() - 0.5),
      difficulty: q.difficulty,
      category: q.category
    }));

    res.json({ questions: formattedQuestions });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// SAVE QUIZ RESULT
app.post('/quiz/results', auth, async (req, res) => {
  try {
    const { score, total_questions, time_taken, difficulty } = req.body;

    const result = await db.query(
      'INSERT INTO quiz_results (user_id, score, total_questions, time_taken, difficulty) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.user.id, score, total_questions, time_taken, difficulty]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET QUIZ HISTORY
app.get('/quiz/history', auth, async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM quiz_results WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET QUIZ STATS
app.get('/quiz/stats', auth, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT
        COUNT(*) as total_quizzes,
        AVG(score) as average_score,
        MAX(score) as best_score,
        AVG(time_taken) as average_time
      FROM quiz_results
      WHERE user_id = $1`,
      [req.user.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server running on port ${PORT}`);
  console.log('Endpoints:');
  console.log('  POST   /signup');
  console.log('  POST   /signin');
  console.log('  GET    /profile');
  console.log('  GET    /todos');
  console.log('  POST   /todos');
  console.log('  PATCH  /todos/:id/toggle');
  console.log('  DELETE /todos/:id');
  console.log('  GET    /todos/stats');
  console.log('  GET    /quiz/questions');
  console.log('  POST   /quiz/results');
  console.log('  GET    /quiz/history');
  console.log('  GET    /quiz/stats');
  console.log('  GET    /test');
  console.log('  GET    /health');
  console.log('  GET    /');
});
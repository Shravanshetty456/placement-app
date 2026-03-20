const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// Allow all origins for public access
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Database connection
const connectionString = `postgresql://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_DATABASE}?sslmode=require`;

const db = new Pool({
  connectionString: connectionString,
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
    const result = await db.query(
      'UPDATE todos SET is_completed = NOT is_completed WHERE id = $1 AND user_id = $2 RETURNING *',
      [req.params.id, req.user.id]
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
  console.log('  GET    /test');
  console.log('  GET    /health');
  console.log('  GET    /');
});
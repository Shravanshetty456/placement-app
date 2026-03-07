const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Database connection - simple and direct
const db = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
  ssl: { rejectUnauthorized: false }
});

// Test connection on startup
db.connect((err) => {
  if (err) console.error('DB Connection error:', err);
  else console.log('✅ Connected to PostgreSQL');
});

// Middleware to check token
const auth = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token' });
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// ============== SIMPLE 4 ENDPOINTS ==============

// 1. SIGNUP - Create new user
app.post('/signup', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields required' });
    }

    // Check if user exists
    const existing = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    // Create user
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

// 2. SIGNIN - Login user
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

// 3. GET PROFILE - Get user info
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

// 4. GET TODOS - Get user's todos
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

// 5. CREATE TODO - Add new todo
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

// 6. UPDATE TODO - Toggle complete
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

// 7. DELETE TODO - Remove todo
app.delete('/todos/:id', auth, async (req, res) => {
  try {
    await db.query('DELETE FROM todos WHERE id = $1 AND user_id = $2', [req.params.id, req.user.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(3000, () => {
  console.log('✅ Server running on http://localhost:3000');
  console.log('Endpoints:');
  console.log('  POST   /signup');
  console.log('  POST   /signin');
  console.log('  GET    /profile');
  console.log('  GET    /todos');
  console.log('  POST   /todos');
  console.log('  PATCH  /todos/:id/toggle');
  console.log('  DELETE /todos/:id');
});
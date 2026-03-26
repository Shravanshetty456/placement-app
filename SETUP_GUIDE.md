# Setup Guide: PostgreSQL Authentication

## Step 1: Create PostgreSQL Database

1. Open PostgreSQL command prompt or pgAdmin
2. Run this command:
```sql
psql -U postgres
```

3. Paste the contents from `backend/setup.sql`:
```sql
CREATE DATABASE placement_app;

\c placement_app

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

4. Verify the database and table were created:
```sql
\c placement_app
\dt
```

## Step 2: Install Backend Dependencies

Open terminal/PowerShell in the `backend` folder:
```
cd backend
npm install
```

## Step 3: Start Backend Server

In the `backend` folder:
```
npm start
```

You should see:
```
Database connected successfully
Server is running on port 3000
```

## Step 4: Run Flutter App

In the `apps` folder:
```
flutter pub get
flutter run
```

## How It Works Now

1. **New User Flow:**
   - User goes to signup screen
   - Enters name, email, and password
   - Clicks "Sign Up"
   - Data is sent to backend and saved to PostgreSQL
   - User redirected to login screen

2. **Existing User Flow:**
   - User enters email and password on login screen
   - Backend checks if email exists in database
   - If NOT found: Shows error "User not found. Please sign up first."
   - If found: Compares password with hashed password in database
   - If password matches: Login successful, goes to home page
   - If password wrong: Shows error "Invalid password"

## Security Features

- Passwords are hashed using bcrypt (not stored as plain text)
- Email uniqueness enforced at database level
- Only signed-up users can login
- Password validation before database lookup

## Troubleshooting

**Backend won't connect to database:**
- Check PostgreSQL is running
- Verify credentials in `.env` file (password should be "shravan")
- Check DB_NAME is set to "placement_app"

**Flutter app can't reach backend:**
- Make sure backend server is running on port 3000
- Check baseUrl in `auth_service.dart` matches your backend URL
- On Android emulator, use `10.0.2.2:3000` instead of `localhost:3000`

**Already signed up but can't login:**
- Check that password matches what you signed up with
- Password is case-sensitive

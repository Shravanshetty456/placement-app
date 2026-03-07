@echo off
REM Setup script for PostgreSQL and Backend

echo ========================================
echo Placement App - Database Setup
echo ========================================

echo.
echo Step 1: Creating PostgreSQL Database...
echo.
echo Run this in PowerShell as Administrator:
echo.
echo psql -U postgres -c "CREATE DATABASE placement_app;"
echo.
echo psql -U postgres -d placement_app -f "backend\setup.sql"
echo.

echo Step 2: Installing Backend Dependencies...
cd backend
echo.
echo Running: npm install
npm install

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo To start the backend server, run:
echo   cd backend && npm start
echo.
echo This will start server on localhost:3000
echo.
echo Then in another terminal, start the Flutter app:
echo   cd apps && flutter run
echo.

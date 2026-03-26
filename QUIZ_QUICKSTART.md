# CS Quiz PWA - Quick Start Guide

## 🚀 Getting Started

### 1. Access the App

Your quiz app is now ready! Here are the ways to access it:

#### Local Development
```bash
# If your backend isn't running yet
cd backend
npm install
npm start
```

Then visit: **http://localhost:3000/quiz-app.html**

#### Direct Files
If you want to test just the HTML/JS/CSS:
- Open `backend/public/quiz-app.html` directly in your browser
- The app works completely offline!

### 2. First Quiz
1. Click **"Start Quiz"** on the welcome screen
2. You'll get 10 randomly selected questions
3. Each question has 30 seconds
4. Click an option or press 1-4 on keyboard
5. Press Enter to submit your answer

### 3. View Results
- See your score percentage
- Check individual answers with explanations
- View time taken and accuracy
- Your score automatically saves to leaderboard

### 4. Check Leaderboard & History
- **Leaderboard Button**: Top 5 scores at the top
- **View Leaderboard**: Full top 5 from home
- **Quiz History**: Last 20 attempts with details

---

## ⌨️ Pro Tips

### Keyboard Shortcuts
- **Press 1-4**: Select option 1-4
- **Press Enter**: Submit answer
- **These work on**: Questions & answer selection

### Time Management
- 30 seconds per question
- Timer shows warning colors (10s yellow, 5s red)
- Auto-skips if time runs out
- Total time is tracked in results

### Best Scores
- All scores saved to localStorage
- Top 5 displayed on leaderboard
- Last 50 quizzes in history
- Data persists across browser sessions

---

## 📱 Install as App

### Chrome/Edge (Desktop)
1. Visit the quiz app
2. Look for "Install App" button or browser URL bar icon
3. Click to install
4. App appears on desktop/taskbar

### Mobile (Android Chrome)
1. Visit the quiz app
2. Tap "Install" prompt at bottom
3. Appears on home screen like native app

### iOS (Safari 16.4+)
1. Tap Share icon
2. Select "Add to Home Screen"
3. Name it and tap "Add"

---

## 🔧 Configuration

### Add More Questions
Edit `backend/public/quiz-app.js` around line 1:

```javascript
const QUESTION_BANK = [
    {
        id: 31,
        category: 'Your Topic',
        difficulty: 'easy/medium/hard',
        question: 'Your question here?',
        code: `optional code block`,
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correct: 0, // index of correct answer
        explanation: 'Why this is correct...'
    },
    // Add more...
];
```

### Change Timer
In `quiz-app.js`, find `startTimer()`:
```javascript
this.timeLeft = 30; // Change to desired seconds
```

### Customize Colors
In `quiz-app.html`, find `:root` CSS:
```css
:root {
    --accent: #58a6ff; /* Change blue */
    --correct: #3fb950; /* Change green */
    --error: #f85149; /* Change red */
}
```

---

## 🐛 Troubleshooting

### App Not Loading?
```bash
# Make sure backend is running
cd backend
npm start

# Visit correct URL
http://localhost:3000/quiz-app.html
```

### Service Worker Issues?
1. Open Chrome DevTools (F12)
2. Go to "Application" → "Service Workers"
3. Check if registered and active
4. Click "Unregister" and reload page

### localStorage Full?
```javascript
// Clear all data
localStorage.clear();

// Or specific items
localStorage.removeItem('quizHistory');
localStorage.removeItem('quizLeaderboard');
```

### Questions Not Showing Up?
1. Check browser console for errors (F12)
2. Ensure `quiz-app.js` loads completely
3. Verify QUESTION_BANK array is valid JSON

---

## 📊 Data Structure

### How Data is Saved
All data stored in browser's localStorage:

```javascript
// View quiz history
JSON.parse(localStorage.getItem('quizHistory'))
// Array of: {score, totalQuestions, timeTaken, accuracy, date}

// View leaderboard
JSON.parse(localStorage.getItem('quizLeaderboard'))
// Array of best scores, sorted by score then accuracy
```

### Export Your Data
```javascript
// Copy to clipboard
copy(JSON.stringify(JSON.parse(localStorage.getItem('quizHistory')), null, 2))

// Paste to file for backup
```

---

## 🌍 Offline Mode

### How It Works
1. **First Visit**: Service Worker caches all files
2. **Offline Use**: Files served from cache automatically
3. **Online Match**: Desktop version works without network

### What Works Offline?
✅ Taking quizzes
✅ Viewing results
✅ Leaderboard
✅ Quiz history
✅ All features!

### What Requires Network?
❌ Nothing! App is 100% offline

---

## 🚀 Deployment

### On Render (with Express backend)
Already configured! Just push to GitHub and redeploy.

### Standalone (GitHub Pages)
```bash
# Copy public folder files to gh-pages branch
git checkout -b gh-pages
cp backend/public/* .
git add .
git commit -m "Deploy quiz"
git push origin gh-pages
```

---

## ✨ Features Overview

| Feature | Status |
|---------|--------|
| 60 CSE Questions | ✅ Done |
| Random Selection (10 per quiz) | ✅ Done |
| 30-Sec Timer | ✅ Done |
| Instant Feedback | ✅ Done |
| Leaderboard | ✅ Top 5 |
| Quiz History | ✅ Last 50 |
| Offline Support | ✅ Full PWA |
| Keyboard Shortcuts | ✅ 1-4, Enter |
| Mobile Responsive | ✅ Responsive |
| Dark Theme | ✅ GitHub Style |
| Code Highlighting | ✅ Syntax Ready |
| No Backend Needed | ✅ True |

---

## 📚 Question Topics

**60 total questions covering:**

**Core Fundamentals:**
- **Python** (2) - Lists, built-ins
- **Java** (2) - Strings, modifiers
- **JavaScript** (2) - Types, scope
- **C++** (2) - Vectors, memory
- **Data Structures** (4) - Arrays, lists, trees, graphs
- **Algorithms** (3) - Sorting, searching, DP
- **OS** (3) - Scheduling, memory, deadlock
- **Networks** (3) - OSI, TCP/IP, routing
- **Databases** (3) - SQL, normalization, ACID
- **Software Engineering** (4) - SDLC, Agile, testing, OOP

**Advanced Topics:**
- **Web Development** (3) - HTTP, REST, CSS
- **DevOps** (4) - Containers, CI/CD, Git
- **Security** (2) - Hashing, encryption
- **Machine Learning** (2) - Supervised learning, overfitting
- **Advanced Algorithms** (2) - QuickSort, Greedy
- **Compilers** (2) - Lexing, interpreted vs compiled
- **Architecture** (2) - MVC, Microservices
- **Mobile Dev** (2) - Cross-platform, native vs hybrid
- **Testing** (2) - Levels, coverage
- **SOLID Principles** (2) - SRP, OCP
- **Performance** (1) - Memoization

---

## 🎓 What You'll Learn

After quizzing repeatedly, you'll master:
- Core CS fundamentals
- Algorithm complexities
- Database design
- Network protocols
- System design basics

---

**Ready? Visit the app and start quizzing! 🚀**

For help, check the README.md in `backend/public/`

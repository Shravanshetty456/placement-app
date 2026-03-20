# CS Engineering MCQ Quiz App - Complete PWA Documentation

## 🎯 Overview

A comprehensive, offline-capable Progressive Web App (PWA) for testing Computer Science and Engineering knowledge. Completely works without any backend dependency, using localStorage for persistence.

**Features:**
- ✅ 30 high-quality CSE questions covering 10 topics
- ✅ 10 randomly selected questions per quiz with shuffled answers
- ✅ 30-second countdown timer per question
- ✅ Professional coding-themed dark UI with syntax highlighting
- ✅ Real-time feedback with explanations
- ✅ Progress bar and score tracking
- ✅ Leaderboard showing top 5 scores
- ✅ Quiz history with 50 most recent attempts
- ✅ Keyboard shortcuts (1-4 for options, Enter to submit)
- ✅ Complete offline support (PWA with Service Worker)
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Zero backend required

---

## 📋 Question Bank Coverage

### Topics (60 Questions Total - 2 Sections)

**SECTION 1: Core CSE Fundamentals (Q1-30)**

1. **Python** (2 questions)
   - List mutability and references
   - Built-in functions (len, range, etc.)

2. **Java** (2 questions)
   - String comparison and string pool
   - Access modifiers

3. **JavaScript** (2 questions)
   - Type system and typeof operator
   - Scope (var, let, const) differences

4. **C++** (2 questions)
   - Vector insertion complexity
   - Memory allocation (new vs stack)

5. **Data Structures** (4 questions)
   - Arrays (O(1) access)
   - Linked Lists (O(n) search)
   - Trees (balanced BST height)
   - Graphs (DFS traversal)

6. **Algorithms** (3 questions)
   - Sorting (Merge Sort guarantees O(n log n))
   - Searching (Binary Search O(log n))
   - Dynamic Programming (Fibonacci O(n))

7. **Operating Systems** (3 questions)
   - Process Scheduling (SJF)
   - Memory Management (Thrashing)
   - Deadlock prevention

8. **Computer Networks** (3 questions)
   - OSI Model (Network Layer routing)
   - TCP vs UDP
   - Routing Protocols (OSPF)

9. **Databases** (3 questions)
   - SQL JOINs (INNER vs LEFT)
   - Normalization
   - ACID Properties

10. **Software Engineering** (4 questions)
    - SDLC phases
    - Agile Sprints
    - Unit Testing
    - OOP/Design Patterns

**SECTION 2: Advanced CSE Topics (Q31-60)**

11. **Web Development** (3 questions)
    - HTTP status codes
    - GET vs POST methods
    - CSS specificity

12. **Cloud & DevOps** (2 questions)
    - Containerization (Docker)
    - CI/CD pipelines

13. **Security & Cryptography** (2 questions)
    - Hashing and integrity
    - Symmetric vs Asymmetric encryption

14. **Machine Learning Basics** (2 questions)
    - Supervised learning concepts
    - Overfitting problems

15. **Advanced Algorithms** (2 questions)
    - QuickSort complexity analysis
    - Greedy algorithm strategy

16. **Compiler & Languages** (2 questions)
    - Compiler phases
    - Interpreted vs Compiled languages

17. **Software Architecture** (2 questions)
    - MVC pattern
    - Monolithic vs Microservices

18. **API & REST** (2 questions)
    - REST definition and principles
    - HTTP success status codes

19. **Network Protocols** (2 questions)
    - HTTP vs HTTPS
    - DNS system

20. **Database Advanced** (2 questions)
    - Database indexing
    - Transaction concepts

21. **Git & Version Control** (2 questions)
    - Version control purpose
    - Merge vs Rebase

22. **Mobile Development** (2 questions)
    - Cross-platform development
    - Native vs Hybrid apps

23. **Testing** (2 questions)
    - Testing levels/pyramid
    - Code coverage

24. **Design Principles** (2 questions)
    - Single Responsibility Principle
    - Open/Closed Principle

25. **Performance & Optimization** (1 question)
    - Memoization technique

---

## 🚀 Quick Start

### Local Development
```bash
cd backend
npm install
npm start
```

Then visit: `http://localhost:3000/quiz-app.html`

### Deployment

#### Option 1: Render (Recommended)
Already configured in the Node.js Express backend.

#### Option 2: Vercel (Static Hosting)
```bash
# Copy public folder to your Vercel project
# Deploy directly
vercel deploy
```

#### Option 3: GitHub Pages
```bash
# Create gh-pages branch
git checkout -b gh-pages
# Copy public folder contents to root
git add .
git commit -m "Deploy quiz app"
git push origin gh-pages
```

#### Option 4: Docker
The Express server automatically serves the public folder with the quiz app.

---

## 💾 Data Storage

### localStorage Keys
```javascript
// Quiz history (last 50 quizzes)
localStorage.getItem('quizHistory')

// Leaderboard (top 100 scores)
localStorage.getItem('quizLeaderboard')
```

### Data Structure
```javascript
// History Entry
{
  score: 8,
  totalQuestions: 10,
  timeTaken: 145,
  accuracy: 80,
  categories: "Python, Java, JavaScript",
  date: "3/20/2026"
}

// Leaderboard Entry
{
  score: 10,
  totalQuestions: 10,
  timeTaken: 120,
  accuracy: 100,
  date: "3/20/2026"
}
```

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **1-4** | Select option 1-4 |
| **Enter** | Submit answer |
| **Esc** | Cancel operation |

---

## 🎨 UI Features

### Themes
- Dark Mode (GitHub-inspired color scheme)
- Accent Colors: Blue (#58a6ff)
- Text: Light gray (#c9d1d9)

### Components
- **Header**: Logo, app title, leaderboard toggle
- **Timer**: 30-second countdown with visual warnings
- **Progress Bar**: Question progress visualization
- **Question Card**: Question text + code blocks + options
- **Feedback**: Instant correct/incorrect feedback with explanations
- **Leaderboard**: Top 5 scores with timestamps
- **History**: Last 20 quiz attempts

---

## 📱 PWA Installation

### Browser Support
- ✅ Chrome/Edge (Android & Desktop)
- ✅ Safari (iOS 16.4+)
- ✅ Firefox (Mobile)
- ⚠️ Opera (Limited support)

### Install Steps

**Desktop (Chrome/Edge):**
1. Visit the app URL
2. Click "Install App" button (or address bar icon)
3. Confirm installation
4. App appears on desktop/start menu

**Mobile (Android):**
1. Open in Chrome/Edge
2. Tap "Install" prompt at bottom
3. Tap "Install" to confirm
4. App appears on home screen

**iOS (Safari 16.4+):**
1. Open in Safari
2. Tap Share → Add to Home Screen
3. Name the app
4. Tap Add

---

## 🔒 Security & Privacy

- ✅ No server-side data collection
- ✅ All data stored locally in browser
- ✅ No account required
- ✅ No tracking or analytics
- ✅ Fully open-source
- ✅ No external API calls

---

## 🛠️ Technical Stack

### Frontend
- **HTML5** - Semantic markup
- **CSS3** - Flexbox, Grid, animations
- **Vanilla JavaScript** - No dependencies
- **Service Worker** - Offline support
- **Web App Manifest** - PWA configuration

### Backend
- **Node.js + Express** - Static file serving
- **No database required** - Completely offline

### Browser APIs Used
- localStorage - Data persistence
- Service Workers - Offline caching
- Web App Manifest - PWA configuration
- IndexedDB - (Optional for future expansion)

---

## 📊 Quiz Flow

```
┌─────────────────┐
│  Welcome Screen │ ← Start, View Leaderboard, History
└────────┬────────┘
         ↓
┌─────────────────┐
│  Random Select  │ ← Pick 10 from 30 questions
│  & Shuffle      │ ← Shuffle answer options
└────────┬────────┘
         ↓
┌─────────────────────────────────────┐
│  Quiz Screen                        │
│  ├─ Progress Bar                    │
│  ├─ 30-Sec Timer (Auto-skip)        │
│  ├─ Question + Code                 │
│  ├─ 4 Shuffled Options              │
│  ├─ Instant Feedback                │
│  └─ Submit/Next                     │
└────────┬────────────────────────────┘
         ↓
  (Repeat 10 times)
         ↓
┌─────────────────┐
│  Results Screen │ ← Score, Accuracy, Time
└────────┬────────┘
         ↓
┌─────────────────┐
│  Save History & │ ← localStorage
│  Update Leader  │ ← Sort & Keep Top 5
└────────┬────────┘
         ↓
┌─────────────────┐
│  Welcome Screen │ ← Updated stats
└─────────────────┘
```

---

## 🐛 Troubleshooting

### Service Worker Not Registering
- Clear browser cache and site data
- Check browser console for errors
- Ensure serving over HTTPS (or localhost for dev)

### localStorage Quota Exceeded
- Clear quiz history: `localStorage.removeItem('quizHistory')`
- Clear leaderboard: `localStorage.removeItem('quizLeaderboard')`

### Offline Mode Not Working
- Ensure service worker is registered
- Check "Application" tab in DevTools
- Manually reload the page

### Timer Issues
- Refresh the page
- Check system clock accuracy
- Ensure JavaScript is not blocked

---

## 📈 Future Enhancements

- [ ] Multiple difficulty levels
- [ ] Subcategory filtering
- [ ] Detailed performance analytics
- [ ] Multiplayer quiz battles
- [ ] Cloud sync (optional backend)
- [ ] Spaced repetition for weak areas
- [ ] Dark/Light theme toggle
- [ ] Question explanations with video links
- [ ] Mobile app (React Native)
- [ ] Offline question bank updates

---

## 📝 Files Structure

```
backend/public/
├── quiz-app.html          # Main HTML (1 file)
├── quiz-app.js            # App logic + 30 questions
├── sw.js                  # Service Worker
├── manifest.json          # PWA configuration
└── README.md              # This file
```

---

## 🎓 Learning Outcomes

After completing multiple quizzes, users will understand:
- Python data structures and language features
- Java OOP and memory management
- JavaScript quirks and async concepts
- C++ memory and performance
- Data structures complexity analysis
- Classic algorithms (sorting, searching, DP)
- Operating system concepts
- Network protocols and architecture
- Database design and SQL
- Software engineering best practices

---

## 📄 License

This project is open-source and free to use for educational purposes.

---

## 👨‍💻 Contributing

To add more questions or features:
1. Edit `quiz-app.js` QUESTION_BANK array
2. Follow the same question format
3. Test thoroughly
4. Submit a pull request

---

## 📞 Support

For issues or suggestions:
1. Check the Troubleshooting section
2. Look at browser console for errors
3. Clear cache and try again
4. Open an issue on GitHub

---

**Happy Quizzing! 🚀**

Last Updated: March 20, 2026
Version: 1.0.0

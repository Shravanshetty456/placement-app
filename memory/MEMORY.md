# Placement App - Flutter Project Memory

## Project Overview
Building a comprehensive placement preparation mobile app with Flutter:
- **Home Screen**: 3 sections - Todos, MCQ Quiz, Profile
- **MCQ System**: API-driven with Open Trivia Database + local fallback
- **Features**: Quiz configuration, timer, scoring, results analytics
- **Offline Support**: Question caching, fallback to local questions
- **Dark Mode**: Full theme support

## Key Files
- `apps/lib/models/question.dart` - Question model with API/JSON parsing
- `apps/lib/services/question_service.dart` - API client with caching & fallback
- `apps/lib/services/fallback_questions.dart` - 76+ local CSE questions backup
- `apps/lib/screens/feature3/mcq_screen.dart` - Complete quiz UI implementation
- `apps/lib/screens/home.dart` - 3-section navigation (Todo, MCQ, Profile)

## Architecture Decisions
1. **API-First Approach**: Fetch from Open Trivia Database, fallback to local questions
2. **Service Pattern**: QuestionService handles all API/cache operations
3. **SharedPreferences**: Lightweight caching (24-hour expiry)
4. **HTML Entity Decoding**: Handles &quot;, &amp;, etc. from API responses
5. **Global Timer**: Per-quiz countdown with auto-end on timeout
6. **Category Filtering**: Using question keywords to categorize fallback questions
7. **Graceful Degradation**: Full offline capability with local questions
8. **Provider Pattern**: Theme management for dark/light mode

## Question Bank Coverage (76 Local Questions + API)
**Topics Covered:**
- Programming Languages: Python, Java, C++, JavaScript, Dart (8 questions)
- Data Structures: Arrays, Linked Lists, Trees, Graphs, Hash Tables (10 questions)
- Algorithms: Sorting, Searching, Dynamic Programming, Recursion, Greedy (8 questions)
- Operating Systems: Process Management, Memory Management, File Systems (3+ questions)
- Computer Networks: OSI Model, TCP/IP, Routing, Protocols (8 questions)
- Databases: SQL, Normalization, Transactions, Transactions (7 questions)
- Software Engineering: SDLC, Agile, Testing, Design Patterns (5 questions)
- Web Development: HTML, CSS, JavaScript, DOM, API (5 questions)
- Cloud Computing: Docker, AWS, Kubernetes (3 questions)

**API Source**: Open Trivia Database (https://opentdb.com/api.php)
- Category: Science: Computers (ID: 18)
- Type: Multiple choice
- Difficulty: Configurable (easy/medium/hard/any)

## Features Implemented
✅ API-driven questions (Open Trivia Database)
✅ Fallback to 76+ local cached questions
✅ Category selection (Science: Computers, Math, General Knowledge)
✅ Difficulty filtering (Easy, Medium, Hard, Any)
✅ User-configurable question count & duration
✅ Global countdown timer with visual warnings
✅ Real-time progress tracking
✅ Instant feedback with correct/incorrect indication
✅ Explanation display for answers
✅ Score calculation with accuracy percentage
✅ Time tracking (minutes:seconds format)
✅ Offline support via SharedPreferences caching (24-hour expiry)
✅ Loading states with spinner
✅ Error handling with retry functionality
✅ Dark mode support
✅ Responsive UI for mobile/tablet
✅ HTML entity decoding (from API responses)

## Deployment & Setup
1. **Dependencies**: Run `flutter pub get` in `apps/` directory
2. **Required Packages**:
   - `http: ^1.1.0` - For API calls
   - `shared_preferences: ^2.2.2` - For caching
   - `provider: ^6.1.1` - For theme management
3. **API Configuration**: Uses Open Trivia Database (free, no key needed)
4. **Caching**: Automatic 24-hour caching via SharedPreferences
5. **Fallback**: Automatic activation when API unavailable

## Testing Checklist
- [ ] API fetch from Open Trivia Database works
- [ ] Fallback to local questions works when API fails
- [ ] Category selection filters questions correctly
- [ ] Difficulty selection works properly
- [ ] Timer counts down and auto-ends quiz
- [ ] Score calculation is accurate
- [ ] Offline mode uses cached questions
- [ ] Error screen appears with retry button
- [ ] Loading screen shows while fetching
- [ ] Dark mode toggle works
- [ ] Results screen displays accuracy %
- [ ] Retry quiz functionality works
- [ ] HTML entities in questions decode correctly
- [ ] Cancel quiz button works

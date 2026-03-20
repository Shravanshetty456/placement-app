// ========== COMPREHENSIVE CSE QUESTION BANK ==========
const QUESTION_BANK = [
    // Python
    {
        id: 1,
        category: 'Python',
        difficulty: 'medium',
        question: 'What will be the output of this Python code?',
        code: `x = [1, 2, 3]
y = x
y.append(4)
print(x)`,
        options: [
            '[1, 2, 3]',
            '[1, 2, 3, 4]',
            'Error: cannot append to x',
            'None'
        ],
        correct: 1,
        explanation: 'Lists in Python are mutable and passed by reference. y = x creates a reference to the same list, not a copy. Appending to y also appends to x.'
    },
    {
        id: 2,
        category: 'Python',
        difficulty: 'medium',
        question: 'Which Python function is used to find the length of an object?',
        options: [
            'length()',
            'size()',
            'len()',
            'count()'
        ],
        correct: 2,
        explanation: 'Python uses the len() built-in function to find the length of strings, lists, tuples, and other sequences.'
    },
    // Java
    {
        id: 3,
        category: 'Java',
        difficulty: 'medium',
        question: 'What is the output of the following Java code?',
        code: `String s1 = "Hello";
String s2 = "Hello";
System.out.println(s1 == s2);`,
        options: [
            'true',
            'false',
            'Error: Cannot compare strings with ==',
            'null'
        ],
        correct: 0,
        explanation: 'String literals in Java are stored in the string pool. Both s1 and s2 refer to the same object in the pool. Using == compares object references, which are the same.'
    },
    {
        id: 4,
        category: 'Java',
        difficulty: 'hard',
        question: 'Which of the following is NOT a valid access modifier in Java?',
        options: [
            'public',
            'private',
            'protected',
            'global'
        ],
        correct: 3,
        explanation: 'Java has four access modifiers: public, private, protected, and default (package-private). "global" is not a Java access modifier.'
    },
    // JavaScript
    {
        id: 5,
        category: 'JavaScript',
        difficulty: 'medium',
        question: 'What will this JavaScript code output?',
        code: `console.log(typeof undefined);
console.log(typeof null);`,
        options: [
            '"undefined", "null"',
            '"undefined", "object"',
            '"object", "object"',
            'Error'
        ],
        correct: 1,
        explanation: 'typeof undefined returns "undefined". typeof null returns "object" (this is a quirk in JavaScript). null is not an object, but a primitive value.'
    },
    {
        id: 6,
        category: 'JavaScript',
        difficulty: 'hard',
        question: 'What is the difference between "var", "let", and "const" in JavaScript?',
        options: [
            'No difference, all are interchangeable',
            'var is function-scoped, let/const are block-scoped; const cannot be reassigned',
            'Only const is valid in modern JavaScript',
            'var and const are the same, let is different'
        ],
        correct: 1,
        explanation: 'var is function-scoped and hoisted. let and const are block-scoped. const cannot be reassigned, but its properties can be modified if it\'s an object.'
    },
    // C++
    {
        id: 7,
        category: 'C++',
        difficulty: 'medium',
        question: 'What is the time complexity of inserting an element at the beginning of a vector in C++?',
        options: [
            'O(1)',
            'O(n)',
            'O(log n)',
            'O(n log n)'
        ],
        correct: 1,
        explanation: 'Inserting at the beginning of a vector requires shifting all existing elements, which takes O(n) time.'
    },
    {
        id: 8,
        category: 'C++',
        difficulty: 'hard',
        question: 'What is the difference between "new" and "stack allocation" in C++?',
        options: [
            'No difference',
            'new allocates on heap and returns a pointer; stack allocation is automatic and deallocated at scope end',
            'Stack allocation is faster but limited to primitives',
            'new is only for objects, stack allocation is for primitives'
        ],
        correct: 1,
        explanation: 'new allocates memory on the heap (manual deallocation required), while stack allocation is automatic and follows RAII principles.'
    },
    // Data Structures - Arrays
    {
        id: 9,
        category: 'Data Structures',
        difficulty: 'easy',
        question: 'What is the time complexity of accessing an element by index in an array?',
        options: [
            'O(n)',
            'O(log n)',
            'O(1)',
            'O(n log n)'
        ],
        correct: 2,
        explanation: 'Arrays provide random access by index with O(1) time complexity due to direct memory addressing.'
    },
    // Data Structures - Linked Lists
    {
        id: 10,
        category: 'Data Structures',
        difficulty: 'medium',
        question: 'What is the time complexity of searching for an element in a singly linked list?',
        options: [
            'O(1)',
            'O(log n)',
            'O(n)',
            'O(n²)'
        ],
        correct: 2,
        explanation: 'Without indices, searching in a linked list requires traversing from the head, resulting in O(n) time complexity in the worst case.'
    },
    // Data Structures - Trees
    {
        id: 11,
        category: 'Data Structures',
        difficulty: 'medium',
        question: 'In a balanced binary search tree, what is the height for n nodes?',
        options: [
            'O(1)',
            'O(log n)',
            'O(n)',
            'O(n²)'
        ],
        correct: 1,
        explanation: 'A balanced BST maintains a height of O(log n) for n nodes, ensuring efficient operations.'
    },
    // Data Structures - Graphs
    {
        id: 12,
        category: 'Data Structures',
        difficulty: 'hard',
        question: 'What is the time complexity of DFS (Depth-First Search) traversal?',
        options: [
            'O(1)',
            'O(log V)',
            'O(V + E)',
            'O(V * E)'
        ],
        correct: 2,
        explanation: 'DFS visits each vertex once (V) and each edge once (E), resulting in O(V + E) time complexity.'
    },
    // Algorithms - Sorting
    {
        id: 13,
        category: 'Algorithms',
        difficulty: 'medium',
        question: 'Which sorting algorithm has O(n log n) time complexity in all cases?',
        options: [
            'Quick Sort',
            'Bubble Sort',
            'Merge Sort',
            'Selection Sort'
        ],
        correct: 2,
        explanation: 'Merge Sort guarantees O(n log n) time complexity in best, average, and worst cases due to its divide-and-conquer approach.'
    },
    // Algorithms - Searching
    {
        id: 14,
        category: 'Algorithms',
        difficulty: 'easy',
        question: 'What is the time complexity of binary search?',
        options: [
            'O(1)',
            'O(n)',
            'O(log n)',
            'O(n²)'
        ],
        correct: 2,
        explanation: 'Binary search eliminates half of the remaining elements with each comparison, resulting in O(log n) time complexity.'
    },
    // Algorithms - Dynamic Programming
    {
        id: 15,
        category: 'Algorithms',
        difficulty: 'hard',
        question: 'What is the time complexity of solving the Fibonacci sequence using dynamic programming?',
        options: [
            'O(1)',
            'O(n)',
            'O(n²)',
            'O(2ⁿ)'
        ],
        correct: 1,
        explanation: 'Dynamic programming solves each subproblem once and stores results, reducing Fibonacci complexity from O(2ⁿ) to O(n).'
    },
    // Operating Systems - Process Scheduling
    {
        id: 16,
        category: 'Operating Systems',
        difficulty: 'medium',
        question: 'Which scheduling algorithm minimizes average waiting time?',
        options: [
            'FCFS (First Come First Served)',
            'SJF (Shortest Job First)',
            'Round Robin',
            'Priority Scheduling'
        ],
        correct: 1,
        explanation: 'SJF (Shortest Job First) schedules processes with shorter burst times first, minimizing average waiting time.'
    },
    // Operating Systems - Memory Management
    {
        id: 17,
        category: 'Operating Systems',
        difficulty: 'hard',
        question: 'What is thrashing in virtual memory?',
        options: [
            'Excessive page faults causing process slowdown',
            'Memory fragmentation',
            'CPU caching issues',
            'Disk I/O bottleneck'
        ],
        correct: 0,
        explanation: 'Thrashing occurs when a process spends more time swapping pages in/out than doing actual work due to insufficient memory.'
    },
    // Operating Systems - Deadlock
    {
        id: 18,
        category: 'Operating Systems',
        difficulty: 'hard',
        question: 'Which of the following is NOT a necessary condition for deadlock?',
        options: [
            'Mutual Exclusion',
            'Hold and Wait',
            'Circular Wait',
            'Preemption'
        ],
        correct: 3,
        explanation: 'Deadlock requires four conditions: Mutual Exclusion, Hold and Wait, No Preemption, and Circular Wait. Preemption can actually prevent deadlock.'
    },
    // Computer Networks - OSI Model
    {
        id: 19,
        category: 'Computer Networks',
        difficulty: 'medium',
        question: 'Which layer of the OSI model handles routing?',
        options: [
            'Data Link Layer (Layer 2)',
            'Network Layer (Layer 3)',
            'Transport Layer (Layer 4)',
            'Application Layer (Layer 7)'
        ],
        correct: 1,
        explanation: 'The Network Layer (Layer 3) is responsible for routing packets from source to destination using IP addresses.'
    },
    // Computer Networks - TCP/IP
    {
        id: 20,
        category: 'Computer Networks',
        difficulty: 'medium',
        question: 'What is the main difference between TCP and UDP?',
        options: [
            'TCP is faster',
            'UDP guarantees delivery order',
            'TCP is connection-oriented and reliable; UDP is connectionless',
            'No difference, just different names'
        ],
        correct: 2,
        explanation: 'TCP (Transmission Control Protocol) establishes a connection and guarantees reliable, ordered delivery. UDP (User Datagram Protocol) is connectionless and unreliable.'
    },
    // Computer Networks - Routing Protocols
    {
        id: 21,
        category: 'Computer Networks',
        difficulty: 'hard',
        question: 'Which routing protocol uses link-state algorithm?',
        options: [
            'RIP (Routing Information Protocol)',
            'OSPF (Open Shortest Path First)',
            'BGP (Border Gateway Protocol)',
            'Both A and B'
        ],
        correct: 1,
        explanation: 'OSPF uses link-state algorithm where routers know the complete network topology. RIP uses distance-vector algorithm.'
    },
    // Databases - SQL
    {
        id: 22,
        category: 'Databases',
        difficulty: 'medium',
        question: 'What is the difference between INNER JOIN and LEFT JOIN?',
        options: [
            'No difference',
            'INNER JOIN returns only matching rows; LEFT JOIN includes all rows from the left table',
            'LEFT JOIN is faster',
            'INNER JOIN uses more memory'
        ],
        correct: 1,
        explanation: 'INNER JOIN returns rows where there is a match in both tables. LEFT JOIN returns all rows from the left table and matching rows from the right.'
    },
    // Databases - Normalization
    {
        id: 23,
        category: 'Databases',
        difficulty: 'hard',
        question: 'What is the primary purpose of database normalization?',
        options: [
            'Increase database speed',
            'Reduce data redundancy and improve data integrity',
            'Simplify SQL queries',
            'Reduce memory usage'
        ],
        correct: 1,
        explanation: 'Normalization removes redundant data, prevents inconsistencies, and maintains data integrity through systematic decomposition.'
    },
    // Databases - Transactions
    {
        id: 24,
        category: 'Databases',
        difficulty: 'medium',
        question: 'What do ACID properties guarantee in a transaction?',
        options: [
            'Atomicity, Consistency, Integrity, Durability',
            'Atomicity, Consistency, Isolation, Durability',
            'Accuracy, Consistency, Isolation, Data integrity',
            'Advanced, Consistent, Isolated, Durable'
        ],
        correct: 1,
        explanation: 'ACID: Atomicity (all-or-nothing), Consistency (valid state), Isolation (independent transactions), Durability (persistent).'
    },
    // Software Engineering - SDLC
    {
        id: 25,
        category: 'Software Engineering',
        difficulty: 'medium',
        question: 'Which phase of SDLC involves gathering and analyzing user requirements?',
        options: [
            'Design Phase',
            'Requirements Phase',
            'Implementation Phase',
            'Testing Phase'
        ],
        correct: 1,
        explanation: 'The Requirements Phase (Requirements Analysis and Planning) involves gathering user needs, defining specifications, and feasibility analysis.'
    },
    // Software Engineering - Agile
    {
        id: 26,
        category: 'Software Engineering',
        difficulty: 'easy',
        question: 'What is a "Sprint" in Agile methodology?',
        options: [
            'A fast run before development',
            'A time-boxed iteration (typically 1-4 weeks) where the team works on specific tasks',
            'A meeting with stakeholders',
            'A testing phase'
        ],
        correct: 1,
        explanation: 'A Sprint is a fixed time-box (usually 1-4 weeks) during which the team completes a set of tasks and delivers a potentially shippable product increment.'
    },
    // Software Engineering - Testing
    {
        id: 27,
        category: 'Software Engineering',
        difficulty: 'medium',
        question: 'What is the purpose of unit testing?',
        options: [
            'Test the entire application',
            'Test individual components or functions in isolation',
            'Test user interface only',
            'Test database performance'
        ],
        correct: 1,
        explanation: 'Unit testing verifies that individual functions, methods, or classes work correctly in isolation, catching bugs early in development.'
    },
    // Advanced: Complexity Analysis
    {
        id: 28,
        category: 'Algorithms',
        difficulty: 'hard',
        question: 'What is the space complexity of a recursive function that makes n recursive calls?',
        options: [
            'O(1)',
            'O(n)',
            'O(log n)',
            'O(n²)'
        ],
        correct: 1,
        explanation: 'Recursive calls use the call stack. With n recursive calls, the call stack depth is O(n), resulting in O(n) space complexity.'
    },
    // Advanced: Object-Oriented Programming
    {
        id: 29,
        category: 'Software Engineering',
        difficulty: 'hard',
        question: 'What is the Liskov Substitution Principle (LSP) in OOP?',
        options: [
            'Objects should be substitutable with instances of their supertype',
            'All objects should have a lisp() method',
            'List objects are more important than substitution',
            'No inheritance is allowed'
        ],
        correct: 0,
        explanation: 'LSP states that derived classes should be substitutable for base classes without breaking code. Objects of a superclass should be replaceable with objects of its subclasses.'
    },
    // Advanced: Design Patterns
    {
        id: 30,
        category: 'Software Engineering',
        difficulty: 'hard',
        question: 'Which design pattern restricts the instantiation of a class to a single object?',
        options: [
            'Factory Pattern',
            'Singleton Pattern',
            'Observer Pattern',
            'Strategy Pattern'
        ],
        correct: 1,
        explanation: 'Singleton Pattern ensures a class has only one instance and provides a global point of access to it.'
    },
    // ========== SECTION 2: ADVANCED CSE QUESTIONS (31-60) ==========
    // Web Development & Frontend
    {
        id: 31,
        category: 'Web Development',
        difficulty: 'easy',
        question: 'What does HTTP status code 404 indicate?',
        options: [
            'Server error',
            'Resource not found',
            'Unauthorized access',
            'Bad request'
        ],
        correct: 1,
        explanation: '404 Not Found indicates that the requested resource does not exist on the server.'
    },
    {
        id: 32,
        category: 'Web Development',
        difficulty: 'medium',
        question: 'What is the main difference between GET and POST HTTP methods?',
        options: [
            'GET is faster than POST',
            'GET retrieves data with URL parameters; POST sends data in request body',
            'POST is always more secure',
            'GET can only be used for reading data'
        ],
        correct: 1,
        explanation: 'GET appends parameters to URL (not secure for sensitive data), while POST sends data in the request body.'
    },
    {
        id: 33,
        category: 'Web Development',
        difficulty: 'medium',
        question: 'What is CSS specificity?',
        options: [
            'The speed of CSS parsing',
            'The order in which CSS rules apply based on selector type',
            'The size of CSS file',
            'The number of CSS classes used'
        ],
        correct: 1,
        explanation: 'Specificity determines which CSS rule applies when multiple rules target the same element. Inline > ID > Class > Type.'
    },
    // Cloud & DevOps
    {
        id: 34,
        category: 'DevOps',
        difficulty: 'medium',
        question: 'What is containerization in DevOps?',
        options: [
            'Storing data in containers',
            'Packaging applications with dependencies into isolated containers',
            'Managing multiple servers',
            'Cloud storage solution'
        ],
        correct: 1,
        explanation: 'Containerization (Docker) packages an app with all dependencies for consistent deployment across environments.'
    },
    {
        id: 35,
        category: 'DevOps',
        difficulty: 'medium',
        question: 'What is CI/CD in software development?',
        options: [
            'Continuous Input/Continuous Distribution',
            'Continuous Integration/Continuous Deployment - automated testing and deployment',
            'Code Inspection/Code Development',
            'Client Interface/Client Data'
        ],
        correct: 1,
        explanation: 'CI/CD automates building, testing, and deploying code changes, reducing manual errors and deployment time.'
    },
    // Security & Cryptography
    {
        id: 36,
        category: 'Security',
        difficulty: 'medium',
        question: 'What is the main purpose of hashing?',
        options: [
            'Encrypt sensitive data',
            'One-way function for data integrity; cannot be decrypted',
            'Speed up database queries',
            'Compress data'
        ],
        correct: 1,
        explanation: 'Hashing creates a fixed-size digest from input data. Same input always produces same hash, but you cannot reverse it.'
    },
    {
        id: 37,
        category: 'Security',
        difficulty: 'hard',
        question: 'What is the difference between symmetric and asymmetric encryption?',
        options: [
            'No difference',
            'Symmetric uses one key; Asymmetric uses public-private key pair',
            'Asymmetric is always faster',
            'Symmetric is more secure'
        ],
        correct: 1,
        explanation: 'Symmetric: same key for encrypt/decrypt (AES). Asymmetric: different keys - public to encrypt, private to decrypt (RSA).'
    },
    // Machine Learning Basics
    {
        id: 38,
        category: 'Machine Learning',
        difficulty: 'easy',
        question: 'What is supervised learning?',
        options: [
            'Learning under human guidance',
            'Learning from labeled data to predict outputs',
            'Learning from unlabeled data',
            'Manual data processing'
        ],
        correct: 1,
        explanation: 'Supervised learning uses labeled training data (input-output pairs) to build predictive models.'
    },
    {
        id: 39,
        category: 'Machine Learning',
        difficulty: 'medium',
        question: 'What does overfitting mean in machine learning?',
        options: [
            'Model learns too much unnecessary detail and performs poorly on new data',
            'Model does not learn training data',
            'Too many features in the model',
            'Using too much training data'
        ],
        correct: 0,
        explanation: 'Overfitting occurs when a model learns training data too well, including noise, causing poor generalization on new data.'
    },
    // Advanced Algorithms
    {
        id: 40,
        category: 'Algorithms',
        difficulty: 'hard',
        question: 'What is the time complexity of QuickSort in the worst case?',
        options: [
            'O(n log n)',
            'O(n)',
            'O(n²)',
            'O(2ⁿ)'
        ],
        correct: 2,
        explanation: 'QuickSort worst case is O(n²) when pivot selection is poor. On average, it is O(n log n).'
    },
    {
        id: 41,
        category: 'Algorithms',
        difficulty: 'hard',
        question: 'What is a greedy algorithm?',
        options: [
            'Algorithm that uses recursion',
            'Makes locally optimal choices at each step',
            'Always finds global optimum',
            'Uses dynamic programming'
        ],
        correct: 1,
        explanation: 'Greedy algorithms make locally optimal choices hoping to find global optimum. Works for some problems (Dijkstra, Huffman) but not all.'
    },
    // Compiler & Languages
    {
        id: 42,
        category: 'Languages',
        difficulty: 'medium',
        question: 'What are the main phases of a compiler?',
        options: [
            'Compiling and executing',
            'Lexical, Syntax, Semantic analysis; Intermediate code; Optimization; Code generation',
            'Parsing and linking',
            'Reading and writing'
        ],
        correct: 1,
        explanation: 'Compiler phases: 1) Lexical analysis 2) Syntax analysis 3) Semantic analysis 4) Intermediate code 5) Optimization 6) Code generation.'
    },
    {
        id: 43,
        category: 'Languages',
        difficulty: 'medium',
        question: 'What is the difference between interpreted and compiled languages?',
        options: [
            'No difference',
            'Compiled converts to machine code before execution; Interpreted converts at runtime',
            'Interpreted is always faster',
            'Compiled cannot handle errors'
        ],
        correct: 1,
        explanation: 'Compiled (C++, Java): code compiled to machine code first. Interpreted (Python, JS): code executed line-by-line at runtime.'
    },
    // Software Architecture
    {
        id: 44,
        category: 'Software Engineering',
        difficulty: 'medium',
        question: 'What is the MVC (Model-View-Controller) architectural pattern?',
        options: [
            'Only used for web development',
            'Separates code into Model (data), View (UI), Controller (logic)',
            'A database design pattern',
            'A testing framework'
        ],
        correct: 1,
        explanation: 'MVC separates concerns: Model handles data, View displays UI, Controller handles user input and business logic.'
    },
    {
        id: 45,
        category: 'Software Engineering',
        difficulty: 'hard',
        question: 'What is the difference between monolithic and microservices architecture?',
        options: [
            'Same thing, different names',
            'Monolithic: single unit; Microservices: independent small services',
            'Monolithic is better',
            'Microservices cannot scale'
        ],
        correct: 1,
        explanation: 'Monolithic: single codebase for entire app. Microservices: small independent services that communicate via APIs.'
    },
    // API & REST
    {
        id: 46,
        category: 'Web Development',
        difficulty: 'medium',
        question: 'What does REST stand for?',
        options: [
            'Reactive Exchange State Transfer',
            'Representational State Transfer',
            'Remote Server Transactions',
            'Relay Server Technology'
        ],
        correct: 1,
        explanation: 'REST (Representational State Transfer) is an architectural style for building APIs using standard HTTP methods.'
    },
    {
        id: 47,
        category: 'Web Development',
        difficulty: 'medium',
        question: 'Which HTTP status code indicates successful request?',
        options: [
            '300-399',
            '200-299',
            '400-499',
            '500-599'
        ],
        correct: 1,
        explanation: 'Status codes 200-299 indicate success (200 OK, 201 Created, 204 No Content, etc.)'
    },
    // Network Protocols Advanced
    {
        id: 48,
        category: 'Computer Networks',
        difficulty: 'hard',
        question: 'What is the difference between HTTP and HTTPS?',
        options: [
            'HTTPS is faster',
            'HTTPS adds encryption/SSL layer for secure communication',
            'HTTP is more secure',
            'No practical difference'
        ],
        correct: 1,
        explanation: 'HTTPS (HTTP Secure) adds SSL/TLS encryption to HTTP, protecting data in transit from interception.'
    },
    {
        id: 49,
        category: 'Computer Networks',
        difficulty: 'hard',
        question: 'What is a DNS server?',
        options: [
            'Stores user passwords',
            'Translates domain names to IP addresses',
            'Manages internet bandwidth',
            'Encrypts network traffic'
        ],
        correct: 1,
        explanation: 'DNS (Domain Name System) translates human-readable domain names (google.com) to IP addresses (142.251.x.x).'
    },
    // Database Advanced
    {
        id: 50,
        category: 'Databases',
        difficulty: 'hard',
        question: 'What is database indexing?',
        options: [
            'Organizing data alphabetically',
            'Data structure that speeds up query retrieval but uses extra memory',
            'Primary key of a table',
            'Column naming convention'
        ],
        correct: 1,
        explanation: 'Indexes create sorted data structures (B-trees) for faster lookups, sacrificing write performance and memory for read speed.'
    },
    {
        id: 51,
        category: 'Databases',
        difficulty: 'medium',
        question: 'What is a database transaction?',
        options: [
            'Moving data between databases',
            'Set of operations that must succeed together or fail together',
            'Backup process',
            'User login session'
        ],
        correct: 1,
        explanation: 'A transaction is an atomic unit of work - either all operations complete successfully or all rollback on failure.'
    },
    // Git & Version Control
    {
        id: 52,
        category: 'DevOps',
        difficulty: 'easy',
        question: 'What is the purpose of version control systems like Git?',
        options: [
            'Speed up code execution',
            'Track changes, enable collaboration, maintain history',
            'Encrypt source code',
            'Optimize RAM usage'
        ],
        correct: 1,
        explanation: 'Version control systems track code changes, enable team collaboration, and maintain a complete project history.'
    },
    {
        id: 53,
        category: 'DevOps',
        difficulty: 'medium',
        question: 'What is the difference between merge and rebase in Git?',
        options: [
            'No difference',
            'Merge combines branches; Rebase replays commits on top of another branch',
            'Rebase is older',
            'Merge deletes branches'
        ],
        correct: 1,
        explanation: 'Merge creates a merge commit combining branches. Rebase replays commits linearly, creating cleaner history.'
    },
    // Mobile Development
    {
        id: 54,
        category: 'Mobile Development',
        difficulty: 'medium',
        question: 'What is cross-platform mobile development?',
        options: [
            'Development for both iOS and Android using single codebase',
            'Developing for tablets only',
            'Mobile web development only',
            'Platform-specific native development'
        ],
        correct: 0,
        explanation: 'Cross-platform development (Flutter, React Native) allows writing once and deploying to multiple platforms.'
    },
    {
        id: 55,
        category: 'Mobile Development',
        difficulty: 'medium',
        question: 'What is the difference between native and hybrid mobile apps?',
        options: [
            'No difference',
            'Native: platform-specific; Hybrid: web technologies (HTML/CSS/JS) in native wrapper',
            'Native is always better',
            'Hybrid cannot access device features'
        ],
        correct: 1,
        explanation: 'Native apps (Swift, Kotlin) are platform-specific. Hybrid apps (Cordova) use web tech wrapped in native container.'
    },
    // Testing
    {
        id: 56,
        category: 'Software Engineering',
        difficulty: 'medium',
        question: 'What are the different levels of software testing?',
        options: [
            'Alpha and Beta testing only',
            'Unit, Integration, System, Acceptance testing',
            'Only automated testing',
            'Manual testing only'
        ],
        correct: 1,
        explanation: 'Testing levels: 1) Unit (individual components) 2) Integration (combined modules) 3) System (entire system) 4) Acceptance (user requirements).'
    },
    {
        id: 57,
        category: 'Software Engineering',
        difficulty: 'medium',
        question: 'What is code coverage in testing?',
        options: [
            'Number of lines written',
            'Percentage of code executed by tests',
            'Test documentation',
            'Number of test files'
        ],
        correct: 1,
        explanation: 'Code coverage measures what percentage of code is executed during testing. Higher coverage generally means better testing.'
    },
    // Design Principles
    {
        id: 58,
        category: 'Software Engineering',
        difficulty: 'hard',
        question: 'What is the Single Responsibility Principle (SRP)?',
        options: [
            'One function per file',
            'A class should have only one reason to change',
            'Using single data types only',
            'No inheritance allowed'
        ],
        correct: 1,
        explanation: 'SRP states each class/module should have only one responsibility, making code more maintainable and testable.'
    },
    {
        id: 59,
        category: 'Software Engineering',
        difficulty: 'hard',
        question: 'What is the Open/Closed Principle (OCP)?',
        options: [
            'All files must be open',
            'Software entities should be open for extension but closed for modification',
            'Use open-source libraries only',
            'Close connections immediately'
        ],
        correct: 1,
        explanation: 'OCP: Extend functionality through inheritance/composition, not by modifying existing code.'
    },
    // Performance & Optimization
    {
        id: 60,
        category: 'Algorithms',
        difficulty: 'hard',
        question: 'What is memoization?',
        options: [
            'Writing notes in code',
            'Storing results of expensive computations for reuse',
            'Memory allocation technique',
            'Variable naming convention'
        ],
        correct: 1,
        explanation: 'Memoization caches function results to avoid recalculating same inputs, used in dynamic programming optimization.'
    }
];

// ========== MAIN APPLICATION ==========
class QuizApp {
    constructor() {
        this.currentQuestions = [];
        this.currentQuestionIndex = 0;
        this.userAnswers = [];
        this.score = 0;
        this.startTime = 0;
        this.timeLeft = 30;
        this.timerInterval = null;
        this.answered = false;
        this.history = this.loadHistory();
        this.leaderboard = this.loadLeaderboard();
        this.modalCallback = null;
        this.init();
    }

    init() {
        this.updateStats();
        this.setupKeyboardShortcuts();
    }

    // ========== QUIZ LOGIC ==========
    startQuiz() {
        // Shuffle and select 10 random questions
        this.currentQuestions = this.getRandomQuestions(10);
        this.currentQuestionIndex = 0;
        this.userAnswers = new Array(10).fill(null);
        this.score = 0;
        this.startTime = Date.now();
        this.answered = false;

        this.showScreen('quizScreen');
        this.loadQuestion();
    }

    getRandomQuestions(count) {
        const shuffled = [...QUESTION_BANK].sort(() => Math.random() - 0.5);
        return shuffled.slice(0, count).map((q, idx) => ({
            ...q,
            quizIndex: idx
        }));
    }

    loadQuestion() {
        this.answered = false;
        this.timeLeft = 30;
        const question = this.currentQuestions[this.currentQuestionIndex];

        // Update header
        document.getElementById('questionCount').textContent =
            `Question ${this.currentQuestionIndex + 1} of ${this.currentQuestions.length}`;
        document.getElementById('questionBadge').textContent = `Q${this.currentQuestionIndex + 1}`;
        document.getElementById('scoreDisplay').textContent = `Score: ${this.score}/${this.currentQuestions.length}`;

        // Update progress bar
        const progress = ((this.currentQuestionIndex + 1) / this.currentQuestions.length) * 100;
        document.getElementById('progressFill').style.width = progress + '%';

        // Display question
        document.getElementById('questionText').innerHTML = this.formatQuestion(question);

        // Shuffle and display options
        const shuffledOptions = this.shuffleArray(question.options.map((opt, idx) => ({
            text: opt,
            originalIndex: idx
        })));

        const optionsHtml = shuffledOptions.map((opt, idx) => `
            <label class="option">
                <input type="radio" name="option" value="${idx}" onchange="app.handleOptionSelect(${idx})">
                <div class="option-label">
                    <div class="option-radio"></div>
                    <div class="option-text">${idx + 1}. ${opt.text}</div>
                </div>
            </label>
        `).join('');

        document.getElementById('optionsContainer').innerHTML = optionsHtml;
        document.getElementById('feedback').classList.remove('show', 'correct', 'incorrect');
        document.getElementById('submitBtn').disabled = false;

        // Store original indices for correct answer checking
        this.currentQuestion = question;
        this.currentShuffledOptions = shuffledOptions;

        this.startTimer();
    }

    formatQuestion(question) {
        let html = `<div>${question.question}</div>`;
        if (question.code) {
            html += `<div class="question-code">${this.escapeHtml(question.code)}</div>`;
        }
        return html;
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    shuffleArray(arr) {
        return [...arr].sort(() => Math.random() - 0.5);
    }

    startTimer() {
        if (this.timerInterval) clearInterval(this.timerInterval);

        const updateTimer = () => {
            const timerEl = document.getElementById('timerValue');
            timerEl.classList.remove('timer-warning', 'timer-danger');

            if (this.timeLeft <= 0) {
                clearInterval(this.timerInterval);
                this.skipQuestion();
            } else if (this.timeLeft <= 10) {
                timerEl.classList.add('timer-warning');
                if (this.timeLeft <= 5) {
                    timerEl.classList.remove('timer-warning');
                    timerEl.classList.add('timer-danger');
                }
            }

            timerEl.textContent = this.timeLeft;
            this.timeLeft--;
        };

        updateTimer();
        this.timerInterval = setInterval(updateTimer, 1000);
    }

    handleOptionSelect(selectedIndex) {
        const selectedOption = this.currentShuffledOptions[selectedIndex];
        this.selectedOptionText = selectedOption.text;
    }

    submitAnswer() {
        if (this.answered) {
            this.nextQuestion();
            return;
        }

        const selected = document.querySelector('input[name="option"]:checked');
        if (!selected) {
            alert('Please select an answer');
            return;
        }

        clearInterval(this.timerInterval);
        this.answered = true;

        const selectedIndex = parseInt(selected.value);
        const selectedOption = this.currentShuffledOptions[selectedIndex];
        const question = this.currentQuestion;
        const isCorrect = selectedOption.text === question.options[question.correct];

        if (isCorrect) {
            this.score++;
        }

        this.userAnswers[this.currentQuestionIndex] = {
            selected: selectedOption.text,
            correct: question.options[question.correct],
            isCorrect: isCorrect
        };

        this.showFeedback(isCorrect, question);
        document.getElementById('scoreDisplay').textContent = `Score: ${this.score}/${this.currentQuestions.length}`;
        document.getElementById('submitBtn').textContent = 'Next Question';
        document.getElementById('submitBtn').disabled = false;

        // Disable options
        document.querySelectorAll('input[name="option"]').forEach(el => {
            el.disabled = true;
        });
        document.querySelectorAll('.option').forEach(el => {
            el.style.pointerEvents = 'none';
            el.style.opacity = '0.7';
        });

        // Highlight correct answer
        document.querySelectorAll('.option').forEach((el, idx) => {
            if (this.currentShuffledOptions[idx].text === question.options[question.correct]) {
                el.classList.add('correct');
            } else if (idx === parseInt(selected.value) && !isCorrect) {
                el.classList.add('incorrect');
            }
        });
    }

    showFeedback(isCorrect, question) {
        const feedback = document.getElementById('feedback');
        const icon = isCorrect ? '✓' : '✗';
        const message = isCorrect ? 'Correct!' : 'Incorrect!';

        feedback.innerHTML = `
            <strong><span class="feedback-icon">${icon}</span>${message}</strong>
            <div style="margin-top: 8px;">${question.explanation}</div>
        `;
        feedback.classList.add('show', isCorrect ? 'correct' : 'incorrect');
    }

    skipQuestion() {
        clearInterval(this.timerInterval);
        this.userAnswers[this.currentQuestionIndex] = null;
        this.nextQuestion();
    }

    nextQuestion() {
        this.currentQuestionIndex++;

        if (this.currentQuestionIndex >= this.currentQuestions.length) {
            this.endQuiz();
        } else {
            this.loadQuestion();
        }
    }

    endQuiz() {
        clearInterval(this.timerInterval);

        const timeTaken = Math.round((Date.now() - this.startTime) / 1000);
        const accuracy = Math.round((this.score / this.currentQuestions.length) * 100);

        // Save to history
        this.addToHistory({
            score: this.score,
            totalQuestions: this.currentQuestions.length,
            timeTaken: timeTaken,
            accuracy: accuracy,
            categories: this.getQuizCategories(),
            date: new Date().toLocaleDateString()
        });

        // Save to leaderboard
        this.addToLeaderboard({
            score: this.score,
            totalQuestions: this.currentQuestions.length,
            timeTaken: timeTaken,
            accuracy: accuracy,
            date: new Date().toLocaleDateString()
        });

        this.showResults(accuracy, timeTaken);
    }

    getQuizCategories() {
        const categories = {};
        this.currentQuestions.forEach(q => {
            categories[q.category] = (categories[q.category] || 0) + 1;
        });
        return Object.keys(categories).join(', ');
    }

    showResults(accuracy, timeTaken) {
        document.getElementById('scorePercentage').textContent = accuracy + '%';
        document.getElementById('scoreCircle').style.setProperty('--percentage', (accuracy / 100 * 360) + 'deg');
        document.getElementById('correctAnswers').textContent = `${this.score}/${this.currentQuestions.length}`;
        document.getElementById('timeTaken').textContent = `${timeTaken}s`;
        document.getElementById('accuracyDisplay').textContent = accuracy + '%';
        document.getElementById('categoryDisplay').textContent = this.getQuizCategories();

        this.showScreen('resultsScreen');
    }

    // ========== STORAGE ==========
    addToHistory(result) {
        this.history.unshift(result);
        this.history = this.history.slice(0, 50); // Keep last 50
        localStorage.setItem('quizHistory', JSON.stringify(this.history));
    }

    addToLeaderboard(result) {
        this.leaderboard.push(result);
        this.leaderboard.sort((a, b) => b.score - a.score || b.accuracy - a.accuracy);
        this.leaderboard = this.leaderboard.slice(0, 100); // Keep top 100
        localStorage.setItem('quizLeaderboard', JSON.stringify(this.leaderboard));
    }

    loadHistory() {
        try {
            return JSON.parse(localStorage.getItem('quizHistory')) || [];
        } catch {
            return [];
        }
    }

    loadLeaderboard() {
        try {
            return JSON.parse(localStorage.getItem('quizLeaderboard')) || [];
        } catch {
            return [];
        }
    }

    updateStats() {
        if (this.history.length === 0) {
            document.getElementById('totalQuizzes').textContent = '0';
            document.getElementById('bestScore').textContent = '0%';
            document.getElementById('avgScore').textContent = '0%';
            document.getElementById('totalCorrect').textContent = '0';
            return;
        }

        const totalQuizzes = this.history.length;
        const bestScore = Math.max(...this.history.map(h => h.score)) +
                          '/' + this.history[0].totalQuestions;
        const avgScore = Math.round(
            this.history.reduce((sum, h) => sum + h.accuracy, 0) / totalQuizzes
        );
        const totalCorrect = this.history.reduce((sum, h) => sum + h.score, 0);

        document.getElementById('totalQuizzes').textContent = totalQuizzes;
        document.getElementById('bestScore').textContent =
            `${Math.max(...this.history.map(h => h.score))}/${this.history[0].totalQuestions}`;
        document.getElementById('avgScore').textContent = avgScore + '%';
        document.getElementById('totalCorrect').textContent = totalCorrect;
    }

    // ========== UI NAVIGATION ==========
    showScreen(screenId) {
        document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
        document.getElementById(screenId).classList.add('active');

        if (screenId === 'leaderboardScreen') {
            this.displayLeaderboard();
        }
        if (screenId === 'historyScreen') {
            this.displayHistory();
        }
    }

    displayLeaderboard() {
        const list = document.getElementById('leaderboardList');
        const topScores = this.leaderboard.slice(0, 5);

        if (topScores.length === 0) {
            list.innerHTML = '<li class="leaderboard-empty">No scores yet. Start quizzing!</li>';
            return;
        }

        list.innerHTML = topScores.map((entry, idx) => `
            <li class="leaderboard-item">
                <div class="leaderboard-rank top">${idx + 1}</div>
                <div class="leaderboard-info">
                    <div class="leaderboard-name">Quiz ${idx + 1}</div>
                    <div class="leaderboard-time">${entry.date} • ${entry.timeTaken}s</div>
                </div>
                <div class="leaderboard-score">${entry.score}/${entry.totalQuestions}</div>
            </li>
        `).join('');
    }

    displayHistory() {
        const list = document.getElementById('historyList');

        if (this.history.length === 0) {
            list.innerHTML = '<li class="leaderboard-empty">No quiz history yet. Start your first quiz!</li>';
            return;
        }

        list.innerHTML = this.history.slice(0, 20).map((entry, idx) => `
            <li class="leaderboard-item">
                <div class="leaderboard-rank">${idx + 1}</div>
                <div class="leaderboard-info">
                    <div class="leaderboard-name">${entry.categories || 'Mixed Topics'}</div>
                    <div class="leaderboard-time">${entry.date} • ${entry.timeTaken}s</div>
                </div>
                <div class="leaderboard-score" style="margin-left: 16px;">
                    <div>${entry.score}/${entry.totalQuestions}</div>
                    <div style="font-size: 12px; color: var(--text-secondary);">${entry.accuracy}%</div>
                </div>
            </li>
        `).join('');
    }

    showLeaderboard() {
        this.showScreen('leaderboardScreen');
    }

    showHistory() {
        this.showScreen('historyScreen');
    }

    toggleLeaderboard() {
        if (document.getElementById('leaderboardScreen').classList.contains('active')) {
            this.goHome();
        } else {
            this.showLeaderboard();
        }
    }

    goHome() {
        this.showScreen('welcomeScreen');
        this.updateStats();
    }

    // ========== KEYBOARD SHORTCUTS ==========
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            if (!document.getElementById('quizScreen').classList.contains('active')) return;

            if (e.key >= '1' && e.key <= '4') {
                const idx = parseInt(e.key) - 1;
                const radio = document.querySelector(`input[name="option"][value="${idx}"]`);
                if (radio && !radio.disabled) {
                    radio.click();
                }
            } else if (e.key === 'Enter') {
                const submit = document.getElementById('submitBtn');
                if (!submit.disabled) {
                    submit.click();
                }
            }
        });
    }

    // ========== MODAL ==========
    showModal(title, text, onConfirm) {
        document.getElementById('modalTitle').textContent = title;
        document.getElementById('modalText').textContent = text;
        this.modalCallback = onConfirm;
        document.getElementById('modal').classList.add('active');
    }

    confirmModal() {
        if (this.modalCallback) {
            this.modalCallback();
        }
        this.closeModal();
    }

    closeModal() {
        document.getElementById('modal').classList.remove('active');
        this.modalCallback = null;
    }
}

// Initialize app
const app = new QuizApp();

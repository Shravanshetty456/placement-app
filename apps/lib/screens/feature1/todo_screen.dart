import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/todo_service.dart';
import '../../services/auth_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  List<TodoTask> _tasks = [];
  int _editIndex = -1;
  int? _editingTodoId;

  // Time selection
  TimeOfDay? _selectedStartTime;
  int _selectedDurationMinutes = 0;

  // Custom time picker controllers
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  // Duration picker controllers
  final TextEditingController _durationHourController = TextEditingController();
  final TextEditingController _durationMinuteController =
      TextEditingController();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = true;

  // Statistics
  int get _completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get _pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  // Compute end time from start + duration
  TimeOfDay? _computedEndTime() {
    if (_selectedStartTime == null || _selectedDurationMinutes <= 0)
      return null;
    final totalMinutes =
        _selectedStartTime!.hour * 60 +
        _selectedStartTime!.minute +
        _selectedDurationMinutes;
    return TimeOfDay(
      hour: (totalMinutes ~/ 60) % 24,
      minute: totalMinutes % 60,
    );
  }

  List<TodoTask> get _currentTimeTasks {
    final now = TimeOfDay.now();
    return _tasks.where((task) {
      if (task.isCompleted ||
          task.startHour == null ||
          task.startMinute == null ||
          task.durationMinutes <= 0)
        return false;
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = task.startHour! * 60 + task.startMinute!;
      final endMinutes = startMinutes + task.durationMinutes;
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    }).toList();
  }

  List<TodoTask> get _upcomingTasks {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    return _tasks.where((task) {
      if (task.isCompleted ||
          task.startHour == null ||
          task.startMinute == null)
        return false;
      final startMinutes = task.startHour! * 60 + task.startMinute!;
      final timeDiff = startMinutes - nowMinutes;
      return timeDiff > 0 && timeDiff <= 30;
    }).toList();
  }

  List<TodoTask> get _sortedTasks {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    List<TodoTask> sorted = List.from(_tasks);
    sorted.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      final aHasTime = a.startHour != null && a.startMinute != null;
      final bHasTime = b.startHour != null && b.startMinute != null;

      if (aHasTime && bHasTime) {
        final aMinutes = a.startHour! * 60 + a.startMinute!;
        final bMinutes = b.startHour! * 60 + b.startMinute!;
        final aDiff = aMinutes >= nowMinutes
            ? aMinutes - nowMinutes
            : (aMinutes + 24 * 60) - nowMinutes;
        final bDiff = bMinutes >= nowMinutes
            ? bMinutes - nowMinutes
            : (bMinutes + 24 * 60) - nowMinutes;
        return aDiff.compareTo(bDiff);
      }
      if (aHasTime && !bHasTime) return -1;
      if (!aHasTime && bHasTime) return 1;
      return a.title.compareTo(b.title);
    });
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadTodos();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _durationHourController.dispose();
    _durationMinuteController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await TodoService.getTodos();
    if (mounted) {
      setState(() {
        _tasks = todos;
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateTodo() async {
    if (_titleController.text.isEmpty) return;

    final userId = AuthService.currentUser?['id'];
    if (userId == null) return;

    final todo = TodoTask(
      id: _editingTodoId,
      userId: userId,
      title: _titleController.text,
      startHour: _selectedStartTime?.hour,
      startMinute: _selectedStartTime?.minute,
      durationMinutes: _selectedDurationMinutes,
      isCompleted: _editIndex != -1 ? _tasks[_editIndex].isCompleted : false,
    );

    if (_editIndex == -1) {
      final created = await TodoService.createTodo(todo);
      if (created != null && mounted) {
        setState(() => _tasks.add(created));
      }
    } else {
      final updated = await TodoService.updateTodo(todo);
      if (updated != null && mounted) {
        setState(() => _tasks[_editIndex] = updated);
      }
    }

    _titleController.clear();
    _selectedStartTime = null;
    _selectedDurationMinutes = 0;
    _editIndex = -1;
    _editingTodoId = null;
  }

  void _startEditing(int index) {
    final task = _tasks[index];
    setState(() {
      _editIndex = index;
      _editingTodoId = task.id;
      _titleController.text = task.title;
      _selectedStartTime = task.startHour != null && task.startMinute != null
          ? TimeOfDay(hour: task.startHour!, minute: task.startMinute!)
          : null;
      _selectedDurationMinutes = task.durationMinutes;
    });
    _showAddEditDialog();
  }

  Future<void> _deleteTodo(int index) async {
    final task = _tasks[index];
    if (task.id != null) {
      final success = await TodoService.deleteTodo(task.id!);
      if (success && mounted) {
        setState(() {
          _tasks.removeAt(index);
          if (_editIndex == index) {
            _editIndex = -1;
            _editingTodoId = null;
            _titleController.clear();
            _selectedStartTime = null;
            _selectedDurationMinutes = 0;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Task deleted', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleTaskCompletion(int index) async {
    final task = _tasks[index];
    if (task.id != null) {
      final updated = await TodoService.toggleTodo(task.id!);
      if (updated != null && mounted) {
        setState(() => _tasks[index] = updated);

        if (updated.isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Task completed!',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  Future<void> _showStartTimePicker() async {
    _hourController.clear();
    _minuteController.clear();

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                AppTheme.secondaryColor.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select Start Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _hourController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: 'HH',
                              labelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _minuteController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: 'MM',
                              labelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '24-hour format (00-23)',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final hour =
                                int.tryParse(_hourController.text) ?? -1;
                            final minute =
                                int.tryParse(_minuteController.text) ?? -1;
                            if (hour >= 0 &&
                                hour <= 23 &&
                                minute >= 0 &&
                                minute <= 59) {
                              setState(() {
                                _selectedStartTime = TimeOfDay(
                                  hour: hour,
                                  minute: minute,
                                );
                              });
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Invalid time format'),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDurationPicker() async {
    if (_selectedDurationMinutes > 0) {
      _durationHourController.text = (_selectedDurationMinutes ~/ 60)
          .toString();
      _durationMinuteController.text = (_selectedDurationMinutes % 60)
          .toString();
    } else {
      _durationHourController.clear();
      _durationMinuteController.clear();
    }

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red.shade400, Colors.orange.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.hourglass_bottom,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select Duration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _durationHourController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: 'HH',
                              labelStyle: TextStyle(color: Colors.red.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red.shade400,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'h',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _durationMinuteController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            decoration: InputDecoration(
                              labelText: 'MM',
                              labelStyle: TextStyle(color: Colors.red.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red.shade400,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'm',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'End time = Start time + Duration',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final hours =
                                int.tryParse(_durationHourController.text) ?? 0;
                            final minutes =
                                int.tryParse(_durationMinuteController.text) ??
                                0;
                            final total = hours * 60 + minutes;

                            if (total > 0 && minutes < 60) {
                              setState(() => _selectedDurationMinutes = total);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Invalid duration'),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return '';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0 && m > 0) return '$h h $m m';
    if (h > 0) return '$h h';
    return '$m m';
  }

  void _showAddEditDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurface
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _editIndex == -1 ? Icons.add_task : Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _editIndex == -1 ? 'Create New Task' : 'Edit Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkText
                                : AppTheme.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Task Input
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkBackground.withOpacity(0.5)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkDivider
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkTextLight
                              : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.task_alt,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkText
                            : AppTheme.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start Time Button
                  InkWell(
                    onTap: () async {
                      await _showStartTimePicker();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedStartTime != null
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedStartTime == null
                                  ? 'Set start time'
                                  : 'Start at ${_selectedStartTime!.format(context)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedStartTime == null
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkTextLight
                                          : Colors.grey.shade600)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkText
                                          : AppTheme.textColor),
                                fontWeight: _selectedStartTime != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (_selectedStartTime != null)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Duration Button
                  InkWell(
                    onTap: () async {
                      await _showDurationPicker();
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.1),
                            Colors.orange.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedDurationMinutes > 0
                              ? Colors.red.shade400
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.hourglass_bottom,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDurationMinutes <= 0
                                  ? 'Set duration'
                                  : 'Duration: ${_formatDuration(_selectedDurationMinutes)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDurationMinutes <= 0
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkTextLight
                                          : Colors.grey.shade600)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppTheme.darkText
                                          : AppTheme.textColor),
                                fontWeight: _selectedDurationMinutes > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (_selectedDurationMinutes > 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // End Time Preview
                  if (_selectedStartTime != null &&
                      _selectedDurationMinutes > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ends at',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _computedEndTime()!.format(context),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _titleController.clear();
                            _selectedStartTime = null;
                            _selectedDurationMinutes = 0;
                            _editIndex = -1;
                            _editingTodoId = null;
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkTextLight
                                : Colors.grey.shade700,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkBackground
                                : Colors.grey.shade100,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_titleController.text.isNotEmpty) {
                              _addOrUpdateTodo();
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _editIndex == -1 ? 'Create Task' : 'Update Task',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // FIX: Wrap in Expanded so long usernames don't overflow
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${AuthService.userName}!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have $_pendingTasks pending tasks',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Animated welcome icon
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.waving_hand,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildEnhancedStatCard(
                            'Total Tasks',
                            '${_tasks.length}',
                            Icons.task_alt,
                            Colors.blue,
                            isDarkMode,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEnhancedStatCard(
                            'Completed',
                            '$_completedTasks',
                            Icons.check_circle,
                            Colors.green,
                            isDarkMode,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEnhancedStatCard(
                            'Pending',
                            '$_pendingTasks',
                            Icons.pending,
                            Colors.orange,
                            isDarkMode,
                          ),
                        ),
                      ],
                    ),

                    // Active tasks indicators
                    if (_currentTimeTasks.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.3),
                              Colors.green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ACTIVE NOW',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    _currentTimeTasks
                                        .map((t) => t.title)
                                        .join(' • '),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_upcomingTasks.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.3),
                              Colors.orange.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.upcoming,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'UPCOMING IN 30 MIN',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    _upcomingTasks
                                        .map((t) => t.title)
                                        .join(' • '),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Tasks List Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // FIX: Wrap in Expanded to prevent overflow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Tasks',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? AppTheme.darkText
                                          : AppTheme.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_sortedTasks.length} tasks • Sorted by upcoming',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? AppTheme.darkTextLight
                                          : Colors.grey.shade500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Animated Add Button
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: GestureDetector(
                                onTap: () {
                                  _editIndex = -1;
                                  _editingTodoId = null;
                                  _titleController.clear();
                                  _selectedStartTime = null;
                                  _selectedDurationMinutes = 0;
                                  _showAddEditDialog();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tasks List
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading your tasks...',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? AppTheme.darkTextLight
                                            : Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _tasks.isEmpty
                            ? _buildEnhancedEmptyState(isDarkMode)
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _sortedTasks.length,
                                  itemBuilder: (context, index) {
                                    return _buildEnhancedTaskCard(
                                      _sortedTasks[index],
                                      index,
                                      isDarkMode,
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppTheme.darkBackground
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt,
                size: 48,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkText : AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first task',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextLight : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.darkBackground
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Try adding time and duration for better planning',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppTheme.darkTextLight
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTaskCard(TodoTask task, int index, bool isDarkMode) {
    final actualIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (actualIndex == -1) return const SizedBox();

    final startTime = task.startHour != null && task.startMinute != null
        ? TimeOfDay(hour: task.startHour!, minute: task.startMinute!)
        : null;

    final isNow = _isTaskNow(task);
    final isOverdue =
        !task.isCompleted &&
        startTime != null &&
        task.durationMinutes > 0 &&
        TimeOfDay.now().hour * 60 + TimeOfDay.now().minute >
            startTime.hour * 60 + startTime.minute + task.durationMinutes;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startEditing(actualIndex),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? (task.isCompleted
                        ? AppTheme.darkBackground.withOpacity(0.3)
                        : isNow
                        ? Colors.green.withOpacity(0.1)
                        : isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : AppTheme.darkBackground)
                  : (task.isCompleted
                        ? Colors.grey.shade50
                        : isNow
                        ? Colors.green.shade50
                        : isOverdue
                        ? Colors.red.shade50
                        : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted
                    ? Colors.green.withOpacity(0.2)
                    : isNow
                    ? Colors.green.withOpacity(0.3)
                    : isOverdue
                    ? Colors.red.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Status Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: task.isCompleted
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          )
                        : isNow
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          )
                        : isOverdue
                        ? LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check : Icons.schedule,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),

                // Task Details — Expanded so it shrinks and doesn't push actions off screen
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: task.isCompleted
                              ? FontWeight.normal
                              : FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? (isDarkMode
                                    ? AppTheme.darkTextLight
                                    : Colors.grey)
                              : (isDarkMode
                                    ? AppTheme.darkText
                                    : AppTheme.textColor),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (startTime != null && task.durationMinutes > 0) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 11,
                              color: isNow
                                  ? Colors.green
                                  : isOverdue
                                  ? Colors.red
                                  : (isDarkMode
                                        ? AppTheme.darkTextLight
                                        : Colors.grey.shade500),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${startTime.format(context)} • ${_formatDuration(task.durationMinutes)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isNow
                                      ? Colors.green
                                      : isOverdue
                                      ? Colors.red
                                      : (isDarkMode
                                            ? AppTheme.darkTextLight
                                            : Colors.grey.shade500),
                                  fontWeight: isNow || isOverdue
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // FIX: Badge + actions stacked in a Column (no horizontal overflow)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge shown only when relevant
                    if (isNow && !task.isCompleted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NOW',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else if (isOverdue)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'LATE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    // Checkbox + menu in a tight Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 34,
                          height: 34,
                          child: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) =>
                                _toggleTaskCompletion(actualIndex),
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            shape: const CircleBorder(),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: PopupMenuButton(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: Icon(
                              Icons.more_vert,
                              color: isDarkMode
                                  ? AppTheme.darkTextLight
                                  : Colors.grey.shade500,
                              size: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red.shade400,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _startEditing(actualIndex);
                              } else if (value == 'delete') {
                                _deleteTodo(actualIndex);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isTaskNow(TodoTask task) {
    if (task.isCompleted ||
        task.startHour == null ||
        task.startMinute == null ||
        task.durationMinutes <= 0)
      return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = task.startHour! * 60 + task.startMinute!;
    final endMinutes = startMinutes + task.durationMinutes;

    if (endMinutes < startMinutes) {
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../theme/app_theme.dart';
// import '../../services/todo_service.dart';
// import '../../services/auth_service.dart';

// class TodoScreen extends StatefulWidget {
//   const TodoScreen({super.key});

//   @override
//   State<TodoScreen> createState() => _TodoScreenState();
// }

// class _TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _titleController = TextEditingController();
//   List<TodoTask> _tasks = [];
//   int _editIndex = -1;
//   int? _editingTodoId;

//   // Time selection
//   TimeOfDay? _selectedStartTime;
//   int _selectedDurationMinutes = 0;

//   // Custom time picker controllers
//   final TextEditingController _hourController = TextEditingController();
//   final TextEditingController _minuteController = TextEditingController();

//   // Duration picker controllers
//   final TextEditingController _durationHourController = TextEditingController();
//   final TextEditingController _durationMinuteController = TextEditingController();

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   bool _isLoading = true;

//   // Statistics
//   int get _completedTasks => _tasks.where((task) => task.isCompleted).length;
//   int get _pendingTasks => _tasks.where((task) => !task.isCompleted).length;

//   // Compute end time from start + duration
//   TimeOfDay? _computedEndTime() {
//     if (_selectedStartTime == null || _selectedDurationMinutes <= 0) return null;
//     final totalMinutes =
//         _selectedStartTime!.hour * 60 + _selectedStartTime!.minute + _selectedDurationMinutes;
//     return TimeOfDay(hour: (totalMinutes ~/ 60) % 24, minute: totalMinutes % 60);
//   }

//   List<TodoTask> get _currentTimeTasks {
//     final now = TimeOfDay.now();
//     return _tasks.where((task) {
//       if (task.isCompleted ||
//           task.startHour == null ||
//           task.startMinute == null ||
//           task.durationMinutes <= 0) return false;

//       final nowMinutes = now.hour * 60 + now.minute;
//       final startMinutes = task.startHour! * 60 + task.startMinute!;
//       final endMinutes = startMinutes + task.durationMinutes;

//       return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
//     }).toList();
//   }

//   List<TodoTask> get _upcomingTasks {
//     final now = TimeOfDay.now();
//     final nowMinutes = now.hour * 60 + now.minute;
//     return _tasks.where((task) {
//       if (task.isCompleted || task.startHour == null || task.startMinute == null) return false;
//       final startMinutes = task.startHour! * 60 + task.startMinute!;
//       final timeDiff = startMinutes - nowMinutes;
//       return timeDiff > 0 && timeDiff <= 30;
//     }).toList();
//   }

//   List<TodoTask> get _sortedTasks {
//     final now = TimeOfDay.now();
//     final nowMinutes = now.hour * 60 + now.minute;
//     List<TodoTask> sorted = List.from(_tasks);
//     sorted.sort((a, b) {
//       if (a.isCompleted && !b.isCompleted) return 1;
//       if (!a.isCompleted && b.isCompleted) return -1;

//       final aHasTime = a.startHour != null && a.startMinute != null;
//       final bHasTime = b.startHour != null && b.startMinute != null;

//       if (aHasTime && bHasTime) {
//         final aMinutes = a.startHour! * 60 + a.startMinute!;
//         final bMinutes = b.startHour! * 60 + b.startMinute!;
//         final aDiff = aMinutes >= nowMinutes
//             ? aMinutes - nowMinutes
//             : (aMinutes + 24 * 60) - nowMinutes;
//         final bDiff = bMinutes >= nowMinutes
//             ? bMinutes - nowMinutes
//             : (bMinutes + 24 * 60) - nowMinutes;
//         return aDiff.compareTo(bDiff);
//       }
//       if (aHasTime && !bHasTime) return -1;
//       if (!aHasTime && bHasTime) return 1;
//       return a.title.compareTo(b.title);
//     });
//     return sorted;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation =
//         CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
//     _animationController.forward();
//     _loadTodos();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _hourController.dispose();
//     _minuteController.dispose();
//     _durationHourController.dispose();
//     _durationMinuteController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadTodos() async {
//     setState(() => _isLoading = true);
//     final todos = await TodoService.getTodos();
//     if (mounted) {
//       setState(() {
//         _tasks = todos;
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _addOrUpdateTodo() async {
//     if (_titleController.text.isEmpty) return;

//     final userId = AuthService.currentUser?['id'];
//     if (userId == null) return;

//     final todo = TodoTask(
//       id: _editingTodoId,
//       userId: userId,
//       title: _titleController.text,
//       startHour: _selectedStartTime?.hour,
//       startMinute: _selectedStartTime?.minute,
//       durationMinutes: _selectedDurationMinutes,
//       isCompleted: _editIndex != -1 ? _tasks[_editIndex].isCompleted : false,
//     );

//     if (_editIndex == -1) {
//       final created = await TodoService.createTodo(todo);
//       if (created != null && mounted) {
//         setState(() => _tasks.add(created));
//       }
//     } else {
//       final updated = await TodoService.updateTodo(todo);
//       if (updated != null && mounted) {
//         setState(() => _tasks[_editIndex] = updated);
//       }
//     }

//     _titleController.clear();
//     _selectedStartTime = null;
//     _selectedDurationMinutes = 0;
//     _editIndex = -1;
//     _editingTodoId = null;
//   }

//   void _startEditing(int index) {
//     final task = _tasks[index];
//     setState(() {
//       _editIndex = index;
//       _editingTodoId = task.id;
//       _titleController.text = task.title;
//       _selectedStartTime = task.startHour != null && task.startMinute != null
//           ? TimeOfDay(hour: task.startHour!, minute: task.startMinute!)
//           : null;
//       _selectedDurationMinutes = task.durationMinutes;
//     });
//     _showAddEditDialog();
//   }

//   Future<void> _deleteTodo(int index) async {
//     final task = _tasks[index];
//     if (task.id != null) {
//       final success = await TodoService.deleteTodo(task.id!);
//       if (success && mounted) {
//         setState(() {
//           _tasks.removeAt(index);
//           if (_editIndex == index) {
//             _editIndex = -1;
//             _editingTodoId = null;
//             _titleController.clear();
//             _selectedStartTime = null;
//             _selectedDurationMinutes = 0;
//           }
//         });
//       }
//     }
//   }

//   Future<void> _toggleTaskCompletion(int index) async {
//     final task = _tasks[index];
//     if (task.id != null) {
//       final updated = await TodoService.toggleTodo(task.id!);
//       if (updated != null && mounted) {
//         setState(() => _tasks[index] = updated);
//       }
//     }
//   }

//   Future<void> _showStartTimePicker() async {
//     _hourController.clear();
//     _minuteController.clear();

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Start Time', style: TextStyle(fontSize: 16)),
//         content: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _hourController,
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 2,
//                         decoration: const InputDecoration(
//                           labelText: 'HH',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//                         ),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 6),
//                       child: Text(':',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                     ),
//                     Expanded(
//                       child: TextField(
//                         controller: _minuteController,
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 2,
//                         decoration: const InputDecoration(
//                           labelText: 'MM',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//                         ),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 '24-hour format (00-23)',
//                 style: TextStyle(fontSize: 11, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(fontSize: 13)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final hour = int.tryParse(_hourController.text) ?? -1;
//               final minute = int.tryParse(_minuteController.text) ?? -1;
//               if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
//                 setState(() {
//                   _selectedStartTime = TimeOfDay(hour: hour, minute: minute);
//                 });
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content:
//                         Text('Enter valid time (00-23 hours, 00-59 minutes)'),
//                     backgroundColor: Colors.red,
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primaryColor,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('OK', style: TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showDurationPicker() async {
//     if (_selectedDurationMinutes > 0) {
//       _durationHourController.text = (_selectedDurationMinutes ~/ 60).toString();
//       _durationMinuteController.text = (_selectedDurationMinutes % 60).toString();
//     } else {
//       _durationHourController.clear();
//       _durationMinuteController.clear();
//     }

//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Select Duration', style: TextStyle(fontSize: 16)),
//         content: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.8,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     // ✅ FIXED: Expanded instead of fixed SizedBox width
//                     Expanded(
//                       child: TextField(
//                         controller: _durationHourController,
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 2,
//                         decoration: const InputDecoration(
//                           labelText: 'HH',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//                         ),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 6),
//                       child: Text('h',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold)),
//                     ),
//                     // ✅ FIXED: Expanded instead of fixed SizedBox width
//                     Expanded(
//                       child: TextField(
//                         controller: _durationMinuteController,
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 2,
//                         decoration: const InputDecoration(
//                           labelText: 'MM',
//                           border: OutlineInputBorder(),
//                           counterText: '',
//                           contentPadding:
//                               EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//                         ),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 6),
//                       child: Text('m',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'End time = Start time + Duration',
//                 style: TextStyle(fontSize: 11, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(fontSize: 13)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final hours = int.tryParse(_durationHourController.text) ?? 0;
//               final minutes = int.tryParse(_durationMinuteController.text) ?? 0;
//               final total = hours * 60 + minutes;

//               if (total <= 0) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Duration must be at least 1 minute'),
//                     backgroundColor: Colors.red,
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 return;
//               }
//               if (minutes > 59) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Minutes must be between 0 and 59'),
//                     backgroundColor: Colors.red,
//                     duration: Duration(seconds: 2),
//                   ),
//                 );
//                 return;
//               }

//               setState(() => _selectedDurationMinutes = total);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('OK', style: TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDuration(int totalMinutes) {
//     if (totalMinutes <= 0) return '';
//     final h = totalMinutes ~/ 60;
//     final m = totalMinutes % 60;
//     if (h > 0 && m > 0) return '$h h $m m';
//     if (h > 0) return '$h h';
//     return '$m m';
//   }

//   void _showAddEditDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: Text(
//             _editIndex == -1 ? 'New Task' : 'Edit Task',
//             style: const TextStyle(fontSize: 16),
//           ),
//           content: Container(
//             width: double.maxFinite,
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.6,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   TextField(
//                     controller: _titleController,
//                     autofocus: true,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter task',
//                       border: OutlineInputBorder(),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                     ),
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                   const SizedBox(height: 16),

//                   // ✅ FIXED: Start Time Button - mainAxisSize.max so Flexible works correctly
//                   InkWell(
//                     onTap: () async {
//                       await _showStartTimePicker();
//                       setDialogState(() {});
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max, // ✅ FIXED
//                         children: [
//                           Icon(Icons.access_time,
//                               size: 18, color: AppTheme.primaryColor),
//                           const SizedBox(width: 8),
//                           Flexible(
//                             child: Text(
//                               _selectedStartTime == null
//                                   ? 'Select Start Time'
//                                   : 'Start: ${_selectedStartTime!.format(context)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _selectedStartTime == null
//                                     ? Colors.grey
//                                     : Colors.black,
//                                 fontWeight: _selectedStartTime != null
//                                     ? FontWeight.w500
//                                     : FontWeight.normal,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // ✅ FIXED: Duration Button - mainAxisSize.max so Flexible works correctly
//                   InkWell(
//                     onTap: () async {
//                       await _showDurationPicker();
//                       setDialogState(() {});
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.red.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.red.withOpacity(0.05),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max, // ✅ FIXED
//                         children: [
//                           const Icon(Icons.hourglass_bottom,
//                               size: 18, color: Colors.red),
//                           const SizedBox(width: 8),
//                           Flexible(
//                             child: Text(
//                               _selectedDurationMinutes <= 0
//                                   ? 'Select Duration'
//                                   : 'Duration: ${_formatDuration(_selectedDurationMinutes)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _selectedDurationMinutes <= 0
//                                     ? Colors.grey
//                                     : Colors.red,
//                                 fontWeight: _selectedDurationMinutes > 0
//                                     ? FontWeight.w500
//                                     : FontWeight.normal,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // ✅ FIXED: End time preview - mainAxisSize.max so Flexible works correctly
//                   if (_selectedStartTime != null && _selectedDurationMinutes > 0)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 12),
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.max, // ✅ FIXED
//                           children: [
//                             const Icon(Icons.schedule,
//                                 size: 16, color: Colors.blue),
//                             const SizedBox(width: 6),
//                             Flexible(
//                               child: Text(
//                                 'Ends at: ${_computedEndTime()!.format(context)}',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _titleController.clear();
//                 _selectedStartTime = null;
//                 _selectedDurationMinutes = 0;
//                 _editIndex = -1;
//                 _editingTodoId = null;
//                 Navigator.pop(context);
//               },
//               child: const Text('Cancel', style: TextStyle(fontSize: 13)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_titleController.text.isNotEmpty) {
//                   _addOrUpdateTodo();
//                   Navigator.pop(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: AppTheme.primaryColor,
//               ),
//               child: Text(
//                 _editIndex == -1 ? 'Add' : 'Update',
//                 style: const TextStyle(fontSize: 13),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDarkMode = themeProvider.isDarkMode;

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDarkMode
//                 ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
//                 : [const Color(0xFF667eea), const Color(0xFF764ba2)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Hello, ${AuthService.userName}!',
//                       style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                     Text(
//                       '$_pendingTasks pending',
//                       style: const TextStyle(
//                           fontSize: 12, color: Colors.white70),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: _buildStatCard('Total', '${_tasks.length}')),
//                         const SizedBox(width: 8),
//                         Expanded(
//                             child:
//                                 _buildStatCard('Done', '$_completedTasks')),
//                         const SizedBox(width: 8),
//                         Expanded(
//                             child: _buildStatCard('Left', '$_pendingTasks')),
//                       ],
//                     ),
//                     if (_currentTimeTasks.isNotEmpty)
//                       Container(
//                         margin: const EdgeInsets.only(top: 8),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.timer,
//                                 color: Colors.green, size: 12),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 'Now: ${_currentTimeTasks.map((t) => t.title).join(', ')}',
//                                 style: const TextStyle(
//                                     color: Colors.green, fontSize: 11),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     if (_upcomingTasks.isNotEmpty)
//                       Container(
//                         margin: const EdgeInsets.only(top: 4),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.upcoming,
//                                 color: Colors.orange, size: 12),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 'Soon: ${_upcomingTasks.map((t) => t.title).join(', ')}',
//                                 style: const TextStyle(
//                                     color: Colors.orange, fontSize: 11),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 8),
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? AppTheme.darkSurface : Colors.white,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding:
//                             const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Tasks',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: isDarkMode
//                                         ? AppTheme.darkText
//                                         : AppTheme.textColor,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Sorted by upcoming',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: isDarkMode
//                                         ? AppTheme.darkTextLight
//                                         : Colors.grey.shade500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 _editIndex = -1;
//                                 _editingTodoId = null;
//                                 _titleController.clear();
//                                 _selectedStartTime = null;
//                                 _selectedDurationMinutes = 0;
//                                 _showAddEditDialog();
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: const BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Color(0xFF667eea),
//                                       Color(0xFF764ba2)
//                                     ],
//                                   ),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(Icons.add,
//                                     color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: _isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : _tasks.isEmpty
//                                 ? _buildEmptyState(isDarkMode)
//                                 : FadeTransition(
//                                     opacity: _fadeAnimation,
//                                     child: ListView.builder(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12),
//                                       itemCount: _sortedTasks.length,
//                                       itemBuilder: (context, index) {
//                                         return _buildSimpleTaskCard(
//                                             _sortedTasks[index],
//                                             index,
//                                             isDarkMode);
//                                       },
//                                     ),
//                                   ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           Text(value,
//               style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white)),
//           Text(label,
//               style:
//                   const TextStyle(fontSize: 9, color: Colors.white70)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(bool isDarkMode) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.task_alt,
//               size: 40,
//               color: isDarkMode
//                   ? AppTheme.darkTextLight
//                   : Colors.grey.shade400),
//           const SizedBox(height: 8),
//           Text(
//             'No tasks',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color:
//                   isDarkMode ? AppTheme.darkText : AppTheme.textColor,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Tap + to add your first task',
//             style: TextStyle(
//               fontSize: 12,
//               color: isDarkMode
//                   ? AppTheme.darkTextLight
//                   : Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSimpleTaskCard(
//       TodoTask task, int index, bool isDarkMode) {
//     final actualIndex = _tasks.indexWhere((t) => t.id == task.id);
//     if (actualIndex == -1) return const SizedBox();

//     final startTime =
//         task.startHour != null && task.startMinute != null
//             ? TimeOfDay(
//                 hour: task.startHour!, minute: task.startMinute!)
//             : null;
//     final endTime = startTime != null && task.durationMinutes > 0
//         ? TimeOfDay(
//             hour: (startTime.hour * 60 +
//                         startTime.minute +
//                         task.durationMinutes) ~/
//                     60 %
//                 24,
//             minute:
//                 (startTime.minute + task.durationMinutes) % 60,
//           )
//         : null;

//     final isNow = _isTaskNow(task);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       padding:
//           const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: isDarkMode
//             ? AppTheme.darkBackground.withOpacity(0.5)
//             : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(
//           color: task.isCompleted
//               ? Colors.green.withOpacity(0.2)
//               : isNow
//                   ? Colors.green.withOpacity(0.3)
//                   : Colors.grey.withOpacity(0.1),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: task.isCompleted
//                   ? Colors.green
//                   : isNow
//                       ? Colors.green
//                       : AppTheme.primaryColor.withOpacity(0.8),
//             ),
//             child: Icon(
//               task.isCompleted ? Icons.check : Icons.schedule,
//               color: Colors.white,
//               size: 12,
//             ),
//           ),
//           const SizedBox(width: 8),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   task.title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     decoration: task.isCompleted
//                         ? TextDecoration.lineThrough
//                         : null,
//                     color: task.isCompleted
//                         ? (isDarkMode
//                             ? AppTheme.darkTextLight
//                             : Colors.grey)
//                         : (isDarkMode
//                             ? AppTheme.darkText
//                             : AppTheme.textColor),
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (startTime != null && endTime != null)
//                   Text(
//                     '${startTime.format(context)} → ${endTime.format(context)}  (${_formatDuration(task.durationMinutes)})',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isNow
//                           ? Colors.green
//                           : (isDarkMode
//                               ? AppTheme.darkTextLight
//                               : Colors.grey.shade500),
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Checkbox(
//                 value: task.isCompleted,
//                 onChanged: (value) =>
//                     _toggleTaskCompletion(actualIndex),
//                 activeColor: Colors.green,
//                 checkColor: Colors.white,
//                 materialTapTargetSize:
//                     MaterialTapTargetSize.shrinkWrap,
//                 visualDensity: VisualDensity.compact,
//                 shape: const CircleBorder(),
//               ),
//               PopupMenuButton(
//                 icon: Icon(
//                   Icons.more_vert,
//                   color: isDarkMode
//                       ? AppTheme.darkTextLight
//                       : Colors.grey.shade500,
//                   size: 14,
//                 ),
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                       value: 'edit',
//                       child: Text('Edit',
//                           style: TextStyle(fontSize: 12))),
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: Text('Delete',
//                         style: TextStyle(
//                             fontSize: 12, color: Colors.red)),
//                   ),
//                 ],
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     _startEditing(actualIndex);
//                   } else if (value == 'delete') {
//                     _deleteTodo(actualIndex);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isTaskNow(TodoTask task) {
//     if (task.isCompleted ||
//         task.startHour == null ||
//         task.startMinute == null ||
//         task.durationMinutes <= 0) return false;

//     final now = TimeOfDay.now();
//     final nowMinutes = now.hour * 60 + now.minute;
//     final startMinutes = task.startHour! * 60 + task.startMinute!;
//     final endMinutes = startMinutes + task.durationMinutes;

//     if (endMinutes < startMinutes) {
//       return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
//     }
//     return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
//   }
// }

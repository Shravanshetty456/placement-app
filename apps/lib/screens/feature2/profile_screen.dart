import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User Profile Data (Editable) - Initialize with actual user data
  late String _userName;
  late String _userEmail;
  late String _userInitials;
  final String _memberSince = 'January 2024';
  final bool _isVerified = true;

  // Stats Data (NOT EDITABLE - Performance Based)
  final int _level = 5;
  final int _xp = 2450;
  final int _streak = 7;

  // Academic Details (Degree & Branch NOT EDITABLE)
  final String _degree = 'Bachelor of Technology';
  final String _branch = 'Computer Science';
  String _year = '3rd Year';
  String _cgpa = '8.5/10';

  // Career Goals (All Editable)
  String _targetRole = 'Software Engineer';
  String _preferredCompanies = 'Google, Microsoft, Amazon';
  String _expectedPackage = '12-15 LPA';
  String _skillsToFocus = 'DSA, System Design, React';

  // Achievements List (Editable)
  final List<Map<String, String>> _achievements = [
    {'title': '7-Day Study Streak', 'date': 'March 2024'},
    {'title': 'Solved 50+ Coding Problems', 'date': 'February 2024'},
    {'title': 'Completed 3 Online Courses', 'date': 'January 2024'},
    {'title': 'Attended 5 Mock Interviews', 'date': 'December 2023'},
  ];

  // List of available years for dropdown
  final List<String> _availableYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year (Integrated)',
    'Graduated',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with actual user data from AuthService
    _userName = AuthService.userName;
    _userEmail = AuthService.userEmail;
    _userInitials = AuthService.userInitials;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDarkMode
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Theme Toggle Button
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: isDarkMode
                                  ? Colors.amber
                                  : AppTheme.primaryColor,
                              size: 22,
                            ),
                            onPressed: () {
                              themeProvider.toggleTheme();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: isDarkMode
                                  ? AppTheme.darkText
                                  : AppTheme.primaryColor,
                              size: 22,
                            ),
                            onPressed: () => _showFullEditDialog(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isDarkMode
                              ? AppTheme.primaryColor.withOpacity(0.3)
                              : Colors.blue.shade100,
                          child: Text(
                            _userInitials,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppTheme.darkText
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        if (_isVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDarkMode
                                      ? AppTheme.darkSurface
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? AppTheme.darkText
                            : AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppTheme.darkTextLight
                            : AppTheme.lightTextLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    _buildCompactStatCard(
                      'Level',
                      '$_level',
                      Icons.stars,
                      Colors.blue,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildCompactStatCard(
                      'XP',
                      '$_xp',
                      Icons.bolt,
                      Colors.orange,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildCompactStatCard(
                      'Streak',
                      '$_streak days',
                      Icons.local_fire_department,
                      Colors.red,
                      isDarkMode,
                    ),
                  ],
                ),
              ),

              // Settings Section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? AppTheme.darkText
                              : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Settings List
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            // Personal Information Section
                            _buildSectionHeader(
                              'Personal Information and goals',
                              isDarkMode,
                            ),
                            _buildOptionItem(
                              icon: Icons.person_outline,
                              title: 'Personal Information',
                              subtitle: 'View and edit personal details',
                              isDarkMode: isDarkMode,
                              onTap: () => _showPersonalInfoDialog(isDarkMode),
                            ),
                            _buildOptionItem(
                              icon: Icons.school_outlined,
                              title: 'Academic Details',
                              subtitle:
                                  'Degree, branch, CGPA (Degree & Branch fixed)',
                              isDarkMode: isDarkMode,
                              onTap: () =>
                                  _showAcademicDetailsDialog(isDarkMode),
                            ),

                            // Career Section
                            _buildOptionItem(
                              icon: Icons.work_outline,
                              title: 'Career Goals',
                              subtitle: 'Target role, companies, package',
                              isDarkMode: isDarkMode,
                              onTap: () => _showCareerGoalsDialog(isDarkMode),
                            ),
                            _buildOptionItem(
                              icon: Icons.emoji_events_outlined,
                              title: 'Achievements',
                              subtitle:
                                  '${_achievements.length} achievements earned',
                              isDarkMode: isDarkMode,
                              onTap: () => _showAchievementsDialog(isDarkMode),
                            ),

                            const SizedBox(height: 8),

                            // Support Section
                            _buildSectionHeader('Support', isDarkMode),
                            _buildOptionItem(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              subtitle: 'FAQs, contact us',
                              isDarkMode: isDarkMode,
                              onTap: () => _showComingSoonDialog(
                                'Help & Support',
                                isDarkMode,
                              ),
                            ),
                            _buildOptionItem(
                              icon: Icons.info_outline,
                              title: 'About',
                              subtitle: 'App version, terms, privacy',
                              isDarkMode: isDarkMode,
                              onTap: () => _showAboutDialog(isDarkMode),
                            ),

                            const Divider(height: 20),

                            // Logout Button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.red.shade200,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                                leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: isDarkMode
                                      ? Colors.red.shade300
                                      : Colors.red.shade400,
                                ),
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                onTap: () => _showLogoutDialog(isDarkMode),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Version
                            Center(
                              child: Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode
                                      ? AppTheme.darkTextLight
                                      : AppTheme.lightTextLight,
                                ),
                              ),
                            ),
                          ],
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

  // Helper Widgets

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildCompactStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDarkMode,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.primaryColor.withOpacity(0.2)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 16),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: isDarkMode
                ? AppTheme.darkTextLight
                : AppTheme.lightTextLight,
          ),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
    );
  }

  // Comprehensive Edit Dialog
  void _showFullEditDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final cgpaController = TextEditingController(text: _cgpa);
    final targetRoleController = TextEditingController(text: _targetRole);
    final preferredCompaniesController = TextEditingController(
      text: _preferredCompanies,
    );
    final expectedPackageController = TextEditingController(
      text: _expectedPackage,
    );
    final skillsController = TextEditingController(text: _skillsToFocus);

    String selectedYear = _year;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
          title: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildEditSectionTitle('Personal Information', isDarkMode),
                  _buildEditField(
                    controller: nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    isDarkMode: isDarkMode,
                  ),
                  _buildEditField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 16),

                  // Academic Details
                  _buildEditSectionTitle('Academic Details', isDarkMode),

                  // Year Dropdown
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDarkMode
                            ? AppTheme.darkDivider
                            : AppTheme.lightDivider,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedYear,
                      isExpanded: true,
                      dropdownColor: isDarkMode
                          ? AppTheme.darkSurface
                          : Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(
                          color: isDarkMode
                              ? AppTheme.darkTextLight
                              : AppTheme.lightTextLight,
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _availableYears.map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(
                            year,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? AppTheme.darkText
                                  : AppTheme.lightText,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedYear = value!;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  // CGPA
                  _buildEditField(
                    controller: cgpaController,
                    label: 'CGPA',
                    icon: Icons.grade,
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    '* Degree and Branch are fixed and cannot be edited',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode
                          ? AppTheme.darkTextLight
                          : AppTheme.lightTextLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Career Goals
                  _buildEditSectionTitle('Career Goals', isDarkMode),
                  _buildEditField(
                    controller: targetRoleController,
                    label: 'Target Role',
                    icon: Icons.work,
                    isDarkMode: isDarkMode,
                  ),
                  _buildEditField(
                    controller: preferredCompaniesController,
                    label: 'Preferred Companies',
                    icon: Icons.business,
                    isDarkMode: isDarkMode,
                  ),
                  _buildEditField(
                    controller: expectedPackageController,
                    label: 'Expected Package',
                    icon: Icons.attach_money,
                    isDarkMode: isDarkMode,
                  ),
                  _buildEditField(
                    controller: skillsController,
                    label: 'Skills to Focus',
                    icon: Icons.code,
                    maxLines: 2,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userName = nameController.text;
                  _userEmail = emailController.text;
                  _year = selectedYear;
                  _cgpa = cgpaController.text;
                  _targetRole = targetRoleController.text;
                  _preferredCompanies = preferredCompaniesController.text;
                  _expectedPackage = expectedPackageController.text;
                  _skillsToFocus = skillsController.text;

                  _updateInitials();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile updated successfully!'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: isDarkMode
                        ? AppTheme.primaryColor
                        : Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for edit field
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode
                ? AppTheme.darkTextLight
                : AppTheme.lightTextLight,
          ),
          prefixIcon: Icon(icon, size: 20, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDarkMode ? AppTheme.darkDivider : AppTheme.lightDivider,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDarkMode ? AppTheme.darkDivider : AppTheme.lightDivider,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Helper method for section titles in edit dialog
  Widget _buildEditSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppTheme.darkText : AppTheme.primaryColor,
        ),
      ),
    );
  }

  // Update user initials based on name
  void _updateInitials() {
    if (_userName.isEmpty) {
      _userInitials = 'U';
    } else {
      List<String> nameParts = _userName.trim().split(' ');
      if (nameParts.length >= 2) {
        _userInitials = nameParts[0][0] + nameParts[1][0];
      } else {
        _userInitials = _userName[0].toUpperCase();
      }
    }
  }

  // Dialog Methods

  void _showPersonalInfoDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', _userName, isDarkMode),
            _buildInfoRow('Email', _userEmail, isDarkMode),
            _buildInfoRow('Member Since', _memberSince, isDarkMode),
            _buildInfoRow(
              'Verification',
              _isVerified ? 'Verified ✓' : 'Not Verified',
              isDarkMode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFullEditDialog();
            },
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcademicDetailsDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Academic Details',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Degree', _degree, isDarkMode),
            _buildInfoRow('Branch', _branch, isDarkMode),
            _buildInfoRow('Year', _year, isDarkMode),
            _buildInfoRow('CGPA', _cgpa, isDarkMode),
            const SizedBox(height: 8),
            Text(
              '* Degree and Branch are fixed and cannot be edited',
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFullEditDialog();
            },
            child: const Text(
              'Edit Year/CGPA',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showCareerGoalsDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Career Goals',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Target Role', _targetRole, isDarkMode),
            _buildInfoRow(
              'Preferred Companies',
              _preferredCompanies,
              isDarkMode,
            ),
            _buildInfoRow('Expected Package', _expectedPackage, isDarkMode),
            _buildInfoRow('Skills to Focus', _skillsToFocus, isDarkMode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFullEditDialog();
            },
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Achievements',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    title: Text(
                      _achievements[index]['title']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                      ),
                    ),
                    subtitle: Text(
                      _achievements[index]['date']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? AppTheme.darkTextLight
                            : AppTheme.lightTextLight,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      color: isDarkMode
                          ? AppTheme.darkTextLight
                          : AppTheme.lightTextLight,
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditAchievementDialog(index, isDarkMode);
                      },
                    ),
                    dense: true,
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddAchievementDialog(isDarkMode);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Achievement',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAchievementDialog(int index, bool isDarkMode) {
    final titleController = TextEditingController(
      text: _achievements[index]['title'],
    );
    final dateController = TextEditingController(
      text: _achievements[index]['date'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Edit Achievement',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
              decoration: InputDecoration(
                labelText: 'Achievement Title',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
              decoration: InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _achievements[index]['title'] = titleController.text;
                _achievements[index]['date'] = dateController.text;
              });
              Navigator.pop(context);
              _showAchievementsDialog(isDarkMode);
            },
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAddAchievementDialog(bool isDarkMode) {
    final titleController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Add Achievement',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
              decoration: InputDecoration(
                labelText: 'Achievement Title',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateController,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
              decoration: InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(
                  color: isDarkMode
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _achievements.add({
                  'title': titleController.text,
                  'date': dateController.text,
                });
              });
              Navigator.pop(context);
              _showAchievementsDialog(isDarkMode);
            },
            child: const Text('Add', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                size: 30,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Placement Prep',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your comprehensive placement preparation companion. Track your progress, set goals, and achieve your dream job.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '© 2024 Placement Prep Team',
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          feature,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 40,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              '$feature feature is coming soon!',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppTheme.darkSurface : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              AuthService.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logged out successfully'),
                  backgroundColor: isDarkMode
                      ? AppTheme.primaryColor
                      : Colors.green,
                ),
              );
            },
            child: const Text('Logout', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
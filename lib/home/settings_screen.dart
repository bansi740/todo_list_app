import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:todo_list_app/home/profile_screen.dart';
import 'package:todo_list_app/home/stats_screen.dart';
import '../home/recently_deleted_screen.dart';
import '../home/login_screen.dart';
import '../service/account_service.dart';
import '../utils/common_widgets.dart';
import 'appearance_screen.dart';
import 'controller/expansion_controller.dart';
import 'controller/stats_controller.dart';
import 'controller/theme_controller.dart';
import 'controller/user_controller.dart';
import 'help_feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ExpansionController expansionController = Get.put(
    ExpansionController(),
  );
  final UserController userController = Get.put(UserController());
  final StatsController statsController = Get.put(StatsController());
  final ThemeController themeController = Get.find();


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;

      final backgroundColor = isDark ? black : Colors.grey[100];
      final cardColor = isDark
          ? Colors.grey.shade900.withAlpha(100) // semi-transparent dark
          : Colors.white.withAlpha(250);
      final textColor = isDark ? Colors.white : Colors.black87;

      return Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          surfaceTintColor: isDark ? Colors.black : Colors.white,
          centerTitle: true,
          title: Text(
            "Settings",
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _animatedSection(
                  0,
                  Column(
                    children: [
                      _sectionTitle("Profile", isDark),
                      _buildCard(
                        cardColor,
                        isDark,
                        _buildProfile(context, textColor, isDark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                _animatedSection(
                  0,
                  Column(
                    children: [
                      _sectionTitle("Insights", isDark),
                      _buildCard(
                        cardColor,
                        isDark,
                        _buildInsights(context, textColor, isDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                _animatedSection(
                  1,
                  Column(
                    children: [
                      _sectionTitle("General", isDark),
                      _buildCard(
                        cardColor,
                        isDark,
                        Column(
                          children: [
                            _buildAppearance(context, textColor, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildRecentlyDeleted(context, textColor, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildHelpFeedback(context, textColor, isDark),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                _animatedSection(
                  2,
                  Column(
                    children: [
                      _sectionTitle("Advanced", isDark),
                      _buildCard(
                        cardColor,
                        isDark,
                        Column(
                          children: [
                            _buildCloudSync(textColor, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildNotifications(textColor, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildStorage(textColor, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildSecurity(context, textColor, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                _animatedSection(
                  3,
                  Column(
                    children: [
                      _sectionTitle("Account", isDark),
                      _buildCard(
                        cardColor,
                        isDark,
                        Column(
                          children: [
                            _buildLogout(context, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildChangePassword(context, isDark),
                            const CommonDivider(startIndent: 20),
                            _buildDeleteAccount(context, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // icon style
  Widget buildSettingsIcon({
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(35) : color.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // CARD
  Widget _buildCard(Color cardColor, bool isDark, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(10)
                : Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(color: cardColor, child: child),
      ),
    );
  }

  Widget _animatedSection(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (index * 120)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 60.0, end: 0.0),
      builder: (context, value, childWidget) {
        // Normalize progress (0 → 1)
        final progress = (1 - (value / 60)).clamp(0.0, 1.0);
        // Smooth easing curve applied again for better feel
        final eased = Curves.easeOutCubic.transform(progress);
        // Slight overshoot effect (subtle premium motion)
        final translateY = value * (1 - eased * 0.15);
        // Smooth opacity curve
        final opacity = eased;
        // Smooth scale animation
        final scale = 0.90 + (eased * 0.08);
        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(opacity: opacity, child: childWidget),
          ),
        );
      },
      child: child,
    );
  }

  // profile
  Widget _buildProfile(BuildContext context, Color textColor, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.person_outline,
        color: Colors.green,
        isDark: isDark,
      ),

      title: Text(
        "Profile",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        "View and manage your profile",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),

      onTap: () {
        // Change this to your profile screen
        Get.to(() => const ProfileScreen());
      },
    );
  }

  // state insights
  Widget _buildInsights(BuildContext context, Color textColor, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.bar_chart_rounded,
        color: Colors.blue,
        isDark: isDark,
      ),

      title: Text(
        "Productivity Insights",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        "View your task statistics",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),

      onTap: () {
        Get.to(() => const StatsScreen());
      },
    );
  }

  // THEME
  Widget _buildAppearance(BuildContext context, Color textColor, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.palette_outlined,
        color: Colors.blue,
        isDark: isDark,
      ),

      title: Text(
        "Appearance",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        "Theme mode settings",
        style: TextStyle(color: Colors.grey.shade500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),

      onTap: () {
        Get.to(() => const AppearanceScreen());
      },
    );
  }

  // RECENTLY DELETED
  Widget _buildRecentlyDeleted(
    BuildContext context,
    Color textColor,
    bool isDark,
  ) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.delete_outline,
        color: Colors.red,
        isDark: isDark,
      ),
      title: Text(
        "Recently Deleted",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        "View and restore deleted items",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),

      onTap: () => Get.to(() => const RecentlyDeletedScreen()),
    );
  }

  // HELP & FEEDBACK
  Widget _buildHelpFeedback(
    BuildContext context,
    Color textColor,
    bool isDark,
  ) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.help_outline,
        color: Colors.green,
        isDark: isDark,
      ),
      title: Text(
        "Help & Feedback",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),

      subtitle: Text(
        "Get support or share your feedback",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      onTap: () => Get.to(() => const HelpFeedbackScreen()),
    );
  }

  // LOGOUT
  Widget _buildLogout(BuildContext context, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.logout,
        color: Colors.orange,
        isDark: isDark,
      ),
      title: const Text(
        "Logout",
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.orange),
      ),
      subtitle: Text(
        "Sign out from your account",
        style: TextStyle(color: Colors.grey.shade500),
      ),
      onTap: () {
        _showLogoutDialog(context);
      },
    );
  }

  // LOGOUT CONFIRMATION DIALOG
  void _showLogoutDialog(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),

      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
            ),

            backgroundColor: isDark
                ? Colors.black.withAlpha(200)
                : Colors.white,

            titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            actionsPadding: const EdgeInsets.only(bottom: 20),

            title: Center(
              child: Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            content: Text(
              "Are you sure you want to logout?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),

            actionsAlignment: MainAxisAlignment.center,

            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => const LoginScreen());
                    },

                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildCloudSync(Color textColor, bool isDark) {
    return SmoothExpansionTile(
      index: 0,
      textColor: textColor,
      isDark: isDark,
      title: "Cloud Sync",

      leading: buildSettingsIcon(
        icon: Icons.cloud_sync_outlined,
        color: Colors.teal,
        isDark: isDark,
      ),

      children: [
        CommonDivider(startIndent: 15, endIndent: 20),
        ListTile(
          title: Text("Off", style: TextStyle(color: textColor)),
          subtitle: Text(
            "Cloud sync disabled",
            style: TextStyle(color: Colors.grey.shade500),
          ),

          trailing: const Icon(Icons.check, color: Colors.blue),
        ),

        CommonDivider(startIndent: 15, endIndent: 20),

        ListTile(
          title: Text("Manual", style: TextStyle(color: textColor)),
          subtitle: Text(
            "Sync manually when needed",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),

        CommonDivider(startIndent: 15, endIndent: 20),

        ListTile(
          title: Text("Auto", style: TextStyle(color: textColor)),
          subtitle: Text(
            "Automatically sync changes",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildNotifications(Color textColor, bool isDark) {
    return SmoothExpansionTile(
      index: 1,
      textColor: textColor,
      isDark: isDark,
      title: "Notifications",
      leading: buildSettingsIcon(
        icon: Icons.notifications_outlined,
        color: Colors.deepPurple,
        isDark: isDark,
      ),
      children: [
        CommonDivider(startIndent: 15, endIndent: 20),

        SwitchListTile(
          title: Text("Push Notifications", style: TextStyle(color: textColor)),
          subtitle: const Text("Receive app notifications"),
          value: true,
          onChanged: (value) {},
        ),

        CommonDivider(startIndent: 15, endIndent: 20),

        SwitchListTile(
          title: Text("Email Reminders", style: TextStyle(color: textColor)),
          subtitle: const Text("Receive email reminders"),
          value: false,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildStorage(Color textColor, bool isDark) {
    return SmoothExpansionTile(
      index: 2,
      textColor: textColor,
      isDark: isDark,
      title: "Storage",
      leading: buildSettingsIcon(
        icon: Icons.storage_outlined,
        color: Colors.teal,
        isDark: isDark,
      ),
      children: [
        CommonDivider(startIndent: 15, endIndent: 20),

        ListTile(
          title: Text("Clear Cache", style: TextStyle(color: textColor)),
          subtitle: Text(
            "Remove temporary app files",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),

        CommonDivider(startIndent: 15, endIndent: 20),

        ListTile(
          title: Text("Manage Storage", style: TextStyle(color: textColor)),
          subtitle: Text(
            "Check and manage app storage",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurity(BuildContext context, Color textColor, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.security,
        color: Colors.purple,
        isDark: isDark,
      ),
      title: Text(
        "Security",
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        "PIN & Biometric settings",
        style: TextStyle(color: Colors.grey.shade500),
      ),
      onTap: () {
      },
    );
  }

  // Change PASSWORD
  Widget _buildChangePassword(BuildContext context, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.lock_reset,
        color: Colors.blue,
        isDark: isDark,
      ),

      title: Text(
        "Change Password",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
        ),
      ),

      subtitle: Text(
        "Update your account password",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      onTap: () => _showChangePasswordDialog(context, isDark),
    );
  }

  // Delete account
  Widget _buildDeleteAccount(BuildContext context, bool isDark) {
    return ListTile(
      leading: buildSettingsIcon(
        icon: Icons.delete_forever,
        color: Colors.red,
        isDark: isDark,
      ),

      title: const Text(
        "Delete Account",
        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
      ),

      subtitle: Text(
        "Permanently remove your account and data",
        style: TextStyle(color: Colors.grey.shade500),
      ),

      onTap: () => _showDeleteDialog(context, isDark),
    );
  }
}

class CommonDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double startIndent;
  final double endIndent;

  const CommonDivider({
    super.key,
    this.height = 1,
    this.color,
    this.startIndent = 0,
    this.endIndent = 25,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: height,
      color: isDark ? Colors.grey.withAlpha(70) : Colors.grey.withAlpha(120),
      thickness: height,
      indent: startIndent,
      endIndent: endIndent,
    );
  }
}

void _showChangePasswordDialog(BuildContext context, bool isDark) {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Change Password",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      final viewInsets = MediaQuery.of(context).viewInsets;
      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black54.withAlpha(220)
                    : Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  _buildModernPasswordField(
                    "Current Password",
                    currentController,
                    isDark,
                  ),
                  const SizedBox(height: 5),
                  _buildModernPasswordField(
                    "New Password",
                    newController,
                    isDark,
                  ),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      newController,
                      confirmController,
                    ]),
                    builder: (context, _) {
                      final newPass = newController.text.trim();
                      final confirmPass = confirmController.text.trim();
                      bool isMatch =
                          confirmPass.isNotEmpty && newPass == confirmPass;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernPasswordField(
                            "Confirm New Password",
                            confirmController,
                            isDark,
                          ),
                          const SizedBox(height: 6),
                          if (confirmPass.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  isMatch ? Icons.check_circle : Icons.error,
                                  size: 18,
                                  color: isMatch ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isMatch
                                      ? "Passwords match"
                                      : "Passwords do not match",
                                  style: TextStyle(
                                    color: isMatch ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.deepOrange
                              : Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final current = currentController.text.trim();
                          final newPass = newController.text.trim();
                          final confirm = confirmController.text.trim();

                          if (current.isEmpty ||
                              newPass.isEmpty ||
                              confirm.isEmpty) {
                            toast("All fields are required");
                            return;
                          }

                          if (newPass != confirm) {
                            toast("New password and confirmation do not match");
                            return;
                          }

                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null || user.email == null) {
                            toast("No user found");
                            return;
                          }

                          try {
                            final cred = EmailAuthProvider.credential(
                              email: user.email!,
                              password: current,
                            );
                            // Re-authenticate
                            await user.reauthenticateWithCredential(cred);
                            // Update password
                            await user.updatePassword(newPass);

                            toast("Password updated successfully");
                            // Optional: Sign out user after password change
                            await FirebaseAuth.instance.signOut();

                            // Navigate to login screen and remove previous routes
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => false, // remove all previous routes
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'wrong-password') {
                              toast("Current password is incorrect");
                            } else {
                              toast("Error: ${e.message}");
                            }
                          }
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

Widget _buildModernPasswordField(
  String label,
  TextEditingController controller,
  bool isDark,
) {
  // Use RxBool to toggle visibility
  final obscureText = true.obs;
  return Obx(
    () => Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withAlpha(150)
            : Colors.grey.shade200.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(50)
                : Colors.grey.withAlpha(50),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText.value,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: isDark ? Colors.white : Colors.black87,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.black.withAlpha(80)
              : Colors.white.withAlpha(255),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText.value ? Icons.visibility_off : Icons.visibility,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
            onPressed: () {
              obscureText.value = !obscureText.value;
            },
          ),
        ),
      ),
    ),
  );
}

// delete showDeleteDialog
void _showDeleteDialog(BuildContext context, bool isDark) {
  final passwordController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete Account",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),

    pageBuilder: (context, animation, secondaryAnimation) {
      final viewInsets = MediaQuery.of(context).viewInsets;

      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.83,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withAlpha(235)
                    : Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.red.withAlpha(40),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // TITLE
                  Text(
                    "Delete Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),
                  // DESCRIPTION
                  Text(
                    "This action is permanent.\nEnter your password to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 18),
                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      filled: true,
                      fillColor: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final password = passwordController.text.trim();

                            if (password.isEmpty) {
                              toast("Enter password");
                              return;
                            }

                            await _handleDelete(context, password);
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
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
      );
    },

    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}

Future<void> _handleDelete(BuildContext context, String password) async {
  try {
    await AccountService.deleteAccount(password);

    toast("Account deleted permanently");

    Get.offAll(() => const LoginScreen());
  } catch (e) {
    toast(e.toString().replaceAll("Exception: ", ""));
  }
}

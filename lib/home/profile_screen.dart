import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller/theme_controller.dart';
import 'controller/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController userController = Get.put(UserController());

  void _showImagePreview(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Preview",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.black,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.white,
                ),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              alignment: Alignment.center,
              child: InteractiveViewer(
                child: const UserAvatar(radius: 150, fontSize: 80),
              ),
            ),
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

  void _showEditDialog(bool isDark) {
    final TextEditingController nameController = TextEditingController(
      text: userController.name.value,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,

          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withAlpha(230)
                    : Colors.white.withAlpha(245),

                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(30)
                      : Colors.black.withAlpha(15),
                ),

                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(140)
                        : Colors.grey.withAlpha(90),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),
                  // Subtitle
                  Text(
                    "Update your display name",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade900.withAlpha(140)
                          : Colors.grey.shade300.withAlpha(180),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withAlpha(220),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            if (newName.isNotEmpty) {
                              await userController.updateUserName(newName);
                            }
                            Get.back();
                          },
                          child: const Text(
                            "Save",
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDark
                  ? Colors.grey.shade900.withAlpha(150)
                  : Colors.white.withAlpha(230),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onLongPress: () => _showImagePreview(context),
                      child: const UserAvatar(radius: 45, fontSize: 28),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Flexible(
                            child: Text(
                              userController.name.value.isEmpty
                                  ? "User"
                                  : userController.name.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        GestureDetector(
                          onTap: () => _showEditDialog(isDark),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Obx(
                      () => Text(
                        userController.email.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // USER ID OUTSIDE CARD
            _buildInfoRow(
              context,
              icon: Icons.fingerprint,
              title: "User ID",
              value: FirebaseAuth.instance.currentUser?.uid ?? "-",
              isDark: isDark,
              isCopy: true,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  required bool isDark,
  bool isCopy = false,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.grey.shade900.withAlpha(100)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? "-" : value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),

        if (isCopy)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar("Copied", "User ID copied");
            },
          ),
      ],
    ),
  );
}

class UserAvatar extends StatelessWidget {
  final double radius;
  final double fontSize;

  const UserAvatar({super.key, this.radius = 40, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Obx(() {
      final name = userController.name.value.trim();
      final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "U";

      final bgColors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
      ];

      final colorIndex = firstLetter.codeUnitAt(0) % bgColors.length;

      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColors[colorIndex],
        child: Text(
          firstLetter,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}

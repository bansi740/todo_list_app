import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/theme_controller.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  int? tappedIndex; // 🔥 for tap animation

  @override
  Widget build(BuildContext context) {
    final ThemeController controller = Get.find();

    return Obx(() {
      final mode = controller.themeMode.value;
      final isDark = controller.isDarkMode;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Appearance"),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(isDark),
              const SizedBox(height: 16),

              _modernTile(
                index: 0,
                title: "Light Mode",
                icon: Icons.wb_sunny_rounded,
                subtitle: "Bright, clean and minimal",
                selected: mode == ThemeMode.light,
                onTap: () => controller.changeTheme(ThemeMode.light),
                isDark: isDark,
                selectedColor: Colors.orange,
              ),

              _modernTile(
                index: 1,
                title: "Dark Mode",
                icon: Icons.nights_stay_rounded,
                subtitle: "Soft dark interface for night",
                selected: mode == ThemeMode.dark,
                onTap: () => controller.changeTheme(ThemeMode.dark),
                isDark: isDark,
                selectedColor: Colors.deepPurple,
              ),

              _modernTile(
                index: 2,
                title: "System Default",
                icon: Icons.phone_android_rounded,
                subtitle: "Matches your device settings",
                selected: mode == ThemeMode.system,
                onTap: () => controller.changeTheme(ThemeMode.system),
                isDark: isDark,
                selectedColor: Colors.blue,
              ),

              const SizedBox(height: 20),
              _infoCard(isDark),
            ],
          ),
        ),
      );
    });
  }

  // Header
  Widget _header(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personalize your experience",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Choose how the app looks and feels",
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  // Info Card
  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withAlpha(12) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(25)
              : Colors.grey.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Theme updates are applied instantly across the app.",
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MODERN TILE WITH FULL ANIMATION
  Widget _modernTile({
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required String subtitle,
    required bool isDark,
    required Color selectedColor,
  }) {
    final baseColor =
    isDark ? Colors.white.withAlpha(12) : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() => tappedIndex = index);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => tappedIndex = null);
        });

        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          gradient: selected
              ? LinearGradient(
            colors: [
              selectedColor.withAlpha(220),
              selectedColor.withAlpha(120),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,

          color: selected ? null : baseColor,

          border: Border.all(
            color: selected
                ? selectedColor.withAlpha(220)
                : Colors.grey.withAlpha(60),
            width: selected ? 1.6 : 1,
          ),

          boxShadow: [
            if (selected)
              BoxShadow(
                color: selectedColor.withAlpha(70),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            else if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // 🔥 ICON ANIMATION
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withAlpha(40)
                    : Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut,
                scale: tappedIndex == index
                    ? 1.3
                    : (selected ? 1.15 : 1.0),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 350),
                  turns: tappedIndex == index ? 0.15 : 0.0,
                  child: Icon(
                    icon,
                    color: selected
                        ? Colors.white
                        : (isDark
                        ? Colors.white70
                        : Colors.black54),
                    size: 26,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (isDark
                          ? Colors.white
                          : Colors.black87),
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: selected
                          ? Colors.white70
                          : (isDark
                          ? Colors.white60
                          : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),

            // 🔥 CHECK ANIMATION
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.white.withAlpha(220)
                    : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: selected
                    ? Icon(
                  Icons.check,
                  key: const ValueKey("check"),
                  size: 16,
                  color: selectedColor,
                )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
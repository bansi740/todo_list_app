import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/controller/home_controller.dart';
import '../home/controller/theme_controller.dart';
import 'assets.dart';

class SortMenuButton extends StatelessWidget {
  const SortMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final ThemeController themeController = Get.find();
    final isDark = themeController.isDarkMode;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 55),
        icon: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.grey.shade100.withAlpha(70),
            borderRadius: BorderRadius.circular(10), // slightly tighter
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.sort,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        color: isDark ? Colors.grey.shade900.withAlpha(220) : Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white.withAlpha(30) : Colors.grey.shade300,
          ),
        ),
        onSelected: (value) {
          if (value == 'title') {
            controller.setSortType(SortType.title);
          }
          if (value == 'date') {
            controller.setSortType(SortType.date);
          }
          if (value == 'asc') {
            controller.setSortOrder('asc');
          }
          if (value == 'desc') {
            controller.setSortOrder('desc');
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            height: 24,
            child: Text(
              "SORT BY",
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuItem(
            value: 'title',
            child: Row(
              children: [
                Image.asset(
                  isDark ? AssetsPath.titleDarkIcon : AssetsPath.titleIcon,
                  height: 20,
                  width: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text("Title")),
                if (controller.sortType.value == SortType.title)
                  const Icon(Icons.check, size: 18, color: Colors.blue),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'date',
            child: Row(
              children: [
                Image.asset(
                  isDark ? AssetsPath.dateDarkIcon : AssetsPath.dateIcon,
                  height: 20,
                  width: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text("Date")),
                if (controller.sortType.value == SortType.date)
                  const Icon(Icons.check, size: 18, color: Colors.blue),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            enabled: false,
            height: 20,
            child: Text(
              "ORDER",
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PopupMenuItem(
            value: 'asc',
            child: Row(
              children: [
                const Icon(Icons.arrow_upward, size: 18),
                const SizedBox(width: 12),
                const Expanded(child: Text("Ascending")),
                if (controller.sortOrder.value == 'asc')
                  const Icon(Icons.check, size: 18, color: Colors.blue),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'desc',
            child: Row(
              children: [
                const Icon(Icons.arrow_downward, size: 18),
                const SizedBox(width: 12),
                const Expanded(child: Text("Descending")),
                if (controller.sortOrder.value == 'desc')
                  const Icon(Icons.check, size: 18, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
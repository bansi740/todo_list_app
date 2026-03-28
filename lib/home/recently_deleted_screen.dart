import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/home/controller/home_controller.dart';
import 'package:todo_list_app/home/todo_list_database/todo_list_model.dart';
import 'package:todo_list_app/home/todo_list_database/todo_firestore_service.dart';
import 'package:todo_list_app/utils/assets.dart';
import 'controller/theme_controller.dart';

class RecentlyDeletedScreen extends StatefulWidget {
  const RecentlyDeletedScreen({super.key});

  @override
  State<RecentlyDeletedScreen> createState() => _RecentlyDeletedScreenState();
}

class _RecentlyDeletedScreenState extends State<RecentlyDeletedScreen> {
  final controller = Get.find<HomeController>();
  final themeController = Get.find<ThemeController>();

  final selectedIds = <String>[].obs;
  final isSelectionMode = false.obs;

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    isSelectionMode.value = selectedIds.isNotEmpty;
  }

  void restoreSelected() {
    for (var id in selectedIds) {
      controller.restoreTodo(id);
    }
    selectedIds.clear();
    isSelectionMode.value = false;
  }

  void deleteSelected() {
    for (var id in selectedIds) {
      controller.permanentDelete(id);
    }
    selectedIds.clear();
    isSelectionMode.value = false;
  }

  void selectAllToggle(List<Todo> todos) {
    if (selectedIds.length == todos.length) {
      selectedIds.clear();
    } else {
      selectedIds.assignAll(todos.map((e) => e.id!));
      if (!isSelectionMode.value) isSelectionMode.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeController.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final restoreColor = isDark ? Colors.green.shade700 : Colors.green.shade400;
    final deleteColor = isDark ? Colors.red.shade700 : Colors.red.shade400;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Obx(
          () => Text(
            isSelectionMode.value
                ? "${selectedIds.length} Selected"
                : "Recently Deleted",
            style: TextStyle(color: textColor),
          ),
        ),
        actions: [
          if (isSelectionMode.value)
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: () {
                selectedIds.clear();
                isSelectionMode.value = false;
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Todo>>(
        stream: TodoFirestoreService.streamDeletedTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final deletedTodos = snapshot.data ?? [];
          if (deletedTodos.isEmpty) {
            return Center(
              child: Text(
                "No Deleted Tasks",
                style: TextStyle(color: subtitleColor, fontSize: 16),
              ),
            );
          }

          return Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                // detect taps on empty space
                onTap: () {
                  if (isSelectionMode.value) {
                    selectedIds.clear();
                    isSelectionMode.value = false;
                  }
                },
                child: ListView.builder(
                  itemCount: deletedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = deletedTodos[index];
                    return Obx(() {
                      final selected = selectedIds.contains(todo.id);

                      return GestureDetector(
                        onLongPress: () => toggleSelection(todo.id!),
                        onTap: () {
                          if (isSelectionMode.value) toggleSelection(todo.id!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? (isDark
                                      ? Colors.grey.shade900.withAlpha(70)
                                      : Colors.blue.shade50.withAlpha(180))
                                : (isDark
                                      ? Colors.grey.shade900.withAlpha(70)
                                      : Colors.white.withAlpha(150)),
                            borderRadius: BorderRadius.circular(22),

                            border: Border.all(
                              color: selected
                                  ? (isDark ? Colors.blueAccent : Colors.blue)
                                  : (isDark ? Colors.white10 : Colors.black12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ?isSelectionMode.value
                                    ? Checkbox(
                                        value: selected,
                                        onChanged: (_) =>
                                            toggleSelection(todo.id!),
                                        activeColor: isDark
                                            ? Colors.green.shade700
                                            : Colors.green.shade400,
                                      )
                                    : null,
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),

                                      if ((todo.description ?? '').isNotEmpty)
                                        Text(
                                          todo.description ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: subtitleColor,
                                          ),
                                        ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${todo.formattedDate} • ${todo.timeAgo}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: subtitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!isSelectionMode.value)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? Colors.green.shade300.withAlpha(
                                                  15,
                                                )
                                              : Colors.green.shade100,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.grey.shade500
                                                      .withAlpha(50)
                                                : Colors.black.withAlpha(40),
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            AssetsPath.restoreIcon,
                                            width: 24,
                                            height: 24,
                                            color: isDark
                                                ? Colors.greenAccent.shade400
                                                : Colors.green.shade700,
                                          ),
                                          onPressed: () =>
                                              controller.restoreTodo(todo.id!),
                                        ),
                                      ),

                                      const SizedBox(width: 6),

                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? Colors.red.shade800.withAlpha(
                                                  15,
                                                )
                                              : Colors.red.shade200.withAlpha(
                                                  150,
                                                ),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.grey.shade500
                                                      .withAlpha(50)
                                                : Colors.black.withAlpha(40),
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Image.asset(
                                            AssetsPath.removeIcon,
                                            width: 22,
                                            height: 22,
                                            color: isDark
                                                ? Colors.redAccent.shade200
                                                : Colors.red.shade700,
                                          ),
                                          onPressed: () => controller
                                              .permanentDelete(todo.id!),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              // Bottom action bar
              Obx(
                () => AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: isSelectionMode.value ? 0 : -70,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: restoreSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: restoreColor,
                          ),
                          child: Text(
                            "Restore",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: deleteSelected,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deleteColor,
                          ),
                          child: Text(
                            "Delete",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => selectAllToggle(deletedTodos),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                          child: Obx(
                            () => Text(
                              selectedIds.length == deletedTodos.length
                                  ? "Unselect All"
                                  : "Select All",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:todo_list_app/home/controller/home_controller.dart';
import 'package:todo_list_app/utils/app_string.dart';
import 'package:todo_list_app/utils/common_widgets.dart';
import '../home/todo_list_database/todo_list_model.dart';

class AddTaskDialog extends StatefulWidget {
  final Todo? todo;
  final bool showStatusSegment;

  const AddTaskDialog({super.key, this.todo, this.showStatusSegment = true});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController tagsController;

  final HomeController homeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  List<String> selectedTags = [];

  late bool isDone;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.todo?.title ?? '');
    descController = TextEditingController(
      text: widget.todo?.description ?? '',
    );

    isDone = widget.todo?.isDone == true;
    homeController.isDoneSelected.value = isDone;
    tagsController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogHeight = widget.showStatusSegment
        ? MediaQuery.of(context).size.height * 0.57
        : MediaQuery.of(context).size.height * 0.45;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        height: dialogHeight,
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withAlpha(225) : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                isEditing ? "Edit Task" : AppString.addTask,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              6.height,

              Text(
                isEditing
                    ? "Update your task details"
                    : "Create a new task with title & description",
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              28.height,

              TodoTextField(
                controller: titleController,
                label: AppString.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Title is required";
                  }
                  return null;
                },
              ),

              18.height,

              TodoTextField(controller: descController, label: AppString.desc),

              18.height,

              // Segmented Toggle
              if (widget.showStatusSegment)
                Obx(() {
                  final isDone = homeController.isDoneSelected.value;

                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 6) {
                        HapticFeedback.heavyImpact();
                        homeController.selectDone();
                      } else if (details.delta.dx < -6) {
                        HapticFeedback.heavyImpact();
                        homeController.selectNotDone();
                      }
                    },
                    child: Container(
                      height: 52,
                      width: 230,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: isDark
                            ? Colors.white.withAlpha(15)
                            : Colors.black.withAlpha(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(25)
                              : Colors.black.withAlpha(10),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Ultra Smooth Sliding Pill
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 180), // ⚡ faster
                            curve: Curves.easeOutCubic,
                            alignment:
                            isDone ? Alignment.centerLeft : Alignment.centerRight,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 110,
                              height: 44,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: isDark
                                    ? const LinearGradient(
                                  colors: [Color(0xff4A4A4A), Color(0xff2A2A2A)],
                                )
                                    : const LinearGradient(
                                  colors: [Colors.white, Color(0xffF5F5F5)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Buttons Row
                          Row(
                            children: [
                              _modernTab(
                                title: AppString.done,
                                isActive: isDone,
                                onTap: homeController.selectDone,
                                isDark: isDark,
                              ),
                              _modernTab(
                                title: AppString.notDone,
                                isActive: !isDone,
                                onTap: homeController.selectNotDone,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  );
                }),

              if (widget.showStatusSegment) 18.height,

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: isDark
                            ? const Color(0xff2A2A2A)
                            : Colors.grey.shade100,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppString.cancel,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  14.width,

                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                //  Close dialog FIRST (fast UI response)
                                Get.back();
                                if (isEditing) {
                                  widget.todo!.title = titleController.text
                                      .trim();
                                  widget.todo!.description = descController.text
                                      .trim();
                                  widget.todo!.isDone =
                                      homeController.isDoneSelected.value;

                                  await homeController.updateTodoHybrid(
                                    widget.todo!,
                                  );
                                } else {
                                  await homeController.addTodoHybrid(
                                    titleController.text.trim(),
                                    descController.text.trim(),
                                    isDone: homeController.isDoneSelected.value,
                                  );
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                          child: Center(
                            child: Text(
                              isEditing ? AppString.save : AppString.addTask,
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }
  Widget _modernTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque, // ⚡ better tap response
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: isActive ? 1.05 : 1.0, // subtle pop
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: isActive ? 15.5 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.grey,
              ),
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:todo_list_app/utils/assets.dart';

import '../home/controller/expansion_controller.dart';
import '../home/controller/home_controller.dart';
import '../home/todo_list_database/todo_list_model.dart';
import '../home/todo_list_screen.dart';
import 'add_task_dialog.dart';
import 'app_string.dart';

class TodoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isPassword;
  final FocusNode? focusNode;



  const TodoTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.isPassword = false, this.focusNode,
  });

  @override
  State<TodoTextField> createState() => _TodoTextFieldState();
}

class _TodoTextFieldState extends State<TodoTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? _obscureText : false,
      style: TextStyle(
        color: isDark ? Colors.white.withAlpha(220) : Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70.withAlpha(200) : Colors.grey.shade700,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white.withAlpha(230) : Colors.black,
          fontWeight: FontWeight.w500,
        ),

        // Eye icon only for password
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: isDark ? Colors.white70 : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        filled: true,
        fillColor: isDark
            ? Colors.grey.shade900.withAlpha(220)
            : Colors.grey.shade200.withAlpha(220),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withAlpha(180) : Colors.black,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

// list screen list
class TodoItem extends StatefulWidget {
  final Todo todo;
  final bool isDark;
  final int index;

  const TodoItem({
    super.key,
    required this.todo,
    required this.isDark,
    required this.index,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = widget.isDark ? Colors.white : Colors.black87;
    final subtitleColor = widget.isDark ? Colors.grey.shade400 : Colors.black54;

    return TapRegion(
      onTapOutside: (_) {
        if (isExpanded) {
          setState(() => isExpanded = false);
        }
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (isExpanded) setState(() => isExpanded = false);
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          setState(() => isExpanded = true);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.grey.shade900.withAlpha(100) // semi-transparent dark
                : Colors.grey.shade300.withAlpha(50),
            borderRadius: BorderRadius.circular(22),
            // subtle border
            border: Border.all(
              color: widget.isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),
                  // TITLE + DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              isDark
                                  ? AssetsPath.titleDarkIcon
                                  : AssetsPath.titleIcon,
                              height: 15,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.todo.title ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Image.asset(AssetsPath.descIcon, height: 15),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                widget.todo.description ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 1),

                        Row(
                          children: [
                            Image.asset(
                              isDark
                                  ? AssetsPath.dateDarkIcon
                                  : AssetsPath.dateIcon,
                              height: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.todo.formattedDate} ",
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // STATUS + PIN
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await controller.togglePin(widget.todo);
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            widget.todo.isPinned == true
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            key: ValueKey(widget.todo.isPinned),
                            color: widget.todo.isPinned == true
                                ? Colors.orange
                                : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () async {
                          widget.todo.isDone = widget.todo.isDone == true
                              ? false
                              : true;
                          await controller.updateTodo(widget.todo);
                        },
                        child: TodoStatusPill(
                          isDone: widget.todo.isDone == true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // EXPAND AREA
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Image.asset(
                                    AssetsPath.editIcon,
                                    height: 18,
                                  ),
                                  label: const Text(
                                    AppString.edit,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AddTaskDialog(
                                        todo: widget.todo,
                                        showStatusSegment: false,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Image.asset(
                                    AssetsPath.removeIcon,
                                    height: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    AppString.delete,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: TweenAnimationBuilder<double>(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                            tween: Tween(begin: 0.85, end: 1.05),
                                            builder: (context, scale, child) {
                                              return Opacity(
                                                opacity: scale.clamp(0, 1), // fade effect
                                                child: Transform.scale(
                                                  scale: scale,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 190,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(24),
                                                color: isDark
                                                    ? const Color(0xff1E1E1E).withAlpha(220)
                                                    : Colors.white.withAlpha(235),
                                                border: Border.all(
                                                  color: isDark
                                                      ? Colors.white.withAlpha(20)
                                                      : Colors.black.withAlpha(10),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withAlpha(40),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Icon
                                                    Container(
                                                      height: 72,
                                                      width: 72,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Colors.red.withAlpha(120),
                                                            Colors.red.withAlpha(40),
                                                          ],
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.delete_outline_rounded,
                                                        color: Colors.red,
                                                        size: 34,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    Text(
                                                      "Delete Task",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.3,
                                                        color: isDark ? Colors.white : Colors.black,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 10),

                                                    Text(
                                                      "Are you sure you want to delete this task?\nThis action cannot be undone.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14.5,
                                                        height: 1.5,
                                                        color: isDark
                                                            ? Colors.white.withAlpha(180)
                                                            : Colors.black.withAlpha(180),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 26),

                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            style: OutlinedButton.styleFrom(
                                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                                              side: BorderSide(
                                                                color: isDark
                                                                    ? Colors.white.withAlpha(30)
                                                                    : Colors.black.withAlpha(20),
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(14),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              AppString.cancel,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                color: isDark
                                                                    ? Colors.white.withAlpha(200)
                                                                    : Colors.black.withAlpha(200),
                                                              ),
                                                            ),
                                                          ),
                                                        ),

                                                        const SizedBox(width: 12),

                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red.withAlpha(220),
                                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(14),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              AppString.delete,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.white,
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
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      await controller.deleteTodo(
                                        widget.todo.id!,
                                      );

                                      showCustomSnackbar(
                                        message: AppString.todoHas,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// done and undone text
class TodoStatusPill extends StatelessWidget {
  final bool isDone;

  const TodoStatusPill({super.key, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color doneColor = const Color(0xFF16A34A);
    final Color pendingColor = const Color(0xFFF97316);

    final Color baseColor = isDone ? doneColor : pendingColor;

    final String label = isDone ? AppString.done : AppString.notDone;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? baseColor.withAlpha(30)
            : baseColor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withAlpha(70),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check : Icons.access_time,
            size: 12,
            color: baseColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}

// setting page in
class SmoothExpansionTile extends StatefulWidget {
  final int index;
  final Widget leading;
  final String title;
  final List<Widget> children;
  final Color textColor;
  final bool isDark;

  const SmoothExpansionTile({
    super.key,
    required this.index,
    required this.leading,
    required this.title,
    required this.children,
    required this.textColor,
    required this.isDark,
  });

  @override
  State<SmoothExpansionTile> createState() => _SmoothExpansionTileState();
}

class _SmoothExpansionTileState extends State<SmoothExpansionTile> {
  final ExpansionController controller = Get.find<ExpansionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.openIndex.value == widget.index;

      return Column(
        children: [
          ListTile(
            leading: widget.leading,
            title: Text(
              widget.title,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),

            // STAR ICON WITH ANIMATION
            trailing: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isExpanded ? 1 : 0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(
                      Colors.transparent,
                      widget.isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.blue.withAlpha(25),
                      value,
                    ),
                  ),
                  child: Transform.rotate(
                    angle: value * 3.1416, // smooth 180° rotation
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,size: 24,
                      color: Color.lerp(
                        widget.textColor,
                        widget.isDark ? Colors.white60 : Colors.blue,
                        value,
                      ),
                    ),
                  ),
                );
              },
            ),

            onTap: () => controller.toggle(widget.index),
          ),
          // EXPAND AREA
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 0),
              child: Column(children: widget.children),
            ),
          ),
        ],
      );
    });
  }
}

// list screen in list animation
class TodoItemAnimation extends StatelessWidget {
  final Widget child;
  final int index;

  const TodoItemAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 260 + (index * 12)),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - value)),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}


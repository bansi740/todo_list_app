import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/home/controller/home_controller.dart';
import 'package:todo_list_app/home/profile_screen.dart';
import 'package:todo_list_app/home/settings_screen.dart';
import 'package:todo_list_app/home/todo_list_database/todo_firestore_service.dart';
import 'package:todo_list_app/home/todo_list_database/todo_list_model.dart';
import 'package:todo_list_app/utils/add_task_dialog.dart';
import 'package:todo_list_app/utils/app_string.dart';
import 'package:todo_list_app/utils/assets.dart';
import '../utils/common_widgets.dart';
import '../utils/sort_menu_button.dart';
import 'controller/theme_controller.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final HomeController controller = Get.put(HomeController());
  final ThemeController themeController = Get.put(ThemeController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // <-- add this
  RxBool showFab = true.obs;

  // Chip selected index: 0 = All, 1 = Done, 2 = Not Done
  RxInt selectedFilter = 0.obs;
  final PageController pageController = PageController();

  final List<String> filterLabels = [
    AppString.all,
    AppString.done,
    AppString.notDone,
    AppString.pinned,
  ];

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // if list can't scroll → always show FAB
      if (!_scrollController.hasClients ||
          !_scrollController.position.hasContentDimensions ||
          _scrollController.position.maxScrollExtent == 0) {
        showFab.value = true;
        return;
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        showFab.value = false; // scrolling down → hide
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        showFab.value = true; // scrolling up → show
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode;
      final textColor = isDark ? Colors.white.withAlpha(250) : Colors.black87;
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: isDark ? Colors.black : Colors.white,
            surfaceTintColor: isDark ? Colors.black : Colors.white,
            title: GestureDetector(
              onTap: () {
                _scrollToTop();
              },
              child: Text(
                AppString.myTask,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
            actionsPadding: const EdgeInsets.only(right: 15),
            actions: [
              GestureDetector(
                onDoubleTap: () {
                  Get.to(() => ProfileScreen());
                },
                child: IconButton(
                  icon: Icon(Icons.settings, color: textColor),
                  onPressed: () {
                    // Navigate directly to SettingsScreen
                    Get.to(() => const SettingsScreen());
                  },
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: StreamBuilder<List<Todo>>(
              stream: TodoFirestoreService.streamTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitFadingCircle(color: Colors.blue, size: 35.0),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final rawTodos = snapshot.data ?? [];

                return Column(
                  children: [
                    // SEARCH + FILTER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SEARCH
                          Row(
                            children: [
                              Obx(
                                () => Expanded(
                                  child: Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey.shade900.withAlpha(100)
                                          : Colors.grey.shade100.withAlpha(70),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      onChanged: controller.updateSearch,
                                      cursorColor: isDark
                                          ? Colors.grey.shade300.withAlpha(170)
                                          : Colors.grey,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 14, // slightly smaller
                                      ),
                                      decoration: InputDecoration(
                                        hintText: AppString.searchTask,
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? Colors.grey.shade500
                                              : Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          size: 20,
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.black54,
                                        ),
                                        suffixIcon:
                                            controller
                                                .searchQuery
                                                .value
                                                .isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.close_rounded,
                                                  size: 18,
                                                  color: isDark
                                                      ? Colors.grey
                                                      : Colors.black54,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  controller.updateSearch('');
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 11,
                                              horizontal: 0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // SORT
                              Align(
                                alignment: Alignment.centerRight,
                                child: const SortMenuButton(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // FILTER CHIPS
                          Obx(
                            () => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: List.generate(filterLabels.length, (
                                  index,
                                ) {
                                  final isSelected =
                                      selectedFilter.value == index;

                                  return GestureDetector(
                                    onTap: () => selectedFilter.value = index,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOut,
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),

                                        //  CLEAN BACKGROUND
                                        color: isSelected
                                            ? (isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.black)
                                            : Colors.transparent,

                                        //  SUBTLE BORDER
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : (isDark
                                                    ? Colors.grey.shade700
                                                    : Colors.grey.shade300),
                                        ),
                                      ),

                                      child: Text(
                                        filterLabels[index],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,

                                          //  CLEAN TEXT COLORS
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.black87),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // LIST
                    Expanded(
                      child: Obx(() {
                        final todos = controller.getFilteredTodosFromList(
                          rawTodos,
                          selectedFilter.value,
                        );

                        if (todos.isEmpty) {
                          return Center(
                            child: Text(
                              "No Task",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 15),
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            // animation for list scroll
                            return TodoItemAnimation(
                              index: index,
                              child: TodoItem(
                                todo: todo,
                                index: index,
                                isDark: themeController.isDarkMode,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: Obx(() {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              offset: showFab.value ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showFab.value ? 1 : 0,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade900.withAlpha(150)
                        : Colors.grey.shade200.withAlpha(180),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showAnimatedAddTaskDialog(context),
                      child: Center(
                        child: Image.asset(
                          AssetsPath.addTaskIcon,
                          width: 28,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

// Snackbar function
void showCustomSnackbar({
  required String message,
  Duration duration = const Duration(seconds: 1),
}) {
  final ThemeController themeController = Get.find();
  final isDark = themeController.isDarkMode;

  Fluttertoast.showToast(
    msg: message,
    // shows both title and message
    toastLength: duration.inSeconds > 2
        ? Toast.LENGTH_LONG
        : Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    // shows at the top like bubble
    backgroundColor: isDark
        ? Colors.grey.shade900.withAlpha(120)
        : Colors.grey.shade200,
    textColor: isDark ? Colors.white : Colors.black87,
    fontSize: 16.0,
    timeInSecForIosWeb: duration.inSeconds,
    webShowClose: true,
    webBgColor: isDark
        ? "#212121" // hex for dark grey
        : "#E0E0E0", // hex for light grey
  );
}

// Animated AddTaskDialog
void _showAnimatedAddTaskDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppString.addTask,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedValue = Curves.easeOutBack.transform(animation.value);
      final scale = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 0.85,
            end: 1.05,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 70,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.05,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 30,
        ),
      ]).transform(animation.value);
      final offsetY = 50 * (1 - curvedValue);
      return Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(scale: scale, child: const AddTaskDialog()),
        ),
      );
    },
  );
}

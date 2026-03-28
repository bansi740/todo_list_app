import 'package:get/get.dart';
import 'package:todo_list_app/home/todo_list_database/todo_firestore_service.dart';
import 'package:uuid/uuid.dart';
import '../../service/network_service.dart';
import '../../service/todo_hybrid_service.dart';
import '../todo_list_database/todo_list_database.dart';
import '../todo_list_database/todo_list_model.dart';

enum SortType { pin, title, date }

class HomeController extends GetxController {
  var todoList = <Todo>[].obs;
  var deletedTodoList = <Todo>[].obs;
  var isDoneSelected = false.obs;
  var searchQuery = ''.obs;
  var sortType = SortType.date.obs;
  var sortOrder = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    NetworkService().onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        // Sync unsynced todos when back online
        TodoHybridService.syncPendingTodos();
      }
    });
    fetchTodos();
    fetchDeletedTodos();
  }

  void selectDone() => isDoneSelected.value = true;

  void selectNotDone() => isDoneSelected.value = false;

  void setSortType(SortType type) {
    sortType.value = type;
  }

  void setSortOrder(String order) {
    if (order == 'asc' || order == 'desc') {
      sortOrder.value = order;
    }
  }

  // FETCH ACTIVE TODOS
  Future<void> fetchTodos() async {
    final data = await TodoHybridService.getAllTodos();
    todoList.value = data;
  }

  // FETCH DELETED TODOS
  Future<void> fetchDeletedTodos() async {
    final data = await TodoDatabase.instance.getDeletedTodos();
    deletedTodoList.value = data;
  }

  // hybrid add
  Future<void> addTodoHybrid(
    String title,
    String description, {
    bool isDone = false,
  }) async {
    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      isDone: isDone,
      isDeleted: false,
      isPinned: false,
      createdAt: DateTime.now(),
    );

    await TodoHybridService.addTodo(todo);

    // Refresh UI
    await loadTodos();
  }

  // hybrid load todos
  Future<void> loadTodos() async {
    final todos = await TodoHybridService.getAllTodos();
    todoList.value = todos;
  }

  // updated hybrid todos
  Future<void> updateTodoHybrid(Todo todo) async {
    await TodoHybridService.updateTodo(todo);

    // Refresh UI
    await loadTodos();
  }

  // ADD
  Future<void> addTodo(String title, String description) async {
    final now = DateTime.now();

    final todo = Todo(
      id: const Uuid().v4(),
      // offline ID
      title: title,
      description: description,
      isDone: isDoneSelected.value,
      createdAt: now,
      isDeleted: false,
      isPinned: false,
      isSynced: false,
    );

    // Add offline
    await TodoDatabase.instance.createTodo(todo);

    // Try syncing online
    if (await NetworkService.isOnline) {
      await TodoFirestoreService.createOrUpdateTodo(todo);
      todo.isSynced = true;
      await TodoDatabase.instance.updateTodo(todo);
    }

    await fetchTodos();

    if (Get.isDialogOpen ?? false) Get.back();
  }

  // ADD
  Future<void> addTodoToFireStore(
    String title,
    String description, {
    required bool isDone,
  }) async {
    final todo = Todo(
      id: Uuid().v4(),
      title: title,
      description: description,
      isDone: isDoneSelected.value ? true : false,
      isDeleted: false,
      isPinned: false,
    );
    await TodoFirestoreService.createOrUpdateTodo(todo);
    // await fetchTodos();
  }

  // UPDATE
  Future<void> updateTodo(Todo todo) async {
    await TodoHybridService.updateTodo(todo);
    await fetchTodos();

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // SOFT DELETE
  Future<void> deleteTodo(String id) async {
    await TodoHybridService.deleteTodo(id);
    await fetchTodos();
    await fetchDeletedTodos();
  }

  void listenDeletedTodos() {
    TodoFirestoreService.streamDeletedTodos().listen((todos) {
      deletedTodoList.value = todos;
    });
  }

  // RESTORE
  Future<void> restoreTodo(String id) async {
    await TodoHybridService.restoreTodo(id);
    await fetchTodos();
    await fetchDeletedTodos();
  }

  // PIN / UNPIN
  Future<void> togglePin(Todo todo) async {
    await TodoHybridService.togglePin(todo);
    await fetchTodos();
  }

  // PERMANENT DELETE
  Future<void> permanentDelete(String id) async {
    await TodoHybridService.permanentDelete(id);
    await fetchDeletedTodos();
  }

  // FILTERED TODOS FOR TAB BAR
  List<Todo> getFilteredTodosFromList(List<Todo> list, int filter) {
    List<Todo> filtered = List.from(list);

    // SEARCH
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();

      filtered = filtered.where((t) {
        final isPinned = t.isPinned ?? false;
        final isDone = t.isDone ?? false;

        final fields = [
          t.title,
          t.description,
          t.id,
          t.createdAt?.toString(),
        ];

        // 🔥 Keyword matching (separate logic)
        final matchesText = fields.any(
              (f) => (f ?? '').toLowerCase().contains(query),
        );

        final matchesPinned =
        (query == 'pin' || query == 'pinned') ? isPinned : false;

        final matchesUnpinned =
        (query == 'unpin' || query == 'normal') ? !isPinned : false;

        final matchesDone =
        (query == 'done' || query == 'completed') ? isDone : false;

        final matchesPending =
        (query == 'pending' || query == 'not done') ? !isDone : false;

        return matchesText ||
            matchesPinned ||
            matchesUnpinned ||
            matchesDone ||
            matchesPending;
      }).toList();
    }

    // FILTER
    if (filter == 1) {
      filtered = filtered.where((t) => t.isDone == true).toList();
    } else if (filter == 2) {
      filtered = filtered.where((t) => t.isDone == false).toList();
    } else if (filter == 3) {
      filtered = filtered.where((t) => t.isPinned == true).toList();
    }

    // Sort
    filtered.sort((a, b) {
      // PIN FIRST
      if ((a.isPinned ?? false) != (b.isPinned ?? false)) {
        return (b.isPinned ?? false) ? 1 : -1;
      }

      int result = 0;

      switch (sortType.value) {
        case SortType.title:
          result = (a.title ?? '').compareTo(b.title ?? '');
          break;

        case SortType.date:
        case SortType.pin:
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          result = aDate.compareTo(bDate);
          break;
      }

      return sortOrder.value == 'asc' ? result : -result;
    });
    return filtered;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }


}

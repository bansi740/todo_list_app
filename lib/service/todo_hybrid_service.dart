import 'package:uuid/uuid.dart';

import '../home/todo_list_database/todo_firestore_service.dart';
import '../home/todo_list_database/todo_list_database.dart';
import '../home/todo_list_database/todo_list_model.dart';
import 'network_service.dart';

class TodoHybridService {
  // ADD / CREATE
  static Future<void> addTodo(Todo todo) async {
    todo.isSynced = false;
    todo.createdAt ??= DateTime.now(); // ensure date exists offline
    await TodoDatabase.instance.createTodo(todo);

    if (await NetworkService.isOnline) {
      await TodoFirestoreService.createOrUpdateTodo(todo);
      todo.isSynced = true;
      await TodoDatabase.instance.updateTodo(todo);
    }
  }

  // UPDATE
  static Future<void> updateTodo(Todo todo) async {
    todo.isSynced = false;
    await TodoDatabase.instance.updateTodo(todo);

    if (await NetworkService.isOnline) {
      await TodoFirestoreService.updateTodo(todo);
      todo.isSynced = true;
      await TodoDatabase.instance.updateTodo(todo);
    }
  }

  // DELETE
  static Future<void> deleteTodo(String id) async {
    await TodoDatabase.instance.deleteTodo(id);

    if (await NetworkService.isOnline) {
      final todo = await TodoDatabase.instance.getTodoById(id);
      if (todo != null) {
        await TodoFirestoreService.updateTodo(todo); // soft delete online
        todo.isSynced = true;
        await TodoDatabase.instance.updateTodo(todo);
      }
    }
  }

  // RESTORE
  static Future<void> restoreTodo(String id) async {
    await TodoDatabase.instance.restoreTodo(id);

    if (await NetworkService.isOnline) {
      final todo = await TodoDatabase.instance.getTodoById(id);
      if (todo != null) {
        await TodoFirestoreService.updateTodo(todo); // restore online
        todo.isSynced = true;
        await TodoDatabase.instance.updateTodo(todo);
      }
    }
  }

  // PIN / UNPIN
  static Future<void> togglePin(Todo todo) async {
    todo.isPinned = !(todo.isPinned ?? false);
    todo.isSynced = false;
    await TodoDatabase.instance.togglePin(todo.id!, todo.isPinned!);

    if (await NetworkService.isOnline) {
      await TodoFirestoreService.updateTodo(todo);
      todo.isSynced = true;
      await TodoDatabase.instance.updateTodo(todo);
    }
  }

  // PERMANENT DELETE
  static Future<void> permanentDelete(String id) async {
    await TodoDatabase.instance.permanentDelete(id);
    if (await NetworkService.isOnline) {
      await TodoFirestoreService.permanentDelete(id);
    }
  }

  // SYNC PENDING OFFLINE TODOS
  static Future<void> syncPendingTodos() async {
    final todos = await TodoDatabase.instance.getAllTodos();

    for (var todo in todos.where((t) => t.isSynced == false)) {
      try {
        todo.id ??= const Uuid().v4(); // ensure ID exists
        await TodoFirestoreService.createOrUpdateTodo(todo);
        todo.isSynced = true;
        await TodoDatabase.instance.updateTodo(todo);
      } catch (_) {
        // ignore errors
      }
    }
  }

  // GET ALL TODOS (offline first, then online merge)
  static Future<List<Todo>> getAllTodos() async {
    // 1️⃣ Get local todos first
    List<Todo> localTodos = await TodoDatabase.instance.getAllTodos();

    // 2️⃣ If online, fetch Firestore todos and merge
    if (await NetworkService.isOnline) {
      try {
        final remoteTodos = await TodoFirestoreService.getAllTodos();

        for (var remote in remoteTodos) {
          // Check if remote todo exists locally
          final localIndex = localTodos.indexWhere((t) => t.id == remote.id);

          if (localIndex == -1) {
            // Remote todo not in local DB → insert
            remote.isSynced = true;
            await TodoDatabase.instance.createTodo(remote);
            localTodos.add(remote);
          } else {
            // Remote todo exists → update local
            remote.isSynced = true;
            await TodoDatabase.instance.updateTodo(remote);
            localTodos[localIndex] = remote;
          }
        }
      } catch (e) {
        print('Error syncing todos: $e');
      }
    }

    return localTodos;
  }
}
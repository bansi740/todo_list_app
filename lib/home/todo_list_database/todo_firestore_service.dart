import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list_app/home/todo_list_database/todo_list_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class TodoFirestoreService {
  static String get uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference get todoCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('todos');

  // CREATE
  static Future<void> createOrUpdateTodo(Todo todo) async {
    final data = todo.toJson(forFirestore: true);

    // Make sure an ID exists
    todo.id ??= const Uuid().v4();

    // Always use the local ID as document ID
    await todoCollection.doc(todo.id).set(data, SetOptions(merge: true));
  }

  // STREAM TODOS
  static Stream<List<Todo>> streamTodos() {
    return todoCollection.where('isDeleted', isEqualTo: false).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Todo.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }).toList();
    });
  }

  // GET ALL TODOS
  static Future<List<Todo>> getAllTodos() async {
    try {
      final querySnapshot = await todoCollection
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Todo.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  // GET ONE TODO
  static Future<Todo?> getTodoById(String id) async {
    try {
      final doc = await todoCollection.doc(id).get();

      if (doc.exists) {
        return Todo.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }

      return null;
    } catch (e) {
      throw Exception('Error fetching todo: $e');
    }
  }

  // UPDATE
  static Future<void> updateTodo(Todo todo) async {
    final docRef = todoCollection.doc(todo.id);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'title': todo.title,
        'description': todo.description,
        'isDone': todo.isDone,
        'reminderAt': todo.reminderAt,
        'isDeleted': todo.isDeleted,
        'isPinned': todo.isPinned,
      });
    } else {
      // if not exists, create using local id
      await createOrUpdateTodo(todo);
    }
  }

  // SOFT DELETE
  static Future<void> deleteTodo(String id) async {
    try {
      await todoCollection.doc(id).update({'isDeleted': true});
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }

  // GET DELETED TODOS
  static Stream<List<Todo>> streamDeletedTodos() {
    return todoCollection.where('isDeleted', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Todo.fromJson({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }).toList();
    });
  }

  // RESTORE
  static Future<void> restoreTodo(String id) async {
    try {
      await todoCollection.doc(id).update({'isDeleted': false});
    } catch (e) {
      throw Exception('Error restoring todo: $e');
    }
  }

  // PERMANENT DELETE
  static Future<void> permanentDelete(String id) async {
    try {
      await todoCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error permanently deleting todo: $e');
    }
  }
}

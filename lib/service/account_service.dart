import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountService {
  static Future<void> deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      throw Exception("User not found");
    }

    try {
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;

      //  Delete todos
      final todos = await firestore
          .collection("users")
          .doc(uid)
          .collection("todos")
          .get();

      for (var doc in todos.docs) {
        await doc.reference.delete();
      }

      // 🗑 Delete user document
      await firestore.collection("users").doc(uid).delete();

      //  Delete Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Incorrect password");
      } else {
        throw Exception(e.message ?? "Auth error");
      }
    } catch (e) {
      throw Exception("Something went wrong");
    }
  }
}

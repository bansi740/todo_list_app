import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var name = ''.obs;
  var email = ''.obs;


  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  void fetchUser() async {

    final user = _auth.currentUser;

    if (user == null) return;

    final doc = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {

      name.value = doc["name"] ?? "";
      email.value = doc["email"] ?? "";

    }
  }
  // edit Username
  Future<void> updateUserName(String newName) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        "name": newName,
      });

      name.value = newName;

    } catch (e) {
      print("Update name error: $e");
    }
  }

}
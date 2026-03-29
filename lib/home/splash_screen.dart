import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/home/todo_list_screen.dart';

import 'login_screen.dart';
import 'controller/theme_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
    Future.microtask(initApp);
  }
  void initApp() async {
    await Future.wait([
      themeController.loadTheme(),
      Future.delayed(const Duration(milliseconds: 300)),
    ]);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Get.offAll(() => const TodoListScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Todo App",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Organize your tasks easily",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            const SpinKitFadingCube(color: Colors.blue, size: 45.0),
          ],
        ),
      ),
    );
  }
}

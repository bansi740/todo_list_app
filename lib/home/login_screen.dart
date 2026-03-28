import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:todo_list_app/home/register_screen.dart';
import 'package:todo_list_app/home/todo_list_screen.dart';
import 'package:todo_list_app/utils/app_string.dart';
import 'package:todo_list_app/utils/assets.dart';

import '../utils/common_widgets.dart';
import 'controller/email_controller.dart';
import 'controller/password_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final PasswordController passwordControllerX = Get.put(PasswordController());
  final EmailController emailControllerX = Get.put(EmailController());

  String? userName;
  bool isLoadingUser = false;

  Future<void> fetchUserData(String email) async {
    if (email.isEmpty || !email.contains("@")) return;

    setState(() {
      isLoadingUser = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        userName = data["name"];
      } else {
        userName = null;
      }
    } catch (e) {
      userName = null;
    }

    setState(() {
      isLoadingUser = false;
    });
  }

  Future login() async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        Get.to(
          () => const RegisterScreen(),
          arguments: {"email": email, "password": password},
        );
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Get.offAll(() => const TodoListScreen());
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        Get.snackbar("Login Failed", "Incorrect password");
        return;
      }
      if (e.code == "invalid-credential") {
        Get.snackbar("Login Failed", "Invalid email or password");
        return;
      }
      Get.snackbar("Login Failed", e.message ?? "Something went wrong");
    }
  }

  @override
  void initState() {
    super.initState();
    final data = Get.arguments;
    if (data != null) {
      emailController.text = data["email"] ?? "";
      passwordController.text = data["password"] ?? "";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsPath.loginIcon,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  width: 55,
                  height: 55,
                ),
                const SizedBox(height: 10),

                isLoadingUser
                    ? SpinKitSpinningLines(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        size: 35.0,
                      )
                    : Column(
                        children: [
                          _TypingText(
                            text: "Welcome Back",
                            fontSize: userName != null ? 18 : 28,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          const SizedBox(height: 4),
                          if (userName != null)
                            _TypingText(
                              text: userName!,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                        ],
                      ),

                const SizedBox(height: 6),

                Text(
                  userName != null
                      ? "Glad to see you again"
                      : "Login to continue",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                // Email
                TodoTextField(
                  controller: emailController,
                  label: "Email",
                  onChanged: (value) {
                    emailControllerX.updateEmailSuggestions(value);

                    if (value.contains("@") && value.contains(".")) {
                      fetchUserData(value);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    }
                    if (!value.contains("@")) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                // Email Suggestions UI
                const SizedBox(height: 8),
                Obx(() {
                  if (emailControllerX.emailSuggestions.isEmpty) {
                    return const SizedBox();
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                    ),
                    child: Column(
                      children: emailControllerX.emailSuggestions.map((email) {
                        return ListTile(
                          dense: true,
                          title: Text(email),
                          onTap: () {
                            emailController.text = email;
                            emailControllerX.clearSuggestions();
                            fetchUserData(email); // ✅ ADD THIS LINE
                          },
                        );
                      }).toList(),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Password
                TodoTextField(
                  controller: passwordController,
                  label: "Password",
                  isPassword: true,
                  onChanged: (value) {
                    passwordControllerX.checkPassword(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Obx(() {
                  if (passwordControllerX.strength.value == 0) {
                    return const SizedBox();
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: passwordControllerX.strength.value,
                          ),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  passwordControllerX.strengthColor.value,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Password Strength",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                passwordControllerX.strengthText.value,
                                key: ValueKey(
                                  passwordControllerX.strengthText.value,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      passwordControllerX.strengthColor.value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppString.donT,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const RegisterScreen());
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        AppString.createAccount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
  }
}

class _TypingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  const _TypingText({
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.w500,
    required this.color,
  });

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.text.length * 80),
      vsync: this,
    );

    _textAnimation = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String visibleText = widget.text.substring(0, _textAnimation.value);

        return Text(
          visibleText,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.color,
          ),
        );
      },
    );
  }
}

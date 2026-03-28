import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  RxDouble strength = 0.0.obs;
  RxString strengthText = "".obs;
  Rx<Color> strengthColor = Colors.transparent.obs;

  void checkPassword(String password) {
    double value = 0;

    if (password.isEmpty) {
      strength.value = 0;
      strengthText.value = "";
      strengthColor.value = Colors.transparent;
      return;
    }

    // Length checks
    if (password.length >= 6) value += 0.3;
    if (password.length >= 8) value += 0.2;

    // Character checks
    if (RegExp(r'[A-Z]').hasMatch(password)) value += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) value += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) value += 0.1;

    strength.value = value;

    // Strength label + color
    if (value < 0.3) {
      strengthText.value = "Weak";
      strengthColor.value = Colors.red;
    } else if (value < 0.7) {
      strengthText.value = "Medium";
      strengthColor.value = Colors.orange;
    } else {
      strengthText.value = "Strong";
      strengthColor.value = Colors.green;
    }
  }
}
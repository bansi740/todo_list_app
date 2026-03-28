import 'package:get/get.dart';

class ExpansionController extends GetxController {
  var openIndex = (-1).obs;

  void toggle(int index) {
    if (openIndex.value == index) {
      openIndex.value = -1; // close if same
    } else {
      openIndex.value = index; // open new
    }
  }
}
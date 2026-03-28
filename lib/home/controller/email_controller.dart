import 'package:get/get.dart';

class EmailController extends GetxController {
  final domains = ["gmail.com", "outlook.com", "yahoo.com"];

  RxList<String> emailSuggestions = <String>[].obs;

  void updateEmailSuggestions(String value) {
    if (value.isEmpty) {
      emailSuggestions.clear();
      return;
    }

    if (!value.contains("@")) {
      emailSuggestions.value =
          domains.map((d) => "$value@$d").toList();
      return;
    }

    String prefix = value.split("@")[0];
    String domainPart =
    value.split("@").length > 1 ? value.split("@")[1] : "";

    // If valid domain entered → clear suggestions
    if (domains.contains(domainPart)) {
      emailSuggestions.clear();
      return;
    }

    emailSuggestions.value = domains
        .where((d) => d.startsWith(domainPart))
        .map((d) => "$prefix@$d")
        .toList();
  }

  void clearSuggestions() {
    emailSuggestions.clear();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/term_model.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool isChecked = false;
  bool isScrolledToBottom = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
        setState(() {
          isScrolledToBottom = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //  Only 5 LONG Terms (Realistic)
  final List<TermModel> termsList = [
    TermModel(
      title: "1. Acceptance of Terms",
      description:
          "By creating an account and using this application, you agree to comply with and be legally bound by these Terms and Conditions. "
          "If you do not agree with any part of these terms, you must not use the application. "
          "These terms apply to all users, including visitors, registered users, and others who access or use the service. "
          "We reserve the right to modify these terms at any time without prior notice. "
          "Continued use of the app after changes means you accept the updated terms.",
    ),

    TermModel(
      title: "2. User Account & Security",
      description:
          "You are responsible for maintaining the confidentiality of your account credentials. "
          "You agree not to share your login details with others. "
          "Any activity performed under your account will be considered your responsibility. "
          "We recommend using a strong password and enabling any available security features. "
          "Unauthorized access or suspicious activity should be reported immediately.",
    ),

    TermModel(
      title: "3. User Responsibilities",
      description:
          "You agree to use the application responsibly and in compliance with all applicable laws. "
          "You must not engage in activities that harm, disrupt, or misuse the platform. "
          "This includes attempting to hack, reverse engineer, or exploit vulnerabilities. "
          "Users must not upload or share harmful, illegal, or offensive content. "
          "Violation of these responsibilities may result in account suspension.",
    ),

    TermModel(
      title: "4. Privacy & Data Usage",
      description:
          "We respect your privacy and are committed to protecting your personal data. "
          "Information collected is used solely to improve app functionality and user experience. "
          "We do not sell or share personal data with third parties without consent. "
          "Basic analytics may be collected for performance monitoring and improvements. "
          "By using the app, you agree to the handling of data as described in our privacy practices.",
    ),

    TermModel(
      title: "5. Data Storage & Backup",
      description:
          "Your data may be stored securely on cloud servers such as Firestore. "
          "While we implement security measures, we cannot guarantee absolute protection against data loss. "
          "Users are encouraged to maintain their own backups where applicable. "
          "We are not responsible for any data loss due to technical failures, device issues, or unforeseen circumstances.",
    ),

    TermModel(
      title: "6. Service Availability",
      description:
          "We strive to provide continuous service but do not guarantee uninterrupted availability. "
          "Maintenance, updates, or technical issues may temporarily affect access to the application. "
          "Features may be added, modified, or removed at any time without prior notice. "
          "We are not liable for any inconvenience caused due to downtime or service interruptions.",
    ),

    TermModel(
      title: "7. Limitation of Liability",
      description:
          "The application is provided on an 'as is' basis without warranties of any kind. "
          "We are not responsible for any direct or indirect damages arising from the use of the app. "
          "This includes data loss, device issues, or unauthorized access. "
          "Users agree to use the application at their own risk and discretion.",
    ),

    TermModel(
      title: "8. Changes to Terms",
      description:
          "We reserve the right to update or modify these Terms & Conditions at any time. "
          "Users will be notified of significant changes when necessary. "
          "Continued use of the application after updates constitutes acceptance of the revised terms. "
          "It is recommended to review the terms periodically to stay informed about any changes.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: isDark ? Colors.black : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 SCROLL AREA
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 Header
                          Text(
                            "Please Read Carefully",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Scroll down and accept to continue",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey : Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Terms List
                          ...termsList.map(
                            (term) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(10)
                                    : Colors.black.withAlpha(10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    term.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Divider(
                            color: isDark
                                ? Colors.grey
                                : Colors.grey.withAlpha(220),
                            thickness: 4,
                            endIndent: 2,
                            indent: 5,
                            radius: BorderRadius.horizontal(
                              left: Radius.circular(20),
                              right: Radius.circular(20),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 🔥 MODERN CHECKBOX
                          GestureDetector(
                            onTap: isScrolledToBottom
                                ? () {
                                    setState(() {
                                      isChecked = !isChecked;
                                    });
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isChecked
                                    ? (isDark ? Colors.white12 : Colors.black12)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isScrolledToBottom
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "I agree to Terms & Conditions",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isScrolledToBottom
                                            ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isChecked
                    ? () {
                        Get.back(result: true);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Agree & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/faq_model.dart';
import 'controller/theme_controller.dart';

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    final isDark = themeController.isDarkMode;

    final backgroundColor = isDark ? black : Colors.grey[100]!;
    final cardColor = isDark
        ? Colors.grey.shade900.withAlpha(120)
        : Colors.grey.shade300.withAlpha(100);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Help & Feedback", style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildCardItem(
                    cardColor,
                    textColor,
                    "FAQs",
                    Icons.question_answer_rounded,
                    () {
                      _showFaqBottomSheet(
                        context,
                        backgroundColor,
                        textColor,
                        cardColor,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCardItem(
                    cardColor,
                    textColor,
                    "Contact Support",
                    Icons.support_agent_rounded,
                    () {},
                  ),
                  const SizedBox(height: 12),
                  _buildCardItem(
                    cardColor,
                    textColor,
                    "Report a Problem",
                    Icons.report_problem_rounded,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                final isDark = Get.find<ThemeController>().isDarkMode;

                Get.closeAllSnackbars();

                Get.rawSnackbar(
                  messageText: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Feedback sent successfully!",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  snackPosition: SnackPosition.TOP,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 14,
                  backgroundColor: isDark
                      ? const Color(0xFF14532D)
                      : const Color(0xFF16A34A),
                  duration: const Duration(seconds: 2),
                  animationDuration: const Duration(milliseconds: 300),
                  isDismissible: true,
                  forwardAnimationCurve: Curves.easeOutBack,
                );
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 120),
                scale: _isPressed ? 0.96 : 1,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),

                    // GRADIENT
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C65E), Color(0xFF16A34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ICON ANIMATION
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0, end: _isPressed ? 1 : 0),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: value * 0.2,
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.feedback_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Send Feedback",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Card-style Expansion Panel Bottom Sheet
  void _showFaqBottomSheet(
    BuildContext context,
    Color bgColor,
    Color textColor,
    Color cardColor,
  ) {
    final List<FaqModel> faqList = [
      FaqModel(
        question: "How do I reset my password?",
        answer:
            "To reset your password, go to Settings > Account > Reset Password. "
            "Follow the instructions sent to your registered email. "
            "If you do not receive an email within a few minutes, check your spam folder. "
            "You can also contact support if you face any issues.",
      ),

      FaqModel(
        question: "How do I contact support?",
        answer:
            "You can contact support via the Contact Support option in this app. "
            "Provide your phone number or email and describe your issue. "
            "Our team will respond within 24 hours. "
            "For urgent matters, you can call the helpline number provided in the app.",
      ),

      FaqModel(
        question: "How to report a problem?",
        answer:
            "To report a problem, tap on Report a Problem, write a detailed description "
            "of the issue you are facing, and click Save. "
            "This will send the report to our team for review. "
            "We recommend including screenshots if possible.",
      ),

      FaqModel(
        question: "Can I change my display name?",
        answer:
            "Yes, you can change your display name from the Settings screen by tapping on the Edit icon next to your name. "
            "After entering a new name, tap Save to update it immediately.",
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.35,
          initialChildSize: 0.65,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: faqList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final faq = faqList[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      // clip ripple to card radius
                      child: Material(
                        color: cardColor,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          // can keep empty, ExpansionTile handles expansion
                          child: Theme(
                            data: Theme.of(
                              context,
                            ).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: textColor,
                              collapsedIconColor: textColor,
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              childrenPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              title: Text(
                                faq.question,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              children: [
                                Text(
                                  faq.answer,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardItem(
    Color cardColor,
    Color textColor,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

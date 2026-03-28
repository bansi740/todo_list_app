import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/stats_controller.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final stats = Get.put(StatsController());

  // Progress Type
  String progressType = "Circle";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.black : Colors.white;
    final text = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,


      // APPBAR WITH ICON
      appBar: AppBar(
        title: const Text("Insights"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: bg,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showProgressTypeSheet(context, isDark, text),
          ),
        ],
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Obx(() {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // FILTER
                _segmentFilter(isDark, text),
                const SizedBox(height: 24),
                // PROGRESS VIEW
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stats.progress),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, value, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: progressType == "Circle"
                          ? _circleProgress(value, isDark, text)
                          : _barProgress(value, isDark, text),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // STATS
                Column(
                  children: [
                    _cleanStatTile(
                      "Total Tasks",
                      stats.totalTasks,
                      Colors.blue,
                      Icons.list,
                    ),
                    const SizedBox(height: 12),
                    _cleanStatTile(
                      "Completed",
                      stats.completedTasks,
                      Colors.green,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 12),
                    _cleanStatTile(
                      "Pending",
                      stats.pending,
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (stats.totalTasks == 0)
                  Center(
                    child: Text(
                      "No tasks found",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
  // FILTER
  Widget _segmentFilter(bool isDark, Color text) {
    final filters = ["Date", "Today", "Month", "Year"];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withAlpha(50)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(25) : Colors.grey.shade200,
        ),
      ),
      child: Obx(() {
        return Row(
          children: filters.map((e) {
            final isSelected = stats.selectedFilter.value == e;

            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (e == "Date") {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      stats.pickDate(picked);
                    }
                  } else {
                    stats.changeFilter(e);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isSelected
                        ? (isDark
                              ? const Color(
                                  0xFF2A2F3A,
                                ) // solid elevated dark surface
                              : Colors.white)
                        : Colors.transparent,
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xcc4facfe), Color(0xff00f1de)],
                          )
                        : null,
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.05 : 1.0,
                    curve: Curves.easeInOut,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        child: Text(e),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  // CIRCLE
  Widget _circleProgress(double value, bool isDark, Color text) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              backgroundColor: isDark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              color: Colors.blue,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const Text("Completed", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // BAR
  Widget _barProgress(double value, bool isDark, Color text) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (context, animatedValue, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? Colors.grey.shade900.withAlpha(40)
                : Colors.grey.shade200.withAlpha(180),
            border: Border.all(
              color: isDark
                  ? Colors.grey.shade300.withAlpha(40)
                  : Colors.grey.shade400.withAlpha(70),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    "${(animatedValue * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background Track
                    Container(
                      height: 10,
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade300,
                    ),

                    // Animated Gradient Fill
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: animatedValue,
                      child: Container(
                        height: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff4facfe), Color(0xff00f2fe)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Footer
              Text(
                "Completed",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // STAT TILE
  Widget _cleanStatTile(String title, int value, Color color, IconData icon) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      builder: (context, val, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withAlpha(18), // subtle background tint
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withAlpha(35), // slightly stronger tint
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: color.withAlpha(220), // softened text tone
                  ),
                ),
              ),

              Text(
                "$val",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color, // keep strong for emphasis
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _modernOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xff4facfe), Color(0xff00f2fe)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withAlpha(50) : Colors.grey.shade100),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(20)
                    : (isDark ? Colors.black26 : Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.blue),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // CHECK ICON
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showProgressTypeSheet(BuildContext context, bool isDark, Color text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HANDLE BAR
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              // TITLE
              Text(
                "Choose Progress Style",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 20),
              // OPTIONS
              _modernOption(
                title: "Circle Progress",
                subtitle: "Visual circular indicator",
                icon: Icons.pie_chart,
                isSelected: progressType == "Circle",
                isDark: isDark,
                onTap: () {
                  setState(() => progressType = "Circle");
                  Get.back();
                },
              ),

              const SizedBox(height: 12),

              _modernOption(
                title: "Bar Progress",
                subtitle: "Linear progress bar",
                icon: Icons.show_chart,
                isSelected: progressType == "Bar",
                isDark: isDark,
                onTap: () {
                  setState(() => progressType = "Bar");
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

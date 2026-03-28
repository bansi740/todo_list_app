import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'home_controller.dart';

class StatsController extends GetxController {
  final home = Get.find<HomeController>();

  var selectedFilter = "Today".obs;

  // NEW: selected custom date
  Rxn<DateTime> selectedDate = Rxn<DateTime>();

  void changeFilter(String filter) {
    selectedFilter.value = filter;

    // reset custom date if not Date filter
    if (filter != "Date") {
      selectedDate.value = null;
    }
  }

  void pickDate(DateTime date) {
    selectedDate.value = date;
    selectedFilter.value = "Date";
  }

  List get filteredTodos {
    final now = DateTime.now();

    return home.todoList.where((todo) {
      final date = todo.createdAt ?? now;

      if (selectedFilter.value == "Today") {
        return date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
      }

      if (selectedFilter.value == "Month") {
        return date.month == now.month && date.year == now.year;
      }

      if (selectedFilter.value == "Year") {
        return date.year == now.year;
      }

      // NEW DATE FILTER
      if (selectedFilter.value == "Date" && selectedDate.value != null) {
        final d = selectedDate.value!;
        return date.day == d.day &&
            date.month == d.month &&
            date.year == d.year;
      }

      return true;
    }).toList();
  }

  int get totalTasks => filteredTodos.length;

  int get completedTasks => filteredTodos.where((t) => t.isDone == true).length;

  int get pending => filteredTodos.where((t) => t.isDone == false).length;

  double get progress {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nav_provider.dart';
import '../providers/task_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'stats_screen.dart';
import 'add_task_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavProvider>(
      builder: (context, navProvider, _) {
        return Scaffold(
          body: IndexedStack(
            index: navProvider.currentIndex,
            children: const [
              HomeScreen(),
              CalendarScreen(),
              StatsScreen(),
            ],
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: navProvider.currentIndex,
            onTap: navProvider.setIndex,
            onAddTap: () {
              final taskProvider = context.read<TaskProvider>();
              final statsProvider = context.read<StatsProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              ).then((result) {
                if (result == true) {
                  // Sync en segundo plano con la DB para confirmar datos reales
                  taskProvider.loadTodayTasks();
                  taskProvider.loadWeekTasks();
                  statsProvider.loadStats();
                }
              });
            },
          ),
        );
      },
    );
  }
}

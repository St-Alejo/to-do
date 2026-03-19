import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonth(_focusedDay);
    });
  }

  void _loadMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    context.read<TaskProvider>().loadMonthTasks(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final selectedTasks = provider.getTasksForDay(_selectedDay);
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: AppTheme.textPrimary),
                        onPressed: () {
                          final prev = DateTime(
                              _focusedDay.year, _focusedDay.month - 1);
                          setState(() => _focusedDay = prev);
                          _loadMonth(prev);
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'es').format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: AppTheme.textPrimary),
                        onPressed: () {
                          final next = DateTime(
                              _focusedDay.year, _focusedDay.month + 1);
                          setState(() => _focusedDay = next);
                          _loadMonth(next);
                        },
                      ),
                    ],
                  ),
                ),
                TableCalendar<TaskModel>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: provider.getTasksForDay,
                  headerVisible: false,
                  calendarFormat: CalendarFormat.month,
                  locale: 'es_ES',
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                    _loadMonth(focusedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle:
                        const TextStyle(color: AppTheme.primary),
                    todayTextStyle: const TextStyle(color: Colors.white),
                    outsideDaysVisible: false,
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 4,
                    markersMaxCount: 1,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Tasks on ${DateFormat('d MMM', 'es').format(_selectedDay)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : selectedTasks.isEmpty
                          ? Center(
                              child: Text(
                                'No tasks on this day',
                                style: TextStyle(
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.7)),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: selectedTasks.length,
                              itemBuilder: (context, index) {
                                final task = selectedTasks[index];
                                return TaskCard(
                                  task: task,
                                  onTap: () => showTaskDetail(
                                    context,
                                    task,
                                    onUpdated: () => context
                                        .read<TaskProvider>()
                                        .loadMonthTasks(
                                          DateTime(_focusedDay.year, _focusedDay.month, 1),
                                          DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
                                        ),
                                  ),
                                  onToggle: () => context
                                      .read<TaskProvider>()
                                      .toggleComplete(
                                          task.id, !task.isCompleted),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

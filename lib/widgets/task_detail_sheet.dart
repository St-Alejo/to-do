import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/task_model.dart';
import '../screens/edit_task_screen.dart';

/// BottomSheet que se muestra al hacer tap en una TaskCard.
/// Muestra los detalles de la tarea y permite editarla.
void showTaskDetail(BuildContext context, TaskModel task, {VoidCallback? onUpdated}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TaskDetailSheet(task: task, onUpdated: onUpdated),
  );
}

class TaskDetailSheet extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onUpdated;

  const TaskDetailSheet({super.key, required this.task, this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header con botón editar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detalles de la tarea',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // Botón lápiz — editar
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task),
                          ),
                        ).then((updated) {
                          if (updated == true) onUpdated?.call();
                        });
                      },
                      icon: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: AppTheme.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              // Contenido desplazable
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  children: [
                    // Estado
                    _DetailRow(
                      icon: task.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      iconColor: task.isCompleted
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      label: 'Estado',
                      value: task.isCompleted ? 'Completada' : 'Pendiente',
                    ),
                    const SizedBox(height: 16),
                    // Título
                    _DetailSection(
                      label: 'Título',
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Descripción
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      _DetailSection(
                        label: 'Descripción',
                        child: Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Fecha y hora
                    Row(
                      children: [
                        Expanded(
                          child: _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppTheme.primary,
                            label: 'Fecha',
                            value: DateFormat('d MMM yyyy', 'es')
                                .format(task.date),
                          ),
                        ),
                        Expanded(
                          child: _DetailRow(
                            icon: Icons.access_time,
                            iconColor: AppTheme.primary,
                            label: 'Hora',
                            value: task.formattedTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Categoría
                    if (task.category != null)
                      _DetailRow(
                        icon: Icons.label_outline,
                        iconColor: _parseColor(task.category!.color),
                        label: 'Categoría',
                        value: task.category!.name,
                        valueColor: _parseColor(task.category!.color),
                      )
                    else if (task.categoryId != null)
                      _DetailRow(
                        icon: Icons.label_outline,
                        iconColor: AppTheme.textSecondary,
                        label: 'Categoría',
                        value: 'Sin nombre',
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _DetailSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }
}

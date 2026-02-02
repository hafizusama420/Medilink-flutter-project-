// lib/app/modules/assignments/views/assignment_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../viewmodels/assignment_list_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AssignmentListView extends GetView<AssignmentListViewModel> {
  const AssignmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAssignments,
          child: Column(
            children: [
              _buildFilterChips(),
              const SizedBox(height: 16),
              _buildStatusSummary(),
              const SizedBox(height: 16),
              Expanded(
                child: controller.filteredAssignments.isEmpty
                    ? _buildEmptyState()
                    : _buildAssignmentsList(),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.isDoctor) {
          return FloatingActionButton.extended(
            onPressed: controller.navigateToCreateAssignment,
            backgroundColor: AppTheme.primaryGreen,
            icon: const Icon(Icons.add),
            label: const Text('New Assignment'),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending'),
              const SizedBox(width: 8),
              _buildFilterChip('Completed'),
              const SizedBox(width: 8),
              _buildFilterChip('Overdue'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = controller.currentFilter.value == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.applyFilter(label);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusCard(
              'Pending',
              controller.pendingCount.toString(),
              Colors.orange,
              Icons.pending_actions,
            ),
            _buildStatusCard(
              'Completed',
              controller.completedCount.toString(),
              AppTheme.primaryGreen,
              Icons.check_circle,
            ),
            _buildStatusCard(
              'Overdue',
              controller.overdueCount.toString(),
              Colors.red,
              Icons.warning,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: controller.filteredAssignments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final assignment = controller.filteredAssignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(assignment) {
    final categoryIcon = _getCategoryIcon(assignment.category);
    final priorityColor = _getPriorityColor(assignment.priority);
    final statusColor = _getStatusColor(assignment.effectiveStatus);

    return GestureDetector(
      onTap: () => controller.navigateToAssignmentDetails(assignment.id!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: assignment.isOverdue && !assignment.isCompleted
                ? Colors.red.withOpacity(0.3)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title ?? 'Untitled Assignment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.category ?? 'General',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assignment.effectiveStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assignment.description != null && assignment.description!.isNotEmpty) ...[
              Text(
                assignment.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Due: ${_formatDate(assignment.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: assignment.isOverdue && !assignment.isCompleted
                        ? Colors.red
                        : Colors.grey.shade600,
                    fontWeight: assignment.isOverdue && !assignment.isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  assignment.priority ?? 'Medium',
                  style: TextStyle(
                    fontSize: 12,
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (controller.isDoctor) ...[
              const SizedBox(height: 8),
              Text(
                'Patient: ${assignment.patientName ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No assignments found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.isDoctor
                ? 'Create assignments for your patients'
                : 'You have no assignments yet',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Exercise':
        return Icons.fitness_center;
      case 'Medication':
        return Icons.medication;
      case 'Lifestyle':
        return Icons.spa;
      case 'Monitoring':
        return Icons.monitor_heart;
      case 'Follow-up':
        return Icons.event_repeat;
      default:
        return Icons.assignment;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.primaryGreen;
      case 'Overdue':
        return Colors.red;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

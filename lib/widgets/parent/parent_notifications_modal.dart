import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/parent/parent_notification_model.dart';

class ParentNotificationsModal extends StatelessWidget {
  final List<ParentNotificationModel> notifications;
  final Function(String id) onMarkRead;

  const ParentNotificationsModal({
    super.key,
    required this.notifications,
    required this.onMarkRead,
  });

  static void show(
    BuildContext context, {
    required List<ParentNotificationModel> notifications,
    required Function(String id) onMarkRead,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParentNotificationsModal(
        notifications: notifications,
        onMarkRead: onMarkRead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: Color(0xFF6C5CE7)),
                const SizedBox(width: 10),
                const Text(
                  'Parent Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _buildNotificationCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, ParentNotificationModel item) {
    Color cardBg;
    Color borderColor;
    IconData icon;
    Color iconColor;

    switch (item.type) {
      case ParentNotificationType.positive:
        cardBg = const Color(0xFFE8F8F5);
        borderColor = const Color(0xFF2ECC71);
        icon = Icons.stars_rounded;
        iconColor = const Color(0xFF2ECC71);
        break;

      case ParentNotificationType.attention:
        cardBg = const Color(0xFFFFF5F5);
        borderColor = const Color(0xFFFF6B6B);
        icon = Icons.lightbulb_rounded;
        iconColor = const Color(0xFFE74C3C);
        break;

      case ParentNotificationType.info:
        cardBg = Colors.white;
        borderColor = Colors.grey.shade300;
        icon = Icons.info_outline_rounded;
        iconColor = const Color(0xFF6C5CE7);
        break;
    }

    final timeStr = DateFormat('MMM d, h:mm a').format(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? Colors.grey.shade200 : borderColor,
          width: item.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (!item.isRead) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 20, color: Color(0xFF6C5CE7)),
              onPressed: () => onMarkRead(item.id),
              tooltip: 'Mark as read',
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme provider
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.white : AppColors.darkBlue,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Avisos',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: databaseService.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final announcements = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final api = announcements[index];
              final dateStr = api['timestamp'] as String? ?? '';
              final date = DateTime.tryParse(dateStr);
              final timeFormatted =
                  date != null
                      ? DateFormat('dd MMM, hh:mm a').format(date)
                      : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      isDark
                          ? null
                          : [
                            BoxShadow(
                              color: AppColors.shadowColor.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  border:
                      isDark ? Border.all(color: AppColors.darkBorder) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightGrey,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                api['subject'] ?? 'Aviso',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.white
                                          : AppColors.darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${api['routeName'] ?? 'General'} • $timeFormatted',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.grey
                                          : AppColors.darkGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      api['message'] ?? '',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.white.withValues(alpha: 0.9)
                                : AppColors.darkBlue,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightGrey,
              shape: BoxShape.circle,
              boxShadow:
                  isDark
                      ? null
                      : [
                        BoxShadow(
                          color: AppColors.shadowColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color:
                  isDark
                      ? AppColors.white.withValues(alpha: 0.2)
                      : AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No tiene notificaciones',
            style: TextStyle(
              color: isDark ? AppColors.white : AppColors.darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Te avisaremos cuando haya novedades\nimportantes sobre tu ruta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isDark
                      ? AppColors.white.withValues(alpha: 0.6)
                      : AppColors.darkGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

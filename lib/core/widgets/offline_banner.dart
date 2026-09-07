import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated banner displayed at the top of the screen when disconnected from internet.
class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final bool isSyncing;
  final VoidCallback? onSyncPressed;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.isSyncing = false,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isSyncing) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSyncing ? AppColors.info : AppColors.warning,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSyncing) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Syncing offline changes...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            const Icon(
              Icons.wifi_off_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You are currently offline. Tasks are saved locally and will sync when reconnected.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

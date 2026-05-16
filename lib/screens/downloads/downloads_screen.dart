import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/download_provider.dart';
import '../../core/themes/app_colors.dart';
import '../../models/download_task.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DownloadProvider>();
      provider.loadDownloads();
      provider.startPolling(intervalSeconds: 2);
    });
  }

  @override
  void dispose() {
    try {
      context.read<DownloadProvider>().stopPolling();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DownloadProvider>().loadDownloads();
            },
          ),
        ],
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun téléchargement',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vos téléchargements apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDownloads(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.downloads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final download = provider.downloads[index];
                return _DownloadCard(
                  download: download,
                  onPause: () => provider.pauseDownload(download.id),
                  onResume: () => provider.resumeDownload(download.id),
                  onCancel: () => provider.cancelDownload(download.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final DownloadTask download;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  const _DownloadCard({
    required this.download,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  String _getStatusText() {
    switch (download.status) {
      case DownloadStatus.pending:
        return 'En attente';
      case DownloadStatus.downloading:
        return 'Téléchargement';
      case DownloadStatus.processing:
        return 'Traitement';
      case DownloadStatus.completed:
        return 'Terminé';
      case DownloadStatus.failed:
        return 'Échoué';
      case DownloadStatus.paused:
        return 'En pause';
      case DownloadStatus.cancelled:
        return 'Annulé';
    }
  }

  Color _getStatusColor() {
    switch (download.status) {
      case DownloadStatus.pending:
        return AppColors.textMuted;
      case DownloadStatus.downloading:
        return AppColors.primary;
      case DownloadStatus.processing:
        return AppColors.info;
      case DownloadStatus.completed:
        return AppColors.success;
      case DownloadStatus.failed:
        return AppColors.error;
      case DownloadStatus.paused:
        return AppColors.warning;
      case DownloadStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Téléchargement #${download.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress
            if (!download.isCompleted && !download.isFailed)
              Row(
                children: [
                  // Circular progress
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (download.progress / 100).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                        ),
                        Text(
                          download.progress >= 1 ? '${download.progress.toStringAsFixed(0)}%' : '${download.progress.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.currentChapterTitle ?? 'Chapitre ${download.currentChapter}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${download.currentChapter}/${download.totalChapters} chapitres • ${download.progressText}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        if (download.isActive)
                          Text(
                            'ETA: ${download.etaText} • Vitesse: ${download.speed.toStringAsFixed(2)}/s',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

            // Info for completed downloads
            if (download.isCompleted)
              Column(
                children: [
                  if (download.fileSize > 0)
                    Text(
                      'Taille: ${(download.fileSize / 1024 / 1024).toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (download.outputPath != null)
                    Text(
                      'Fichier: ${download.outputPath}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

            // Error message
            if (download.isFailed && download.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  download.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),

            // Actions
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (download.isActive)
                  TextButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause, size: 18),
                    label: const Text('Pause'),
                  ),
                if (download.isPaused)
                  TextButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Reprendre'),
                  ),
                if (download.isActive || download.isPaused)
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Annuler'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
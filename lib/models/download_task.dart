enum DownloadStatus {
  pending,
  downloading,
  processing,
  completed,
  failed,
  paused,
  cancelled,
}

extension DownloadStatusExtension on DownloadStatus {
  String get value {
    switch (this) {
      case DownloadStatus.pending:
        return 'pending';
      case DownloadStatus.downloading:
        return 'downloading';
      case DownloadStatus.processing:
        return 'processing';
      case DownloadStatus.completed:
        return 'completed';
      case DownloadStatus.failed:
        return 'failed';
      case DownloadStatus.paused:
        return 'paused';
      case DownloadStatus.cancelled:
        return 'cancelled';
    }
  }

  static DownloadStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'processing':
        return DownloadStatus.processing;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      case 'paused':
        return DownloadStatus.paused;
      case 'cancelled':
        return DownloadStatus.cancelled;
      default:
        return DownloadStatus.pending;
    }
  }
}

class DownloadTask {
  final int id;
  final int novelId;
  final DownloadStatus status;
  final double progress;
  final int currentChapter;
  final int totalChapters;
  final String? currentChapterTitle;
  final double speed;
  final int eta;
  final String? outputPath;
  final int fileSize;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  DownloadTask({
    required this.id,
    required this.novelId,
    required this.status,
    required this.progress,
    required this.currentChapter,
    required this.totalChapters,
    this.currentChapterTitle,
    required this.speed,
    required this.eta,
    this.outputPath,
    required this.fileSize,
    this.errorMessage,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] ?? 0,
      novelId: json['novel_id'] ?? 0,
      status: DownloadStatusExtension.fromString(json['status'] ?? 'pending'),
      progress: (json['progress'] ?? 0).toDouble(),
      currentChapter: json['current_chapter'] ?? 0,
      totalChapters: json['total_chapters'] ?? 0,
      currentChapterTitle: json['current_chapter_title'],
      speed: (json['speed'] ?? 0).toDouble(),
      eta: json['eta'] ?? 0,
      outputPath: json['output_path'],
      fileSize: json['file_size'] ?? 0,
      errorMessage: json['error_message'],
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at']) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novel_id': novelId,
      'status': status.value,
      'progress': progress,
      'current_chapter': currentChapter,
      'total_chapters': totalChapters,
      'current_chapter_title': currentChapterTitle,
      'speed': speed,
      'eta': eta,
      'output_path': outputPath,
      'file_size': fileSize,
      'error_message': errorMessage,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => 
      status == DownloadStatus.downloading || 
      status == DownloadStatus.processing;

  bool get isPaused => status == DownloadStatus.paused;

  bool get isCompleted => status == DownloadStatus.completed;

  bool get isFailed => status == DownloadStatus.failed;

  String get progressText {
    if (status == DownloadStatus.completed) {
      return '100%';
    }
    return '${progress.toStringAsFixed(1)}%';
  }

  String get etaText {
    if (eta <= 0) return '--';
    if (eta < 60) return '${eta}s';
    if (eta < 3600) return '${(eta / 60).ceil()}min';
    return '${(eta / 3600).ceil()}h';
  }
}
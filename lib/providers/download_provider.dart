import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/download_task.dart';
import '../services/api_service.dart';

class DownloadProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<DownloadTask> _downloads = [];
  Timer? _pollTimer;
  bool _isLoading = false;
  String? _error;

  List<DownloadTask> get downloads => _downloads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DownloadTask> get activeDownloads => 
      _downloads.where((d) => d.isActive).toList();

  List<DownloadTask> get completedDownloads => 
      _downloads.where((d) => d.isCompleted).toList();

  /// Charge la liste des téléchargements
  Future<void> loadDownloads({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _downloads = await _apiService.getDownloads(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start polling the downloads endpoint every [intervalSeconds].
  void startPolling({int intervalSeconds = 2}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      await loadDownloads();
    });
  }

  /// Stop polling downloads.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Démarre un nouveau téléchargement
  Future<DownloadTask> startDownload(String url) async {
    try {
      final download = await _apiService.startDownload(url);
      _downloads.insert(0, download);
      notifyListeners();
      return download;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met en pause un téléchargement
  Future<void> pauseDownload(int downloadId) async {
    try {
      await _apiService.pauseDownload(downloadId);
      final index = _downloads.indexWhere((d) => d.id == downloadId);
      if (index != -1) {
        _downloads[index] = DownloadTask(
          id: _downloads[index].id,
          novelId: _downloads[index].novelId,
          status: DownloadStatus.paused,
          progress: _downloads[index].progress,
          currentChapter: _downloads[index].currentChapter,
          totalChapters: _downloads[index].totalChapters,
          currentChapterTitle: _downloads[index].currentChapterTitle,
          speed: _downloads[index].speed,
          eta: _downloads[index].eta,
          outputPath: _downloads[index].outputPath,
          fileSize: _downloads[index].fileSize,
          errorMessage: _downloads[index].errorMessage,
          startedAt: _downloads[index].startedAt,
          completedAt: _downloads[index].completedAt,
          createdAt: _downloads[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Reprend un téléchargement
  Future<void> resumeDownload(int downloadId) async {
    try {
      await _apiService.resumeDownload(downloadId);
      final index = _downloads.indexWhere((d) => d.id == downloadId);
      if (index != -1) {
        _downloads[index] = DownloadTask(
          id: _downloads[index].id,
          novelId: _downloads[index].novelId,
          status: DownloadStatus.downloading,
          progress: _downloads[index].progress,
          currentChapter: _downloads[index].currentChapter,
          totalChapters: _downloads[index].totalChapters,
          currentChapterTitle: _downloads[index].currentChapterTitle,
          speed: _downloads[index].speed,
          eta: _downloads[index].eta,
          outputPath: _downloads[index].outputPath,
          fileSize: _downloads[index].fileSize,
          errorMessage: _downloads[index].errorMessage,
          startedAt: _downloads[index].startedAt,
          completedAt: _downloads[index].completedAt,
          createdAt: _downloads[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Annule un téléchargement
  Future<void> cancelDownload(int downloadId) async {
    try {
      await _apiService.cancelDownload(downloadId);
      _downloads.removeWhere((d) => d.id == downloadId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Met à jour un téléchargement (pour polling)
  void updateDownload(DownloadTask download) {
    final index = _downloads.indexWhere((d) => d.id == download.id);
    if (index != -1) {
      _downloads[index] = download;
      notifyListeners();
    } else {
      _downloads.insert(0, download);
      notifyListeners();
    }
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
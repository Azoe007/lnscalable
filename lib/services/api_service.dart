import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/novel.dart';
import '../models/download_task.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Intercepteur pour logs
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // ============================================
  // HEALTH CHECK
  // ============================================

  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // DOWNLOADS
  // ============================================

  /// Démarre un nouveau téléchargement
  Future<DownloadTask> startDownload(String url) async {
    try {
      final response = await _dio.post(
        AppConstants.downloadsEndpoint,
        data: jsonEncode({'url': url}),
      );
      return DownloadTask.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la liste des téléchargements
  Future<List<DownloadTask>> getDownloads({String? status}) async {
    try {
      final response = await _dio.get(
        AppConstants.downloadsEndpoint,
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data as List)
          .map((json) => DownloadTask.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les détails d'un téléchargement
  Future<DownloadTask> getDownload(int downloadId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.downloadsEndpoint}/$downloadId',
      );
      return DownloadTask.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met en pause un téléchargement
  Future<void> pauseDownload(int downloadId) async {
    try {
      await _dio.post(
        '${AppConstants.downloadsEndpoint}/$downloadId/pause',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reprend un téléchargement
  Future<void> resumeDownload(int downloadId) async {
    try {
      await _dio.post(
        '${AppConstants.downloadsEndpoint}/$downloadId/resume',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Annule un téléchargement
  Future<void> cancelDownload(int downloadId) async {
    try {
      await _dio.delete(
        '${AppConstants.downloadsEndpoint}/$downloadId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // LIBRARY
  // ============================================

  /// Récupère la bibliothèque
  Future<List<Novel>> getLibrary({
    int skip = 0,
    int limit = 50,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.libraryEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (search != null) 'search': search,
        },
      );
      return (response.data as List)
          .map((json) => Novel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère un novel
  Future<Novel> getNovel(int novelId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.libraryEndpoint}/$novelId',
      );
      return Novel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime un novel
  Future<void> deleteNovel(int novelId) async {
    try {
      await _dio.delete(
        '${AppConstants.libraryEndpoint}/$novelId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // FAVORITES
  // ============================================

  /// Récupère les favoris
  Future<List<Novel>> getFavorites() async {
    try {
      final response = await _dio.get(AppConstants.favoritesEndpoint);
      return (response.data as List)
          .map((json) => Novel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Ajoute aux favoris
  Future<void> addFavorite(int novelId) async {
    try {
      await _dio.post(
        '${AppConstants.favoritesEndpoint}/$novelId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime des favoris
  Future<void> removeFavorite(int novelId) async {
    try {
      await _dio.delete(
        '${AppConstants.favoritesEndpoint}/$novelId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HISTORY
  // ============================================

  /// Récupère l'historique
  Future<List<Novel>> getHistory({
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.historyEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      return (response.data as List)
          .map((json) => Novel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ERROR HANDLING
  // ============================================

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Délai de connexion dépassé');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('Impossible de se connecter au serveur');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Ressource introuvable');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur du serveur');
    }
    return Exception('Une erreur est survenue: ${e.message}');
  }
}
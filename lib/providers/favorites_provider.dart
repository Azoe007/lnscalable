import 'package:flutter/foundation.dart';
import '../models/novel.dart';
import '../services/api_service.dart';

class FavoritesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Novel> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Novel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les favoris
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _apiService.getFavorites();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute aux favoris
  Future<void> addFavorite(int novelId) async {
    try {
      await _apiService.addFavorite(novelId);
      // Recharge les favoris
      await loadFavorites();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Supprime des favoris
  Future<void> removeFavorite(int novelId) async {
    try {
      await _apiService.removeFavorite(novelId);
      _favorites.removeWhere((n) => n.id == novelId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Vérifie si un novel est en favori
  bool isFavorite(int novelId) {
    return _favorites.any((n) => n.id == novelId);
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
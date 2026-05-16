import 'package:flutter/foundation.dart';
import '../models/novel.dart';
import '../services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Novel> _novels = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;

  List<Novel> get novels => _novels;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Charge la bibliothèque
  Future<void> loadLibrary({
    int skip = 0,
    int limit = 50,
    String? search,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 0;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newNovels = await _apiService.getLibrary(
        skip: skip,
        limit: limit,
        search: search,
      );

      if (loadMore) {
        _novels.addAll(newNovels);
      } else {
        _novels = newNovels;
      }

      _hasMore = newNovels.length == limit;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge plus de novels (pagination)
  Future<void> loadMore({String? search}) async {
    if (_isLoading || !_hasMore) return;
    
    await loadLibrary(
      skip: _currentPage * 50,
      limit: 50,
      search: search,
      loadMore: true,
    );
  }

  /// Recherche des novels
  Future<void> search(String query) async {
    await loadLibrary(search: query);
  }

  /// Efface la recherche
  void clearSearch() {
    _novels = [];
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
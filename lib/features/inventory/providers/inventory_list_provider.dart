import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medistock_pro/features/inventory/providers/inventory_providers.dart';
import 'package:medistock_pro/features/inventory/repositories/inventory_repository.dart';

class InventoryListState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final bool hasReachedMax;
  final String searchQuery;
  final String? error;

  InventoryListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.error,
  });

  InventoryListState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    bool? hasReachedMax,
    String? searchQuery,
    String? error,
  }) {
    return InventoryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

class InventoryListController extends StateNotifier<InventoryListState> {
  final InventoryRepository _repository;
  Timer? _debounce;

  InventoryListController(this._repository) : super(InventoryListState()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, items: [], currentPage: 1, hasReachedMax: false, error: null);
    try {
      final result = await _repository.getInventoryPaginated(
        page: 1,
        search: state.searchQuery,
      );
      
      final items = result['data'] as List<Map<String, dynamic>>;
      final totalPages = result['totalPages'] as int;
      
      state = state.copyWith(
        isLoading: false,
        items: items,
        hasReachedMax: state.currentPage >= totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final result = await _repository.getInventoryPaginated(
        page: nextPage,
        search: state.searchQuery,
      );
      
      final newItems = result['data'] as List<Map<String, dynamic>>;
      final totalPages = result['totalPages'] as int;

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...newItems],
        currentPage: nextPage,
        hasReachedMax: nextPage >= totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void updateSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (state.searchQuery != query) {
        state = state.copyWith(searchQuery: query);
        fetchInitial();
      }
    });
  }

  void refresh() {
    fetchInitial();
  }
}

final inventoryListControllerProvider = StateNotifierProvider<InventoryListController, InventoryListState>((ref) {
  return InventoryListController(ref.watch(inventoryRepositoryProvider));
});

import 'package:flutter/foundation.dart';

import '../models/complaint.dart';
import '../services/complaint_service.dart';
import '../utils/api_exception.dart';

class ComplaintsProvider extends ChangeNotifier {
  ComplaintsProvider(this._service);

  final ComplaintService _service;

  final List<Complaint> items = [];
  int count = 0;
  int _page = 1;
  bool loading = false;
  bool loadingMore = false;
  bool hasNext = false;
  String? error;
  ApiException? lastException;

  int get resolvedCount => items.where((item) => item.status == 'resolved').length;

  int get activeCount => items.where((item) {
        return item.status == 'reported' || item.status == 'in_progress';
      }).length;

  Future<void> refresh() {
    _page = 1;
    return _fetch(replace: true);
  }

  Future<void> loadMore() async {
    if (!hasNext || loading || loadingMore) {
      return;
    }
    _page += 1;
    await _fetch(replace: false);
  }

  Future<void> _fetch({required bool replace}) async {
    if (replace) {
      loading = true;
    } else {
      loadingMore = true;
    }
    error = null;
    lastException = null;
    notifyListeners();
    try {
      final page = await _service.list(page: _page);
      if (replace) {
        items
          ..clear()
          ..addAll(page.results);
      } else {
        items.addAll(page.results);
      }
      count = page.count;
      hasNext = page.hasNext;
    } catch (e) {
      if (!replace) {
        _page -= 1;
      }
      lastException = e is ApiException ? e : null;
      error = e.toString();
    } finally {
      loading = false;
      loadingMore = false;
      notifyListeners();
    }
  }
}

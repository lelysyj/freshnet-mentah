import '../models/inspection_model.dart';

class InspectionStorage {
  static final List<InspectionModel> _data = [];

  static void add(InspectionModel item) => _data.insert(0, item);

  static List<InspectionModel> getAll() => List.unmodifiable(_data);

  static void remove(int id) => _data.removeWhere((e) => e.id == id);

  static int getTotal() => _data.length;

  static int getFreshCount() => _data.where((e) => e.isFresh).length;

  static int getNonFreshCount() => _data.where((e) => !e.isFresh).length;

  static InspectionModel? getLatest() {
    if (_data.isEmpty) return null;
    return _data.first;
  }
}
// models/modcutter.dart
class Cutters {
  final int _colctrid;
  final String _colctrdesc;
  final String _traflag;

  Cutters(this._colctrid, this._colctrdesc, this._traflag);

  int get colctrid => _colctrid;
  String get colctrdesc => _colctrdesc;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _colctrid;
    map['description'] = _colctrdesc;
    map['traflag'] = _traflag;

    return map;
  }

  Cutters.fromMapObject(Map<String, dynamic> map)
    : _colctrid = map['id'],
      _colctrdesc = map['description'],
      _traflag = map['traflag'];
}

// models/modcutter.dart
class Cutting {
  final int _colcmid;
  final String _colcmdesc;
  final String _traflag;

  Cutting(this._colcmid, this._colcmdesc, this._traflag);

  int get colcmid => _colcmid;
  String get olcmdesc => _colcmdesc;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _colcmid;
    map['description'] = _colcmdesc;
    map['traflag'] = _traflag;

    return map;
  }

  Cutting.fromMapObject(Map<String, dynamic> map)
    : _colcmid = map['id'],
      _colcmdesc = map['description'],
      _traflag = map['traflag'];
}

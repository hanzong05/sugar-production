// models/modvariety.dart
class Variety {
  final int _colvarid;
  final String _colvardesc;
  final String _traflag;

  Variety(this._colvarid, this._colvardesc, this._traflag);

  int get colvarid => _colvarid;
  String get colvardesc => _colvardesc;
  String get traflag => _traflag;
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _colvarid;
    map['description'] = _colvardesc;
    map['traflag'] = _traflag;
    return map;
  }

  Variety.fromMapObject(Map<String, dynamic> map)
    : _colvarid = map['id'],
      _colvardesc = map['description'],
      _traflag = map['traflag'];
}

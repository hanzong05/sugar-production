// models/modlocation.dart
class Location {
  final int _collocid;
  final String _colloccode;
  final String _colloclocation;
  final String _traflag;

  Location(
    this._collocid,
    this._colloccode,
    this._colloclocation,
    this._traflag,
  );

  int get collocid => _collocid;
  String get colloccode => _colloccode;
  String get collocdesc => _colloclocation;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _collocid;
    map['code'] = _colloccode;
    map['location'] = _colloclocation;
    map['traflag'] = _traflag;

    return map;
  }

  Location.fromMapObject(Map<String, dynamic> map)
    : _collocid = map['id'],
      _colloccode = map['code'],
      _colloclocation = map['location'],
      _traflag = map['traflag'];
}

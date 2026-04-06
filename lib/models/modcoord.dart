class Coordinators {
  final int _frid;
  final String _frcode;
  final String _frname;
  final String _traflag;

  // String colTktcount = 'tktcount';
  // String colTktused = 'tktused';
  // String colTktusedupdated = 'tktusedupdated';
  // String colTktarrived = 'tktarrived';

  Coordinators(this._frid, this._frcode, this._frname, this._traflag);
  int get plid => _frid;
  String get frcode => _frcode;
  String get frname => _frname;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['fr_id'] = _frid;
    map['fr_code'] = _frcode;
    map['fr_name'] = _frname;
    map['traflag'] = _traflag;

    return map;
  }

  Coordinators.fromMapObject(Map<String, dynamic> map)
    : _frid = map['fr_id'],
      _frcode = map['fr_code'],
      _frname = map['fr_name'],
      _traflag = map['traflag'];
}

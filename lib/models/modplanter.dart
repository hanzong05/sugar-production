class Planter {
  final int _plid;
  final String _plcode;
  final String _plname;
  final String _traflag;

  // String colTktcount = 'tktcount';
  // String colTktused = 'tktused';
  // String colTktusedupdated = 'tktusedupdated';
  // String colTktarrived = 'tktarrived';

  Planter(this._plid, this._plcode, this._plname, this._traflag);
  int get plid => _plid;
  String get plcode => _plcode;
  String get plname => _plname;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['pl_id'] = _plid;
    map['pl_code'] = _plcode;
    map['pl_name'] = _plname;
    map['traflag'] = _traflag;

    return map;
  }

  Planter.fromMapObject(Map<String, dynamic> map)
    : _plid = map['pl_id'],
      _plcode = map['pl_code'],
      _plname = map['pl_name'],
      _traflag = map['traflag'];
}

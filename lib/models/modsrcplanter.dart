class SourcePlanter {
  final int _plsrcid;
  final String _plsrccode;
  final String _plsrcname;
  final String _traflag;
  SourcePlanter(this._plsrcid, this._plsrccode, this._plsrcname, this._traflag);
  int get plsrcid => _plsrcid;
  String get plsrccode => _plsrccode;
  String get plsrcname => _plsrcname;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['plsrc_id'] = _plsrcid;
    map['plsrc_code'] = _plsrccode;
    map['plsrc_name'] = _plsrcname;
    map['traflag'] = _traflag;
    return map;
  }

  SourcePlanter.fromMapObject(Map<String, dynamic> map)
    : _plsrcid = map['plsrc_id'],
      _plsrccode = map['plsrc_code'],
      _plsrcname = map['plsrc_name'],
      _traflag = map['traflag'];
}

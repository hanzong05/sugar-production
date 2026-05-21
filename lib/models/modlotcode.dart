// models/modcutter.dart
class Lots {
  final int _lotcodeid;
  final String __lotcodename;
  final int _plsrcId;
  final String _traflag;

  Lots(this._lotcodeid, this.__lotcodename, this._plsrcId, this._traflag);

  int get lotcodeid => _lotcodeid;
  String get lotcodename => __lotcodename;
  int get plsrcId => _plsrcId;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['lotcode_id'] = _lotcodeid;
    map['lotcode_name'] = __lotcodename;
    map['plsrc_id'] = _plsrcId;
    map['traflag'] = _traflag;

    return map;
  }

  Lots.fromMapObject(Map<String, dynamic> map)
    : _lotcodeid = map['lotcode_id'],
      __lotcodename = map['lotcode_name'],
      _plsrcId = map['plsrc_id'],
      _traflag = map['traflag'];
}

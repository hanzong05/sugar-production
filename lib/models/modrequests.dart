class Requests {
  final int _colReqid;
  final int _colReqno;
  final String _colReqdtr;
  final String _colReqplcode;
  final String _colReqplname;
  final String _colReqlotlocation;
  final String _colReqlothectare;
  final int _colReqttlqty;
  final int _colReqrmqty;
  final int _colReqdlqty;
  final int _colReqplId;
  final String _traflag;

  // String colTktcount = 'tktcount';
  // String colTktused = 'tktused';
  // String colTktusedupdated = 'tktusedupdated';
  // String colTktarrived = 'tktarrived';

  Requests(
    this._colReqid,
    this._colReqno,
    this._colReqdtr,
    this._colReqplcode,
    this._colReqplname,
    this._colReqlotlocation,
    this._colReqlothectare,
    this._colReqttlqty,
    this._colReqrmqty,
    this._colReqdlqty,
    this._colReqplId,
    this._traflag,
  );

  int get colReqid => _colReqid;
  String get colReqplname => _colReqplname;
  String get colReqlotlocation => _colReqlotlocation;
  String get colReqlothectare => _colReqlothectare;
  String get colReqplcode => _colReqplcode;
  int get colReqttlqty => _colReqttlqty;
  int get colReqdlqty => _colReqdlqty;
  int get colReqrmqty => _colReqrmqty;
  String get colReqdtr => _colReqdtr;
  int get colReqplId => _colReqplId;
  int get colReqno => _colReqno;
  String get traflag => _traflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['request_id'] = _colReqid;
    map['planter_name'] = _colReqplname;
    map['lot_location'] = _colReqlotlocation;
    map['area'] = _colReqlothectare;
    map['planter_code'] = _colReqplcode;
    map['qty'] = _colReqttlqty;
    map['delivered_qty'] = _colReqdlqty;
    map['remaining_qty'] = _colReqrmqty;
    map['request_date'] = _colReqdtr;
    map['request_no'] = _colReqno;
    map['planter_id'] = _colReqplId;
    map['traflag'] = _traflag;

    return map;
  }

  Requests.fromMapObject(Map<String, dynamic> map)
    : _colReqid = map['request_id'],
      _colReqplname = map['planter_name'],
      _colReqlotlocation = map['lot_location'],
      _colReqlothectare = map['area'],
      _colReqplcode = map['planter_code'],
      _colReqttlqty = map['qty'],
      _colReqdlqty = map['delivered_qty'],
      _colReqrmqty = map['remaining_qty'],
      _colReqdtr = map['request_date'],
      _colReqno = map['request_no'],
      _colReqplId = map['planter_id'],
      _traflag = map['traflag'];
}

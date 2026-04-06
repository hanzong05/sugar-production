import 'dart:typed_data';

class CPR {
  final int _colcprid;
  final String _colccprrefno;
  final int? _colcprrequestid;
  final int? _colcprlocid;
  final int? _colcprvarietyid;
  final int? _colcprplanterid;
  final int? _colcprcutterid;
  final int? _colcprqty;
  final String? _colcprdatedelivered;
  final int? _colcprcounter;
  final int? _colcprdeliveredby;
  final String? _colcprrecievedby;
  final int? _colcprseries;
  final int? _colcprsourceplanter;
  final int? _colcprcoordid;
  final int? _colcprhlngstat;
  final int? _colcprhlngqty;
  final int? _colcprcm;
  final String _colcprcmdate;
  final String _traflag;

  CPR(
    this._colcprid,
    this._colccprrefno,
    this._colcprrequestid,
    this._colcprlocid,
    this._colcprvarietyid,
    this._colcprplanterid,
    this._colcprcutterid,
    this._colcprqty,
    this._colcprdatedelivered,
    this._colcprcounter,
    this._colcprdeliveredby,
    this._colcprrecievedby,
    this._colcprseries,
    this._colcprsourceplanter,
    this._traflag,
    this._colcprcoordid,
    this._colcprhlngstat,
    this._colcprhlngqty,
    this._colcprcm,
    this._colcprcmdate,
  );

  // Getters
  int get colcprid => _colcprid;
  String get colccprrefno => _colccprrefno;
  int? get colcprrequestid => _colcprrequestid;
  int? get colcprlocid => _colcprlocid;
  int? get colcprvarietyid => _colcprvarietyid;
  int? get colcprplanterid => _colcprplanterid;
  int? get colcprcutterid => _colcprcutterid;
  int? get colcprqty => _colcprqty;
  String? get colcprdatedelivered => _colcprdatedelivered;
  int? get colcprcounter => _colcprcounter;
  int? get colcprdeliveredby => _colcprdeliveredby;
  String? get colcprrecievedby => _colcprrecievedby;
  int? get colcprseries => _colcprseries;
  int? get colcprsourceplanter => _colcprsourceplanter;
  String get traflag => _traflag;
  int? get colcprcoordid => _colcprcoordid;
  int? get colcprhlngstat => _colcprhlngstat;
  int? get colcprhlngqty => _colcprhlngqty;
  int? get colcprcm => _colcprcm;
  String get colcprcmdate => _colcprcmdate;

  Map<String, dynamic> toMap() {
    return {
      'cpr_id': _colcprid,
      'cpr_refno': _colccprrefno,
      'request_id': _colcprrequestid,
      'location_id': _colcprlocid,
      'variety_id': _colcprvarietyid,
      'planter_id': _colcprplanterid,
      'cutter_id': _colcprcutterid,
      'qty': _colcprqty,
      'delivery_date': _colcprdatedelivered,
      'print_count': _colcprcounter,
      'delivered_by_id': _colcprdeliveredby,
      'recieved_by': _colcprrecievedby,
      'series': _colcprseries,
      'source_planter': _colcprsourceplanter,
      'traflag': _traflag,
      'rcvfr_id': _colcprcoordid,
      'hauling_paid': _colcprhlngstat,
      'hauling_amount': _colcprhlngqty,
      'cuttingmode': _colcprcm,
      'cuttingdate': _colcprcmdate,
    };
  }

  CPR.fromMapObject(Map<String, dynamic> map)
    : _colcprid = map['cpr_id'],
      _colccprrefno = map['cpr_refno'],
      _colcprrequestid = map['request_id'],
      _colcprlocid = map['location_id'],
      _colcprvarietyid = map['variety_id'],
      _colcprplanterid = map['planter_id'],
      _colcprcutterid = map['cutter_id'],
      _colcprqty = map['qty'],
      _colcprdatedelivered = map['delivery_date'],
      _colcprcounter = map['print_count'],
      _colcprdeliveredby = map['delivered_by_id'],
      _colcprrecievedby = map['recieved_by'],
      _colcprseries = map['series'],
      _colcprsourceplanter = map['source_planter'],
      _traflag = map['traflag'],
      _colcprcoordid = map['rcvfr_id'],
      _colcprhlngstat = map['hauling_paid'],
      _colcprhlngqty = map['hauling_amount'],
      _colcprcm = map['cuttingmode'],
      _colcprcmdate = map['cuttingdate'];
}

// models/modcutter.dart
class LotPicture {
  final int _collpid;
  final String _collpreqid;
  final String _collandprep;
  final String _collandprepdate;
  final String _collandactual;
  final String _collandactualdate;
  final String _collptraflag;
  final String _colaptraflag;

  LotPicture(
    this._collpid,
    this._collpreqid,
    this._collandprep,
    this._collandprepdate,
    this._collandactual,
    this._collandactualdate,
    this._collptraflag,
    this._colaptraflag,
  );

  int get colcmid => _collpid;
  String get collpreqid => _collpreqid;
  String get collandprep => _collandprep;
  String get collandprepdate => _collandprepdate;
  String get collandactual => _collandactual;
  String get collandactualdate => _collandactualdate;
  String get collptraflag => _collptraflag;
  String get colaptraflag => _colaptraflag;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _collpid;
    map['request_id'] = _collpreqid;
    map['land_prep'] = _collandprep;
    map['landprep_date'] = _collandprepdate;
    map['actual_planted'] = _collandactual;
    map['actualplanted_date'] = _collandactualdate;
    map['lp_traflag'] = _collptraflag;
    map['ap_traflag'] = _colaptraflag;

    return map;
  }

  LotPicture.fromMapObject(Map<String, dynamic> map)
    : _collpid = map['id'],
      _collpreqid = map['request_id'],
      _collandprep = map['land_prep'],
      _collandprepdate = map['landprep_date'],
      _collandactual = map['actual_planted'],
      _collandactualdate = map['actualplanted_date'],
      _collptraflag = map['lp_traflag'],
      _colaptraflag = map['ap_traflag'];
}

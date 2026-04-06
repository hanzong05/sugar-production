class Notifications {
  final String _notiftitle;
  final String _notifbody;
  final String _notifdatetime;
  final int _traflag;
  final int? _notifid;

  Notifications(
    this._notiftitle,
    this._notifbody,
    this._notifdatetime,
    this._traflag, [
    this._notifid,
  ]);

  int? get notifid => _notifid;
  String get notiftitle => _notiftitle;
  String get notifbody => _notifbody;
  String get notifdatetime => _notifdatetime;
  int get traflag => _traflag;

  Notifications copyWith({
    int? notifid,
    String? notiftitle,
    String? notifbody,
    String? notifdatetime,
    int? traflag,
  }) {
    return Notifications(
      notiftitle ?? _notiftitle,
      notifbody ?? _notifbody,
      notifdatetime ?? _notifdatetime,
      traflag ?? _traflag,
      notifid ?? _notifid,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_notifid != null) map['id'] = _notifid;
    map['title'] = _notiftitle;
    map['body'] = _notifbody;
    map['date_time'] = _notifdatetime;
    map['traflag'] = _traflag;
    return map;
  }

  Notifications.fromMapObject(Map<String, dynamic> map)
    : _notiftitle = map['title'],
      _notifid = map['id'],
      _notifbody = map['body'],
      _notifdatetime = map['date_time'],
      _traflag = map['traflag'];
}

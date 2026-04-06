class UserPermissions {
  final int _moduleid;
  final int _hasaccess;

  // String colTktcount = 'tktcount';
  // String colTktused = 'tktused';
  // String colTktusedupdated = 'tktusedupdated';
  // String colTktarrived = 'tktarrived';

  UserPermissions(this._moduleid, this._hasaccess);
  int get moduleid => _moduleid;
  int get hasaccess => _hasaccess;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['module_id'] = _moduleid;
    map['has_access'] = _hasaccess;

    return map;
  }

  UserPermissions.fromMapObject(Map<String, dynamic> map)
    : _moduleid = map['module_id'],
      _hasaccess = map['has_access'];
}

class Version {
  final int _versionid;
  final String _current_version;
  // String _fcmkey;

  Version(
    this._versionid,
    this._current_version,
    // this._fcmkey,
  );

  int get usernameid => _versionid;
  String get username => _current_version;
  // String get fcmkey => _fcmkey;

  Map<String, dynamic> toMap() {
    return {'version_id': _versionid, 'old_version': _current_version};
  }

  Version.fromMapObject(Map<String, dynamic> map)
    : _versionid = map['version_id'],
      _current_version = map['old_version'];
}

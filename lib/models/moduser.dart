class User {
  final int _usernameid;
  final String _username;
  final String _password;
  final String _fullname;
  // String _fcmkey;

  User(
    this._usernameid,
    this._username,
    this._password,
    this._fullname,
    // this._fcmkey,
  );

  int get usernameid => _usernameid;
  String get username => _username;
  String get password => _password;
  String get fullname => _fullname;
  // String get fcmkey => _fcmkey;

  Map<String, dynamic> toMap() {
    return {
      'usernameid': _usernameid,
      'username': _username,
      'password': _password,
      'fullname': _fullname,
    };
  }

  User.fromMapObject(Map<String, dynamic> map)
    : _usernameid = map['usernameid'],
      _username = map['username'],
      _password = map['password'],
      _fullname = map['fullname'];
}

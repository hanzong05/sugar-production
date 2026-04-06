class Announcements {
  final int _annId;
  final String _image;
  final String _createdAt;

  Announcements(this._annId, this._image, this._createdAt);
  int get annId => _annId;
  String get image => _image;
  String get frname => _createdAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map['id'] = _annId;
    map['image'] = _image;
    map['created_at'] = _createdAt;

    return map;
  }

  Announcements.fromMapObject(Map<String, dynamic> map)
    : _annId = map['id'],
      _image = map['image'],
      _createdAt = map['created_at'];
}

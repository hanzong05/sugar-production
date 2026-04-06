import 'package:sugar_production/core/db.dart';

class AnnouncementsService {
  static Future<int> insertAnnoncement(Map<String, dynamic> location) async {
    try {
      return await DBHelper.insertGallery(location);
    } catch (e) {
      print('Error inserting location: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllAnnouncements() async {
    try {
      final db = await DBHelper.db;
      return await db.query(gallerytable, orderBy: '$colcreatedat ASC');
    } catch (e) {
      print('Error getting all announcements: $e');
      rethrow;
    }
  }
}

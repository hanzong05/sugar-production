import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:sugar_production/core/constants/globals.dart' as globals;
import 'package:sugar_production/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'package:sugar_production/core/db.dart';
import 'package:sugar_production/models/modnotif.dart';
import 'package:sugar_production/core/services/notification.dart';

Future<void> initBackgroundService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'farm_channel',
    'Sugar Production',
    description: 'Keeps API polling alive',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  await plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
      notificationChannelId: 'farm_channel',
      initialNotificationTitle: 'Sugar Production',
      initialNotificationContent: 'Listening for updates...',
      foregroundServiceNotificationId: 1,
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(const InitializationSettings(android: android));

  const tsKey = 'farm_last_ts';
  const userIdKey = 'session_usernameid';
  final prefs = await SharedPreferences.getInstance();

  String lastTimestamp = prefs.getString(tsKey) ?? '';
  String userId = prefs.getInt(userIdKey)?.toString() ?? '';

  // print('[BG SERVICE] Started for user: $userId');
  service.on('setUserId').listen((data) async {
    if (data?['user_id'] != null) {
      userId = data!['user_id'].toString();
      await prefs.setInt(
        userIdKey,
        int.tryParse(userId) ?? 0,
      ); // ✅ persist it too
      // print('[BG] user_id updated: $userId');
    }
  });

  // Future<void> pollForUser(String uid) async {
  //   try {
  //     final apiEndpoint =
  //         '${ApiConstants.baseUrl}/${ApiConstants.notifications}?usernameid=$uid';

  //     final response = await safeGet(apiEndpoint, {
  //       HttpHeaders.authorizationHeader: globals.globalhttpauth.toString(),
  //     });

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseBody = jsonDecode(response.body);
  //       final List<dynamic> messages = responseBody['notif'] ?? [];

  //       if (messages.isEmpty) return;

  //       String newestTimestamp = lastTimestamp;

  //       // ✅ Parse once outside the loop
  //       final NotificationJson notifjson = NotificationFromJson(response.body);

  //       for (var msg in messages) {
  //         final String title = msg['title']?.toString() ?? '';
  //         final String body = msg['body']?.toString() ?? '';
  //         final String timestamp = msg['trn_date']?.toString() ?? '';

  //         if (title.isEmpty && body.isEmpty && timestamp.isEmpty) continue;

  //         await plugin.show(
  //           timestamp.hashCode ^ title.hashCode,
  //           title,
  //           body,
  //           const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               'farm_channel',
  //               'Sugar Production',
  //               importance: Importance.max,
  //               priority: Priority.high,
  //             ),
  //           ),
  //         );
  //         await NotificationUtils.saveToPrefs(title, body, timestamp);
  //         if (timestamp.compareTo(newestTimestamp) > 0) {
  //           newestTimestamp = timestamp;
  //         }

  //         // print('[BG] Notified [user:$uid]: $title');
  //       }

  //       // ✅ Insert to DB once outside the loop
  //       for (var i = 0; i < notifjson.data.length; i++) {
  //         String? datetime = notifjson.data[i].datetime;
  //         String? title = notifjson.data[i].title;
  //         String? body = notifjson.data[i].body;
  //         var x = Notifications(title, body, datetime, 0);
  //         await DBHelper.insertNotif(x.toMap());
  //       }
  //       service.invoke('newNotification');
  //       if (newestTimestamp != lastTimestamp) {
  //         lastTimestamp = newestTimestamp;
  //         await prefs.setString(tsKey, lastTimestamp);
  //       }
  //     } else {
  //       print('[BG] Non-200 response: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('[BG] Poll error: $e');
  //   }
  // }

  Future<void> pollForUser(String uid) async {
    try {
      final apiEndpoint =
          '${ApiConstants.baseUrl}/${ApiConstants.notifications}?usernameid=$uid';

      final response = await safeGet(apiEndpoint, {
        HttpHeaders.authorizationHeader: globals.globalhttpauth.toString(),
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> messages = responseBody['notif'] ?? [];

        if (messages.isEmpty) return;

        String newestTimestamp = lastTimestamp;

        for (var msg in messages) {
          final String title = (msg['title'] ?? '').toString().trim();
          final String body = (msg['body'] ?? '').toString().trim();
          final String timestamp = (msg['trn_date'] ?? '').toString().trim();

          // skip completely empty item
          if (title.isEmpty && body.isEmpty && timestamp.isEmpty) {
            continue;
          }

          // skip if timestamp is empty
          if (timestamp.isEmpty) {
            continue;
          }

          // skip already processed / old notification
          if (lastTimestamp.isNotEmpty &&
              timestamp.compareTo(lastTimestamp) <= 0) {
            continue;
          }

          // show local notification
          await plugin.show(
            timestamp.hashCode ^ title.hashCode,
            title,
            body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'farm_channel',
                'Sugar Production',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );

          // save to prefs
          await NotificationUtils.saveToPrefs(title, body, timestamp);

          // save to DB
          final notif = Notifications(title, body, timestamp, 0);
          await DBHelper.insertNotif(notif.toMap());

          // update newest timestamp
          if (timestamp.compareTo(newestTimestamp) > 0) {
            newestTimestamp = timestamp;
          }
        }

        service.invoke('newNotification');

        if (newestTimestamp != lastTimestamp) {
          lastTimestamp = newestTimestamp;
          await prefs.setString(tsKey, lastTimestamp);
        }
      } else {
        // print('[BG] Non-200 response Notif: ${response.statusCode}');
      }
    } catch (e) {
      // print('[BG] Poll error: $e');
    }
  }

  // Future<void> pollForGallery() async {
  //   try {
  //     final apiEndpoint = '${ApiConstants.baseUrl}/${ApiConstants.gallery}';

  //     final response = await safeGet(apiEndpoint, {
  //       HttpHeaders.authorizationHeader: globals.globalhttpauth.toString(),
  //     });

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseBody = jsonDecode(response.body);
  //       final List<dynamic> items = responseBody['images'] ?? [];

  //       if (items.isNotEmpty) {
  //         for (var item in items) {
  //           final int id = (item['id'] as num?)?.toInt() ?? 0;
  //           final String image = item['imageblob']?.toString() ?? '';
  //           final String createdAt =
  //               item['createdat']?.toString() ??
  //               DateTime.now().toIso8601String();
  //           final int traflag = (item['traflag'] as num?)?.toInt() ?? 0;

  //           if (image.isEmpty) continue;

  //           final row = {
  //             colimageblob: image,
  //             colcreatedat: createdAt,
  //             colgallerytraflag: 'S',
  //           };
  //           if (traflag == 1) {
  //             await DBHelper.insertGallery(row);
  //           } else if (traflag == 2) {
  //             await DBHelper.updateGallery(row, id);
  //           } else if (traflag == 3) {
  //             await DBHelper.deleteGallery(id);
  //           }
  //         }

  //         service.invoke('newAnnouncement');
  //       }

  //       print('[BG] Announcements synced: ${items.length}');
  //     } else {
  //       print('[BG] Announcements non-200: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('[BG] Announcements poll error: $e');
  //   }
  // }

  service.on('setUserId').listen((data) async {
    if (data?['user_id'] != null) {
      userId = data!['user_id'].toString();
      // print('[BG] user_id updated: $userId');
    }
  });
  service.on('stop').listen((_) => service.stopSelf());

  bool isPolling = false;

  Timer.periodic(const Duration(seconds: 5), (_) async {
    if (userId.isEmpty) {
      userId = prefs.getInt(userIdKey)?.toString() ?? '';
    }

    if (userId.isEmpty) {
      // print('[BG] No user logged in — skipping');
      return;
    }

    if (isPolling) {
      // print('[BG] Already polling — skipping');
      return;
    }

    isPolling = true;
    try {
      // await Future.wait([pollForUser(userId), pollForGallery()]);

      await Future.wait([pollForUser(userId)]);
    } finally {
      isPolling = false;
    }
  });
}

http.Client _createHttpClient() {
  final context = SecurityContext.defaultContext
    ..allowLegacyUnsafeRenegotiation = true;
  final httpClient = HttpClient(context: context);
  httpClient.badCertificateCallback = (cert, host, port) => true;
  return IOClient(httpClient);
}

Future<http.Response> safeGet(String url, Map<String, String> headers) async {
  for (int attempt = 0; attempt < 2; attempt++) {
    try {
      final client = _createHttpClient();
      try {
        final response = await client
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 10));
        return response;
      } finally {
        client.close();
      }
    } catch (e) {
      final isSSLError =
          e.toString().contains('NO_RENEGOTIATION') ||
          e.toString().contains('HANDSHAKE_FAILURE') ||
          e.toString().contains('ClientException');
      if (isSSLError && attempt < 1) {
        // print('[BG] SSL error attempt ${attempt + 1}, retrying...');
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }
      rethrow;
    }
  }
  throw Exception('Failed after 2 attempts');
}

// Future<void> _saveNotifToPrefs(
//   String title,
//   String body,
//   String timestamp,
// ) async {
//   const prefKey = 'pending_notifications';
//   final prefs = await SharedPreferences.getInstance();
//   final existing = prefs.getStringList(prefKey) ?? [];
//   existing.add(
//     jsonEncode({
//       'title': title,
//       'body': body,
//       'dateTime':
//           DateTime.tryParse(timestamp)?.toIso8601String() ??
//           DateTime.now().toIso8601String(),
//     }),
//   );
// }

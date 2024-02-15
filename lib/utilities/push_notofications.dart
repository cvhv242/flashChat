import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
class PushNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;
  String? FCMToken;

  Future<String?> initialize() async {
    await _firebaseMessaging.requestPermission();
    FCMToken = await _firebaseMessaging.getToken();
    print(FCMToken);
  }

  Future<void> sendPushNotification(String? sender, String message) async {
    var body = {
      "registration_ids": [
        "cToBGgKeTUWjUib5H9NOxc:APA91bFWq8oJ9LTf7E6za426WAGE3rOC28_5aNAU-_dm0MCCg4BlHZhR4UsClPJ4L033ytXGTKXxX34Wx01q6byDqElhKMWOgXsbSk5aYRevrMf-gjDxKxFkF_1KtpJr84ljdE6L97tz",
      ],
      "notification": {
        "body": message,
        "title": sender
      }
    };
    var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders
            .authorizationHeader: 'key=AAAAK3iSvek:APA91bGXb9nIv3CLiaZBgILlIDWuATz9X_DKTy1HqYR2-JafxzUR9Ffg93lXuEWq_3l5kFgU5Bz5fbtHKBjF9sLIqdjazUOz8EgqZtveCuWa0T7j11TflNzlEn-bSe3ddGWRiAepHZUV',
      },
      body: jsonEncode(body),
    );
    print(response.statusCode);
  }
}

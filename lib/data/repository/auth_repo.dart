import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gigglio/data/data_models/notification_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';
import 'package:gigglio/data/data_provider/api_response.dart';
import 'package:gigglio/data/data_provider/dio_client.dart';
import 'package:gigglio/data/utils/app_constants.dart';

class AuthRepo {
  final DioClient dio;
  const AuthRepo({required this.dio});

  Future<void> sendNotification(
    String? token, {
    required UserDetails sender,
    required NotiCategory noti,
    Function(Map<String, dynamic> json)? onSuccess,
    Function(Map<String, dynamic> error)? onError,
  }) async {
    if (token == null) return;
    final body = {
      'to': token,
      'notification': {
        'title': noti.title,
        'body': '${sender.displayName} ${noti.desc}',
      },
      'data': {'type': noti.id, 'from': sender.id}
    };
    final options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=${dotenv.get('SERVER_KEY')}',
    });
    final url = 'https://fcm.googleapis.com/fcm/send';
    final response =
        await dio.post(url, data: body, options: options, client: dio);
    ApiResponse.verify(response,
        onSuccess: onSuccess ?? (json) => logPrint(json, 'fb noti'),
        onError: onError ?? (e) => logPrint(e, 'fb noti'));
  }
}

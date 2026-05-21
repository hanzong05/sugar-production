import 'dart:io';
import 'package:dio/dio.dart';

Dio createDio() {
  final dio = createDio();

  (dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  return dio;
}

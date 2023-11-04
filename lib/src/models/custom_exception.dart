import 'exceptions_enum.dart';

class CustomException implements Exception {
  ExceptionsEnum exception;
  String message;
  Map<String, dynamic>? data;
  CustomException(this.exception, this.message, {this.data});
}

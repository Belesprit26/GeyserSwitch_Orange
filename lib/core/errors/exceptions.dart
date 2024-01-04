import 'package:equatable/equatable.dart';
import 'package:gs_orange/core/errors/failures.dart';

class ServerException extends Equatable implements Exception {
  const ServerException({required this.message, required this.statusCode});

  final String message;
  final String statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

class CacheException extends Equatable implements Exception {
  const CacheException({required this.message, this.statusCode = 500});

  final String message;
  final int statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

class APIException extends Equatable implements Exception {
  const APIException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

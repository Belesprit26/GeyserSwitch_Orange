import 'package:equatable/equatable.dart';
import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';

abstract class LoadSheddingState extends Equatable {
  const LoadSheddingState();

  @override
  List<Object?> get props => [];
}

class LoadSheddingEmpty extends LoadSheddingState {}

class LoadSheddingLoading extends LoadSheddingState {}

class LoadSheddingLoaded extends LoadSheddingState {
  final LoadSheddingEntity result;

  const LoadSheddingLoaded(this.result);

  @override
  List<Object?> get props => [result];
}

class LoadSheddingLoadFailure extends LoadSheddingState {
  final String message;

  const LoadSheddingLoadFailure(this.message);

  List<Object?> get prope => [message];
}

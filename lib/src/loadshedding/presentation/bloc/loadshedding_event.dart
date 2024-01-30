import 'package:equatable/equatable.dart';

abstract class LoadSheddingEvent extends Equatable {
  const LoadSheddingEvent();

  @override
  List<Object?> get props => [];
}

class OnCityChanged extends LoadSheddingEvent {
  final String cityName;

  const OnCityChanged(this.cityName);

  @override
  List<Object?> get props => [cityName];
}

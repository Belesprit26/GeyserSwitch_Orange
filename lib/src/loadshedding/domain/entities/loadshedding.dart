import 'package:equatable/equatable.dart';

class LoadSheddingEntity extends Equatable {
  const LoadSheddingEntity({
    required this.cityName,
    required this.stage,
    required this.stageUpdated,
  });

  const LoadSheddingEntity.empty()
      : this(
          cityName: "National",
          stage: "_empty.stage",
          stageUpdated: "_empty.updated",
        );

  final String? cityName;
  final String? stage;
  final String? stageUpdated;

  @override
  List<Object?> get props => [
        cityName,
        stage,
        stageUpdated,
      ];
}

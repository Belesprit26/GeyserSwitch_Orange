import 'package:gs_orange/src/loadshedding/domain/entities/loadshedding.dart';

class LoadSheddingModel extends LoadSheddingEntity {
  const LoadSheddingModel({
    required String? cityName,
    required String? stage,
    required String? stageUpdated,
  }) : super(
          cityName: cityName,
          stage: stage,
          stageUpdated: stageUpdated,
        );

  factory LoadSheddingModel.fromJson(Map<String, dynamic> json) =>
      LoadSheddingModel(
        cityName: json['status']['eskom']['name'],
        stage: json['status']['eskom']['stage'],
        stageUpdated: json['status']['eskom']['stage_updated'],
      );

  Map<String, dynamic> toJson() => {
        'status': [
          {
            'eskom': [
              {
                'name': cityName,
                'stage': stage,
                'stageUpdated': stageUpdated,
              },
            ],
          },
        ],
      };
}

import 'dart:convert';

import 'package:gs_orange/core/utils/constants.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/eskom/domain/entities/eskom.dart';

class EskomModel extends Eskom {
  const EskomModel({
    required super.name,
    required super.stage,
    required super.stageUpdated,
  });

  //Empty Model for testing purposes
  const EskomModel.empty()
      : this(
          name: "National",
          stage: "_empty.stage",
          stageUpdated: "_empty.updated",
        );

  //If the data comes back as a JSON, this will help pass
  //it into the DataMap format.
  factory EskomModel.fromJson(String source) =>
      EskomModel.fromMap(jsonDecode(source) as DataMap);

/*  EskomModel.fromJson(DataMap map)
      : this(
          name: map['status']['eskom']['name'] as String,
          stage: map['status']['eskom']['stage'] as String,
          stageUpdated: map['status']['eskom']['stage_updated'] as String,
        );*/

  //This is what process the information for our use
  EskomModel.fromMap(DataMap map)
      : this(
          name: map['status']['eskom']['name'] as String,
          stage: map['status']['eskom']['stage'] as String,
          stageUpdated: map['status']['eskom']['stage_updated'] as String,
        );

  EskomModel copyWith({
    String? name,
  }) {
    return EskomModel(
      name: name,
      stage: stage,
      stageUpdated: stageUpdated,
    );
  }

  DataMap toMap() => {
        'status': [
          {
            'eskom': [
              {
                'name': name,
                'stage': stage,
                'stageUpdated': stageUpdated,
              },
            ],
          },
        ],
      };

  String toJson() => jsonEncode(toMap());
}

class StatusModel extends Status {
  const StatusModel({
    required super.eskom,
  });
  //If the data comes back as a JSON, this will help pass
  //it into the DataMap format.
  factory StatusModel.fromJson(String source) =>
      StatusModel.fromMap(jsonDecode(source) as DataMap);

  //This is what process the information for our use
  StatusModel.fromMap(DataMap map)
      : this(
          eskom: map['eskom'],
        );

  DataMap toMap() => {
        'eskom': eskom,
      };

  String toJson() => jsonEncode(toMap());
}

/*class LoadSheddingModel extends LoadShedding {
  const LoadSheddingModel({
    required super.status,
  });

  //If the data comes back as a JSON, this will help pass
  //it into the DataMap format.
  factory LoadSheddingModel.fromJson(String source) =>
      LoadSheddingModel.fromMap(jsonDecode(source) as DataMap);

  //This is what process the information for our use
  LoadSheddingModel.fromMap(DataMap map)
      : this(
          status: map['status'],
        );

  DataMap toMap() => {
        'status': status,
      };

  String toJson() => jsonEncode(toMap());
}*/

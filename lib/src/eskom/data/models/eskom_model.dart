import 'dart:convert';

import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/auth/domain/entities/eskom.dart';

class EskomModel extends Eskom {
  const EskomModel({
    required super.name,
    required super.stage,
    required super.stageUpdated,
  });

  //Empty Model for testing purposes
  const EskomModel.empty()
      : this(
          name: "_empty.name",
          stage: "_empty.stage",
          stageUpdated: "_empty.update",
        );

  //If the data comes back as a JSON, this will help pass
  //it into the DataMap format.
  factory EskomModel.fromJson(String source) =>
      EskomModel.fromMap(jsonDecode(source) as DataMap);

  //This is what process the information for our use
  EskomModel.fromMap(DataMap map)
      : this(
          name: map['status']['eskom']['name'] as String,
          stage: map['status']['eskom']['stage'] as String,
          stageUpdated: map['status']['eskom']['stage_updated'] as String,
        );
}

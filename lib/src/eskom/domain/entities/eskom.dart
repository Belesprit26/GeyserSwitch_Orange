import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:gs_orange/core/utils/constants.dart';

class Eskom extends Equatable {
  const Eskom({
    required this.name,
    required this.stage,
    required this.stageUpdated,
  });

  const Eskom.empty()
      : this(
          name: "National",
          stage: "_empty.stage",
          stageUpdated: "_empty.updated",
        );

  final String? name;
  final String? stage;
  final String? stageUpdated;

  @override
  List<Object?> get props => [name];
}

class Status extends Equatable {
  const Status({
    required this.eskom,
  });
  final Eskom? eskom;

  @override
  // TODO: implement props
  List<Object?> get props => [eskom];
}
/*
class LoadShedding extends Equatable {
  const LoadShedding({
    required this.status,
  });

  final Status? status;

  @override
  List<Object?> get props => [status];
}*/

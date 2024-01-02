import 'package:equatable/equatable.dart';

class Eskom extends Equatable {
  const Eskom({
    required this.name,
    required this.stage,
    required this.stageUpdated,
  });

  const Eskom.empty()
      : this(
            name: "_empty.name",
            stage: "_empty.stage",
            stageUpdated: "_empty.update");

  final String? name;
  final String? stage;
  final String? stageUpdated;

  @override
  List<Object?> get props => [name, stage];
}

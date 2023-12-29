import 'package:equatable/equatable.dart';

class Eskom extends Equatable {
  const Eskom({
    required this.name,
    required this.stage,
    required this.stageUpdated,
  });
  final String name;
  final String stage;
  final DateTime stageUpdated;

  @override
  List<Object?> get props => [name];
}

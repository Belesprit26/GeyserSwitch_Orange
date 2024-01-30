import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gs_orange/src/loadshedding/domain/usecases/get_current_stage.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_event.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_state.dart';
import 'package:rxdart/rxdart.dart';

class LoadSheddingBloc extends Bloc<LoadSheddingEvent, LoadSheddingState> {
  final GetCurrentStageUsecase _getCurrentStageUsecase;
  LoadSheddingBloc(this._getCurrentStageUsecase) : super(LoadSheddingEmpty()) {
    on<OnCityChanged>(
      (event, emit) async {
        emit(LoadSheddingLoading());
        final result = await _getCurrentStageUsecase.execute(event.cityName);
        result.fold(
          (failure) {
            emit(LoadSheddingLoadFailure(failure.message));
          },
          (data) {
            emit(LoadSheddingLoaded(data));
            print(data);
          },
        );
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

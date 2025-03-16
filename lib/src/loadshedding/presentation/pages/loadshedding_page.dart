import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_bloc.dart';
import 'package:gs_orange/src/loadshedding/presentation/bloc/loadshedding_state.dart';
import '../bloc/loadshedding_event.dart';

class LoadSheddingPage extends StatelessWidget {
  const LoadSheddingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1D1E22),
          title: const Text(
            'LoadShedding',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  fillColor: const Color(0xffF3F3F3),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (query) {
                  context.read<LoadSheddingBloc>().add(OnCityChanged(query));
                },
              ),
              const SizedBox(height: 32.0),
              BlocBuilder<LoadSheddingBloc, LoadSheddingState>(
                builder: (context, state) {
                  if (state is LoadSheddingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is LoadSheddingLoaded) {
                    return Column(
                      key: const Key('load shedding_data'),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.result.cityName ?? 'waiting',
                              style: const TextStyle(
                                fontSize: 22.0,
                              ),
                            ),
                            SizedBox(
                              child: const Image(
                                image: AssetImage('assets/icons/atom.png'),
                              ),
                              height: 34,
                              width: 34,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Stage: ${state.result.stage}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Table(
                          defaultColumnWidth: const FixedColumnWidth(150.0),
                          border: TableBorder.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          children: [
                            TableRow(children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Last Update',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.result.stageUpdated.toString(),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ), // Will be change later
                            ]),
                          ],
                        ),
                        Table(
                          defaultColumnWidth: const FixedColumnWidth(150.0),
                          border: TableBorder.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          children: [
                            TableRow(children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Temperature',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.result.stageUpdated.toString(),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ), // Will be change later
                            ]),
                          ],
                        ),
                      ],
                    );
                  }
                  if (state is LoadSheddingLoadFailure) {
                    return Center(
                      child: Text(state.message),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_body.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/home_button_provider.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/geyser_entity.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/home_button_1.dart';
import 'package:gs_orange/src/home/presentation/refactors/geyser_status.dart';
import 'package:gs_orange/src/home/presentation/widgets/glowy_ui/animated_glowing_border.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_app_bar.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeButtonProvider = Provider.of<HomeButtonProvider>(context);

    if (homeButtonProvider.isLoading) {
      return Scaffold(
        appBar: const HomeAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final geyserCount = homeButtonProvider.geyserList.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const HomeAppBar(),
        body: geyserCount == 0
            ? const Center(child: Text('No geysers connected'))
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 33),
            geyserCount == 1
                ? buildSingleGeyserView(homeButtonProvider.geyserList[0])
                : buildGeyserCarousel(homeButtonProvider.geyserList),
          ],
        ),
      ),
    );
  }

  Widget buildSingleGeyserView(Geyser geyser) {
    return ChangeNotifierProvider<Geyser>.value(
      value: geyser,
      child: Consumer<Geyser>(
        builder: (context, geyser, _) {
          return Column(
            children: [
              GeyserStatus(geyser: geyser),
              HomeBody(geyser: geyser),
              const SizedBox(height: 55),
              HomeButton1(geyser: geyser),
              const SizedBox(height: 45),
            ],
          );
        },
      ),
    );
  }

  Widget buildGeyserCarousel(List<Geyser> geysers) {
    return SizedBox(
      height: 600,
      child: PageView.builder(
        itemCount: geysers.length,
        itemBuilder: (context, index) {
          final geyser = geysers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: buildSingleGeyserView(geyser),
          );
        },
      ),
    );
  }
}
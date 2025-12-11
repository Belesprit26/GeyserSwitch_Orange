import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_body.dart';
import 'package:gs_orange/src/home/presentation/widgets/geyser_stats_widget.dart';
import 'package:gs_orange/src/home/presentation/providers/geyser_provider.dart';
import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';
import 'package:gs_orange/src/home/presentation/widgets/geyser_toggle_button.dart';
import 'package:gs_orange/src/home/presentation/widgets/geyser_status.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_app_bar.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_providers/timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gs_orange/src/ble/presentation/widgets/mode_indicator.dart';

import '../widgets/glowy_ui/glowy_borders.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  int _currentPage = 0;
  late final String userId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const HomeAppBar(),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Consumer<GeyserProvider>(
                  builder: (context, geyserProvider, _) {
                    if (geyserProvider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final geysers = geyserProvider.geyserList;
                    final geyserCount = geysers.length;

                    if (geyserCount == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(child: Text('No geysers connected')),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 33),
                        const ModeIndicator(),
                        const SizedBox(height: 12),
                        geyserCount == 1
                            ? buildSingleGeyserView(geysers[0])
                            : buildGeyserCarousel(geysers),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'Number of geysers: $geyserCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Displaying active timers
                        Consumer<TimerProvider>(
                          builder: (context, timerProvider, _) {
                            final activeTimers = timerProvider.getActiveTimers();
                            return activeTimers.isEmpty
                                ? const Center(
                                    child: Text('No timers are currently active.',
                                        style: TextStyle(fontSize: 16)),
                                  )
                                : Center(
                                    child: Text(
                                      'Active Timers: ${activeTimers.join(', ')}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: GeyserStatsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSingleGeyserView(GeyserEntity geyser) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth;
    
    // iPhone 15 Plus width is 430, iPhone 15 width is 393
    if (screenWidth >= 430) {
      containerWidth = screenWidth * 0.77; // For iPhone 15 Plus and larger devices
    } else if (screenWidth >= 393) {
      containerWidth = screenWidth * 0.8; // For iPhone 15
    } else {
      containerWidth = screenWidth * 0.8; // For smaller devices
    }

    return ChangeNotifierProvider<GeyserEntity>.value(
      value: geyser,
      child: Column(
        children: [
          geyser.isOn ?
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: AnimatedGradientBorder(
              borderSize: 2,
              glowSize: 5,
              gradientColors: [
                geyser.temperature >=  45 ? Colors.red.withValues(alpha:0.2) : Colors.blueAccent.withValues(alpha:0.2),
                Colors.black54.withValues(alpha:0.3),
                Colors.black87.withValues(alpha:0.3),
              ],
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).colorScheme.inversePrimary
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<GeyserEntity>(
                      builder: (context, geyser, _) {
                        return Column(
                          children: [
                            GeyserStatus(geyser: geyser),
                            HomeBody(geyser: geyser),
                            const SizedBox(height: 35),
                            GeyserToggleButton(geyser: geyser),
                            const SizedBox(height: 35),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
          : Container(
            width: containerWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 19.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: geyser.temperature >= 50 ?
                      Colors.redAccent.withValues(alpha:0.6) :
                      geyser.temperature <= 40 ?
                      Colors.blueAccent.withValues(alpha:0.6) :
                      Colors.deepOrangeAccent.withValues(alpha:0.6),
                      blurRadius: 10.0,
                      blurStyle: BlurStyle.outer
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black87.withValues(alpha:0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).colorScheme.inversePrimary
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<GeyserEntity>(
                      builder: (context, geyser, _) {
                        return Column(
                          children: [
                            GeyserStatus(geyser: geyser),
                            HomeBody(geyser: geyser),
                            const SizedBox(height: 35),
                            GeyserToggleButton(geyser: geyser),
                            const SizedBox(height: 35),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildGeyserCarousel(List<GeyserEntity> geysers) {
    return Column(
      children: [
        SizedBox(
          height: 450,
          child: PageView.builder(
            controller: _pageController,
            itemCount: geysers.length,
            pageSnapping: true,
            itemBuilder: (context, index) {
              final geyser = geysers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: buildSingleGeyserView(geyser),
              );
            },
          ),
        ),
        // Dot Indicators
       if (geysers.length >= 1) SmoothPageIndicator(
          controller: _pageController,
          count: geysers.length,
          effect: ExpandingDotsEffect(
            activeDotColor: Colors.black.withValues(alpha:0.6),
            dotHeight: 8,
            dotWidth: 8,
            spacing: 9,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
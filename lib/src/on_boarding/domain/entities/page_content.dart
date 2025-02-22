import 'package:gs_orange/core/res/media_res.dart';
import 'package:equatable/equatable.dart';

class PageContent extends Equatable {
  const PageContent({
    required this.image,
    required this.title,
    required this.description,
  });

  const PageContent.first()
      : this(
          image: MediaRes.gs_Logo,
          title: 'Welcome to GeyserSwitch',
          description:
          "Welcome to the family! GeyserSwitch is a first-of-its-kind energy management tool created with you in mind. "
              "We’re thrilled to have you with us and can’t wait for you to explore everything we’ve prepared just for you."
        );

/*  const PageContent.second()
      : this(
          image: MediaRes.gs_Logo2,
          title: 'Features available to you today',
          description:
              '- Switch your geyser on/off from anywhere in the world.\n '
              "- Set timers for off peak hours. No more cold showers.\n"
              "- See the temperature live and set your desired max temperature to maximize savings.\n",
        );

  const PageContent.third()
      : this(
          image: MediaRes.gs_Logo2,
          title: 'Simple Setup',
          description: '1) Register an account here.\n '
              '2) Power your GeyserSwitch unit up.\n'
              '3) Connect to the GeyserSwitchConnect hotspot.\n'
              '4) Enter your WiFi details, Email & Password credentials used in your registration here and your given User-ID.\n\n'
              "That's it! Enjoy...",
        );*/

  final String image;
  final String title;
  final String description;

  @override
  List<Object?> get props => [image, title, description];
}

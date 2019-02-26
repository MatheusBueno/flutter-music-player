import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'dart:math';

import 'package:music_player/theme.dart';

class PlayerController extends StatelessWidget {
  const PlayerController({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 40, bottom: 50),
        color: accentColor,
        child: Material(
          shadowColor: const Color(0x44000000),
          color: accentColor,
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Song Name',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Artist Name',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              letterSpacing: 3,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              new ButtonsController(),
            ],
          ),
        ));
  }
}

Row _rowPlaybackControll() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      new PreviousButton(),
      new PlayBackButton(),
      new NextButton(),
    ],
  );
}

class ButtonsController extends StatelessWidget {
  const ButtonsController({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 40),
      child: _rowPlaybackControll(),
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: Icon(
        Icons.skip_previous,
        color: Colors.white,
        size: 40,
      ),
      onPressed: () {
        // TODO
      },
    );
  }
}

class PlayBackButton extends StatelessWidget {
  const PlayBackButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioPlayerState,
      ],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
        IconData icon = Icons.music_note;
        Function onPressed;
        Color buttonColor = lightAccentColor;

        if (player.state == AudioPlayerState.playing) {
          icon = Icons.pause;
          onPressed = player.pause;
          buttonColor = Colors.white;
        } else if (player.state == AudioPlayerState.paused ||
            player.state == AudioPlayerState.completed) {
          icon = Icons.play_arrow;
          onPressed = player.play;
          buttonColor = Colors.white;
        }
        return IconButton(
          splashColor: Colors.white,
          color: Colors.white,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 34,
          ),
          onPressed: onPressed,
        );

        // return RawMaterialButton(
        //     shape: CircleBorder(),
        //     fillColor: buttonColor,
        //     splashColor: lightAccentColor,
        //     highlightColor: lightAccentColor.withOpacity(0.5),
        //     elevation: 10,
        //     highlightElevation: 5,
        //     onPressed: onPressed,
        //     child: Padding(
        //       padding: EdgeInsets.all(6),
        //       child: IconButton(
        //         icon: Icon(
        //           icon,
        //           color: accentColor,
        //           size: 34,
        //         ),
        //         onPressed: onPressed,
        //       ),
        //     ));
      },
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: Icon(
        Icons.skip_next,
        color: Colors.white,
        size: 40,
      ),
      onPressed: () {
        // TODO
      },
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

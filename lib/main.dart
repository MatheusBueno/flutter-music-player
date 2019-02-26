import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';

import 'package:music_player/buttons_control.dart';
import 'package:music_player/songs.dart';
import 'package:music_player/theme.dart';

import 'package:fluttery_audio/fluttery_audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    return Audio(
      audioUrl: demoPlaylist.songs[0].audioUrl,
      playbackState: PlaybackState.paused,
      child: Scaffold(
        appBar: _appBar(),
        body: Column(
          children: <Widget>[
            // Seek bar
            Expanded(
              child: AudioComponent(
                  updateMe: [
                    WatchableAudioProperties.audioPlayhead,
                    WatchableAudioProperties.audioSeeking
                  ],
                  playerBuilder:
                      (BuildContext context, AudioPlayer player, Widget child) {
                    double playbackProgress = 0;

                    if (player.audioLength != null && player.position != null) {
                      playbackProgress = player.position.inMilliseconds /
                          player.audioLength.inMilliseconds;
                    }

                    _seekPercent = player.isSeeking ? _seekPercent : null;

                    return new RadialSeekBar(
                      progress: playbackProgress,
                      seekPercent: _seekPercent,
                      onSeekRequested: (double seekPercent) {
                        setState(() => _seekPercent = seekPercent);

                        final seekMillis =
                            (player.audioLength.inMilliseconds * seekPercent)
                                .round();
                        player.seek(Duration(milliseconds: seekMillis));
                      },
                    );
                  }),
            ),
            // Visualizer
            _containerSong(),
            // Song title and controls
            new PlayerController(),
          ],
        ),
      ),
    );
  }
}

class RadialSeekBar extends StatefulWidget {
  final double progress;
  final double seekPercent;

  final Function(double) onSeekRequested;

  RadialSeekBar({
    this.seekPercent = 0,
    this.progress = 0,
    this.onSeekRequested,
  });

  @override
  RadialSeekBarState createState() {
    return new RadialSeekBarState();
  }
}

class RadialSeekBarState extends State<RadialSeekBar> {
  double _progress = 0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  void _onDragStart(PolarCoord coord) {
    print(coord);
    _startDragCoord = coord;
    _startDragPercent = _progress;
  }

  void _onDragUpdate(PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1;
    });
    print(_startDragPercent);
    print(_currentDragPercent);
  }

  void _onDragEnd() {
    if (widget.onSeekRequested != null) {
      widget.onSeekRequested(_currentDragPercent);
    }

    setState(() {
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double thumbPosition = _progress;
    if (_currentDragPercent != null) {
      thumbPosition = _currentDragPercent;
    } else if (widget.seekPercent != null) {
      thumbPosition = widget.seekPercent;
    }
    return RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: Container(
              width: 140,
              height: 140,
              child: RadialProgressBar(
                progressPercent: _progress,
                thumbPosition: thumbPosition,
                progressColor: accentColor,
                thumbsColor: lightAccentColor,
                trackColor: const Color(0xFFEEEEEE),
                innerPadding: const EdgeInsets.all(10),
                child: ClipOval(
                  clipper: CircleClipper(),
                  child: Image.network(
                    demoPlaylist.songs[0].albumArtUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

AppBar _appBar() {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0.0, // Remove shadow.
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios),
      color: const Color(0xFFDDDDDD),
      onPressed: () {},
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.menu),
        color: const Color(0xFFDDDDDD),
        onPressed: () {},
      ),
    ],
    title: Text(''),
  );
}

// Visualizer
Container _containerSong() {
  return Container(
    width: double.infinity,
    height: 150,
  );
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressPercent;
  final double progressWith;
  final Color progressColor;
  final double thumbSize;
  final Color thumbsColor;
  final double thumbPosition;
  final EdgeInsets outPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar({
    this.trackWidth = 3,
    this.trackColor = Colors.grey,
    this.progressPercent = 0,
    this.progressWith = 5,
    this.progressColor = Colors.black,
    this.thumbSize = 10,
    this.thumbsColor = Colors.black,
    this.thumbPosition = 0,
    this.innerPadding = const EdgeInsets.all(0),
    this.outPadding = const EdgeInsets.all(0),
    this.child,
  });

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPaint() {
    // Make room for the painted track, progress and thumb

    final outerThickness =
        max(widget.trackWidth, max(widget.progressWith, widget.thumbSize)) / 2;

    return EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outPadding,
      child: CustomPaint(
        foregroundPainter: RadialSeekBarPainter(
            trackWidth: widget.trackWidth,
            trackColor: widget.trackColor,
            progressWith: widget.progressWith,
            progressColor: widget.progressColor,
            progressPercent: widget.progressPercent,
            thumbSize: widget.thumbSize,
            thumbColor: widget.thumbsColor,
            thumbPosition: widget.thumbPosition),
        child: Padding(
          padding: _insetsForPaint() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressPercent;
  final Paint progressPain;
  final double progressWith;
  final Paint thumbPaint;
  final double thumbSize;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required this.progressPercent,
    @required this.progressWith,
    @required this.thumbSize,
    @required this.thumbPosition,
    @required trackColor,
    @required progressColor,
    @required thumbColor,
  })  : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPain = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWith
          ..strokeCap = StrokeCap.round,
        thumbPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWith, thumbSize));
    Size constrainedSize = Size(
      size.width - outerThickness,
      size.height - outerThickness,
    );

    // Paint track
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;

    canvas.drawCircle(center, radius, trackPaint);

    // Paint progress
    final progressAngle = 2 * pi * progressPercent;

    canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -pi / 2,
        progressAngle,
        false,
        progressPain);

    // Paint thumb.

    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbSize / 2;

    canvas.drawCircle(
      thumbCenter,
      thumbRadius,
      thumbPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

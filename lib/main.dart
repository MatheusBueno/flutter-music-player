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
    return AudioPlaylist(
      playlist: demoPlaylist.songs
          .map((DemoSong song) => song.audioUrl)
          .toList(growable: false),
      playbackState: PlaybackState.paused,
      child: Scaffold(
        appBar: _appBar(),
        body: Column(
          children: <Widget>[
            // Seek bar
            Expanded(
              child: AudioPlaylistComponent(
                playlistBuilder:
                    (BuildContext context, Playlist playlist, Widget child) {
                  String albumArtUrl =
                      demoPlaylist.songs[playlist.activeIndex].albumArtUrl;

                  return AudioComponent(
                      updateMe: [
                        WatchableAudioProperties.audioPlayhead,
                        WatchableAudioProperties.audioSeeking
                      ],
                      playerBuilder: (BuildContext context, AudioPlayer player,
                          Widget child) {
                        double playbackProgress = 0;

                        if (player.audioLength != null &&
                            player.position != null) {
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
                                (player.audioLength.inMilliseconds *
                                        seekPercent)
                                    .round();
                            player.seek(Duration(milliseconds: seekMillis));
                          },
                          child: Container(
                            color: accentColor,
                            child: Image.network(
                              albumArtUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      });
                },
              ),
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
  final Widget child;

  final Function(double) onSeekRequested;

  RadialSeekBar({
    this.seekPercent = 0,
    this.progress = 0,
    this.onSeekRequested,
    this.child,
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
                  child: widget.child,
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

class VisualizerPainter extends CustomPainter {
  final List<int> fft;
  final double height;
  final Color color;
  final Paint wavePaint;

  VisualizerPainter({
    this.fft,
    this.height,
    this.color,
  }) : wavePaint = new Paint()
          ..color = color.withOpacity(0.75)
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    _renderWaves(canvas, size);
  }

  void _renderWaves(Canvas canvas, Size size) {
    final histogramLow =
        _createHistogram(fft, 15, 2, ((fft.length) / 4).floor());
    final histogramHigh = _createHistogram(
        fft, 15, (fft.length / 4).ceil(), (fft.length / 2).floor());

    _renderHistogram(canvas, size, histogramLow);
    _renderHistogram(canvas, size, histogramHigh);
  }

  void _renderHistogram(Canvas canvas, Size size, List<int> histogram) {
    if (histogram.length == 0) {
      return;
    }

    final pointsToGraph = histogram.length;
    final widthPerSample = (size.width / (pointsToGraph - 2)).floor();

    final points = new List<double>.filled(pointsToGraph * 4, 0.0);

    for (int i = 0; i < histogram.length - 1; ++i) {
      points[i * 4] = (i * widthPerSample).toDouble();
      points[i * 4 + 1] = size.height - histogram[i].toDouble();

      points[i * 4 + 2] = ((i + 1) * widthPerSample).toDouble();
      points[i * 4 + 3] = size.height - (histogram[i + 1].toDouble());
    }

    Path path = new Path();
    path.moveTo(0.0, size.height);
    path.lineTo(points[0], points[1]);
    for (int i = 2; i < points.length - 4; i += 2) {
      path.cubicTo(points[i - 2] + 10.0, points[i - 1], points[i] - 10.0,
          points[i + 1], points[i], points[i + 1]);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  List<int> _createHistogram(List<int> samples, int bucketCount,
      [int start, int end]) {
    if (start == end) {
      return const [];
    }

    start = start ?? 0;
    end = end ?? samples.length - 1;
    final sampleCount = end - start + 1;

    final samplesPerBucket = (sampleCount / bucketCount).floor();
    if (samplesPerBucket == 0) {
      return const [];
    }

    final actualSampleCount = sampleCount - (sampleCount % samplesPerBucket);
    List<int> histogram = new List<int>.filled(bucketCount, 0);

    // Add up the frequency amounts for each bucket.
    for (int i = start; i <= start + actualSampleCount; ++i) {
      // Ignore the imaginary half of each FFT sample
      if ((i - start) % 2 == 1) {
        continue;
      }

      int bucketIndex = ((i - start) / samplesPerBucket).floor();
      histogram[bucketIndex] += samples[i];
    }

    // Massage the data for visualization
    for (var i = 0; i < histogram.length; ++i) {
      histogram[i] = (histogram[i] / samplesPerBucket).abs().round();
    }

    return histogram;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
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

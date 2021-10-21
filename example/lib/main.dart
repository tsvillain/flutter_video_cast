import 'package:flutter/material.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CastSample());
  }
}

class CastSample extends StatefulWidget {
  static const _iconSize = 50.0;

  @override
  _CastSampleState createState() => _CastSampleState();
}

class _CastSampleState extends State<CastSample> {
  ChromeCastController _controller;
  // VideoPlayerController _videoController;
  AppState _state = AppState.idle;
  bool _playing = false;
  // static const String videoUrl =
  //     'https://player.vimeo.com/external/605412753.m3u8?s=b6e3a93a339e449ad7723e4458a54ddeebd309f9';
  @override
  void initState() {
    // _videoController = VideoPlayerController.network(videoUrl);
    // _videoController.initialize().then((value) {
    //   // setState(() {});
    //   // _videoController.play();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plugin example app'),
        actions: <Widget>[
          AirPlayButton(
            size: CastSample._iconSize,
            color: Colors.white,
            activeColor: Colors.amber,
            onRoutesOpening: () => print('opening'),
            onRoutesClosed: () => print('closed'),
          ),
          ChromeCastButton(
            size: CastSample._iconSize,
            color: Colors.white,
            onButtonCreated: _onButtonCreated,
            onSessionStarted: _onSessionStarted,
            onSessionEnded: () {
              setState(() => _state = AppState.idle);
              // _videoController.play();
            },
            onRequestCompleted: _onRequestCompleted,
            onRequestFailed: _onRequestFailed,
          ),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(
          //   width: double.maxFinite,
          //   child: _videoController.value.isInitialized
          //       ? AspectRatio(
          //           aspectRatio: _videoController.value.aspectRatio,
          //           child: VideoPlayer(_videoController),
          //         )
          //       : Container(),
          // ),
          Text("random text"),
          SizedBox(
            height: 10,
          ),
          _mediaControls()
        ],
      )),
    );
  }

  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        return Text('ChromeCast not connected');
      case AppState.connected:
        return Text('No media loaded');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return Text('An error has occurred');
      default:
        return Container();
    }
  }

  Widget _mediaControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.replay_10,
          onPressed: _backward,
        ),
        _RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: _playPause),
        _RoundIconButton(
          icon: Icons.forward_10,
          onPressed: _forward,
        )
      ],
    );
  }

  Future<void> _forward() async {
    final playing =
        await _controller.isConnected() && await _controller.isPlaying();
    if (playing) {
      _controller.seek(relative: true, interval: 10.0);
    }
    // else {
    //   final currentPosition = await _videoController.position;
    //   _videoController.seekTo(currentPosition + Duration(seconds: 10));
    // }
    setState(() => _playing = !playing);
  }

  Future<void> _backward() async {
    final playing =
        await _controller.isConnected() && await _controller.isPlaying();
    if (playing) {
      _controller.seek(relative: true, interval: -10.0);
    }
    // else {
    //   final currentPosition = await _videoController.position;
    //   _videoController.seekTo(currentPosition - Duration(seconds: 10));
    // }
    setState(() => _playing = !playing);
  }

  Future<void> _playPause() async {
    final playing = await _controller.isPlaying();
    if (playing) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    setState(() => _playing = !playing);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    try {
      await _controller.addSessionListener();
      print("{{{}}} Connected: (on btn created) " +
          (await _controller.isConnected()).toString());
    } catch (e) {
      print("err: ${e.toString()}");
    }
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
    print("{{{}}} Connected: (onSessionStarted) " +
        (await _controller.isConnected()).toString());
    try {
      await _controller.loadMedia(
          'https://player.vimeo.com/external/605412753.m3u8?s=b6e3a93a339e449ad7723e4458a54ddeebd309f9');
      print("{{{}}} Media loaded");
      try {
        await _controller.play();
        print("{{{}}} started playing");
      } catch (e) {
        print("{{{}}} Play Failed: ${e.toString()}");
      }
    } catch (e) {
      print("{{{}}} Media load failed : ${e.toString()}");
    }

    // final duration = await _videoController.position;
    // await Future.delayed(Duration(seconds: 5));
    // await _videoController.pause();
    // _controller.seek(interval: duration.inSeconds.toDouble(), relative: true);
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    print("{{{}}} Playing : $playing");
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
    });
  }

  Future<void> _onRequestFailed(String error) async {
    setState(() => _state = AppState.error);
    print("{{{}}} Request Failed: ${error.toString()}");
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  _RoundIconButton({@required this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Icon(icon, color: Colors.white),
        padding: EdgeInsets.all(16.0),
        color: Colors.blue,
        shape: CircleBorder(),
        onPressed: onPressed);
  }
}

enum AppState { idle, connected, mediaLoaded, error }

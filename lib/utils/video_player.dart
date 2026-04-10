import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../base_url.dart';
import 'url_helper.dart';

class NetworkVideoPlayer extends StatefulWidget {
  const NetworkVideoPlayer({super.key,required this.videoUrl});

  final String videoUrl;

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;


  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(UrlHelper.getFullImageUrl(widget.videoUrl)));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowPlaybackSpeedChanging: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white70,
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _chewieController != null &&
            _chewieController!
                .videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}

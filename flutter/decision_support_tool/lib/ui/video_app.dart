import 'package:flutter/material.dart';
import 'package:web/web.dart';

class VideoApp extends StatelessWidget {
  final String videoId; // ID of video file
  const VideoApp({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    // The video is an <iframe> platform view: a real DOM element living
    // outside Flutter's own canvas/hit-testing. A Flutter-painted modal
    // barrier (e.g. from showDialog) cannot stop the browser from routing
    // clicks straight to it, since an iframe is its own browsing context.
    // So instead of relying on visual layering, don't mount the iframe at
    // all whenever this widget's route is covered by another route (a
    // dialog pushed on top of it) — with nothing in the DOM, there is
    // nothing for a click to reach.
    final isCoveredByAnotherRoute = !(ModalRoute.of(context)?.isCurrent ?? true);
    if (isCoveredByAnotherRoute) {
      return const ColoredBox(
        color: Colors.black12,
        child: Center(
          child: Icon(Icons.videocam_off, color: Colors.black38, size: 32.0),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0x00000000),
      body: HtmlElementView.fromTagName(
        tagName: 'iframe',
        onElementCreated: (Object iframe) {
          iframe as HTMLIFrameElement;
          iframe.src = 'https://drive.google.com/file/d/${videoId}/preview';
          iframe.width = '480';
          iframe.height = '640';
          iframe.allow = 'autoplay';
        },
      ),
    );
  }
}

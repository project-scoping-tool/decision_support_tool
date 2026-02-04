import 'package:flutter/material.dart';
import 'package:web/web.dart';

class VideoApp extends StatelessWidget {
  final String videoId; // ID of video file
  const VideoApp({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
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

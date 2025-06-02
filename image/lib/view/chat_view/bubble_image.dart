import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../model/chat_message.dart';

import '../../services/api_base_url.dart';
import '../../utils/constant_file.dart';
import '../../utils/responsive.dart';

import '../loader/discrete_circular_indicator.dart';
import 'base_message_bubble.dart';

/// detail screen of the image, display when tap on the image bubble
class DetailScreen extends StatelessWidget {
  final String tag;
  final Widget image;

  const DetailScreen({super.key, required this.tag, required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(body: Center(child: Hero(tag: tag, child: image))),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class ImageMessage extends StatelessWidget {
  const ImageMessage({
    super.key,

    this.previousElement,
    required this.currentElement,
    this.nextElement,
    required this.isLoading,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.onTap,
    this.bubbleRadius = 16,
  });

  final ChatMessage? previousElement;
  final ChatMessage currentElement;
  final ChatMessage? nextElement;
  final bool isLoading;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double bubbleRadius;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, res) {
        return BaseMessageBubble(
          currentElement: currentElement,
          previousElement: previousElement,
          nextElement: nextElement,
          messageContent: currentElement.isSender ? Text(currentElement.text) : imageWidget(currentElement.text, context),
          loadingContent: DiscreteColorCircularLoader(),
        );
      },
    );
  }

  Widget _image(String imageUrl) {
    // Check if the imageUrl is valid
    if (Uri.tryParse(imageUrl)?.hasScheme != true) {
      return const Icon(Icons.error); // Display an error icon if the URL is invalid
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 20.0, minWidth: 20.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  imageWidget(String imageUrl, context) {
    if (imageUrl.contains(ApiBaseUrls.cloudinaryFetchUrl)) {
      return GestureDetector(
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(tag: '${currentElement.text}_${DateTime.now().millisecondsSinceEpoch}', image: _image(currentElement.text))),
              );
            },
        child: Hero(
          tag: '${currentElement.text}_${DateTime.now().millisecondsSinceEpoch}',
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ClipRRect(borderRadius: BorderRadius.circular(bubbleRadius), child: _image(currentElement.text)),
          ),
        ),
      );
    } else {
      return Text(imageUrl);
    }
  }
}

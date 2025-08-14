import 'dart:typed_data';
import 'package:flutter/material.dart';

class SavePage extends StatefulWidget {
  final String? imageUrl;
  final Uint8List? imageData;
  
  const SavePage({
    Key? key, 
    this.imageUrl,
    this.imageData,
  }) : super(key: key);

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  late Future<ImageProvider>? _imageFuture;

  Future<ImageProvider> _loadImage(String url) async {
    try {
      final image = NetworkImage(url);
      // Try to resolve the image to check if it loads
      await precacheImage(image, context);
      return image;
    } catch (_) {
      return const AssetImage('assets/placeholder.png');
    }
  }

  @override
  void initState() {
    super.initState();
    // Only load from URL if we have a URL and no image data
    if (widget.imageUrl != null && widget.imageData == null) {
      _imageFuture = _loadImage(widget.imageUrl!);
    } else {
      _imageFuture = null;
    }
  }

  Widget _buildImageDisplay() {
    if (widget.imageData != null) {
      // Display image from memory (imageData)
      return Image.memory(
        widget.imageData!,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: child,
          );
        },
      );
    } else if (widget.imageUrl != null && _imageFuture != null) {
      // Display image from URL
      return FutureBuilder<ImageProvider>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          } else {
            return Image(
              image: snapshot.data!,
              fit: BoxFit.cover,
            );
          }
        },
      );
    } else {
      // No image data or URL provided
      return const Center(
        child: Text(
          'No image data',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/gallery');
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Image Saved !',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[900],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImageDisplay(),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF18181C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _FormatButton(selected: true, label: 'PNG'),
                      const SizedBox(width: 12),
                      _FormatButton(selected: false, label: 'JPG'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Images will not have transparency and will be smaller in file size',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ResolutionOption(selected: true, label: '1080P'),
                      _ResolutionOption(selected: false, label: '1920P', isPro: true),
                      _ResolutionOption(selected: false, label: '2664P', isPro: true),
                      _ResolutionOption(selected: false, label: '4096P', isPro: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ScaleOption(selected: false, label: '1X'),
                      const SizedBox(width: 10),
                      _ScaleOption(selected: true, label: '2X'),
                      const SizedBox(width: 10),
                      _ScaleOption(selected: false, label: '4X'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your image will be exported at 1080x1920. This is great for exact others.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Download logic here
                      },
                      child: const Text(
                        'Download',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final bool selected;
  final String label;
  const _FormatButton({required this.selected, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResolutionOption extends StatelessWidget {
  final bool selected;
  final String label;
  final bool isPro;
  const _ResolutionOption({required this.selected, required this.label, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        if (isPro)
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.workspace_premium, color: Colors.redAccent, size: 16),
          ),
      ],
    );
  }
}

class _ScaleOption extends StatelessWidget {
  final bool selected;
  final String label;
  const _ScaleOption({required this.selected, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
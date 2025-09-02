import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ObjectSelectionWidget extends StatefulWidget {
  final Uint8List imageData;
  final Function(Uint8List) onMaskCreated;
  final Function(Uint8List, Uint8List) onProcessRemoval; // Add callback for processing
  final bool isAutoDetect;

  const ObjectSelectionWidget({
    super.key,
    required this.imageData,
    required this.onMaskCreated,
    required this.onProcessRemoval, // Required callback
    this.isAutoDetect = false,
  });

  @override
  State<ObjectSelectionWidget> createState() => _ObjectSelectionWidgetState();
}

class _ObjectSelectionWidgetState extends State<ObjectSelectionWidget> {
  List<Path> drawnPaths = [];
  List<Rect> detectedObjects = [];
  List<bool> selectedObjects = [];
  bool isDrawing = false;
  bool isProcessing = false; // Add processing state
  String processingStatus = '';
  ui.Image? decodedImage;
  double imageScale = 1.0;
  Offset imageOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
    if (widget.isAutoDetect) {
      _autoDetectObjects();
    }
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageData);
    final frame = await codec.getNextFrame();
    setState(() {
      decodedImage = frame.image;
    });
  }

  Future<void> _autoDetectObjects() async {
    // Simulate object detection (in real app, you'd use ML models like TensorFlow Lite)
    // For demo, create some mock detected objects
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (decodedImage != null) {
      setState(() {
        detectedObjects = [
          Rect.fromLTWH(50, 50, 100, 120),
          Rect.fromLTWH(200, 80, 80, 100),
          Rect.fromLTWH(120, 200, 150, 180),
        ];
        selectedObjects = List.filled(detectedObjects.length, false);
      });
    }
  }

  void _toggleObjectSelection(int index) {
    setState(() {
      selectedObjects[index] = !selectedObjects[index];
    });
  }

Future<Uint8List> _createMaskFromSelection() async {
  if (decodedImage == null) throw Exception('Image not loaded');

  // USE ORIGINAL IMAGE DIMENSIONS - This is crucial!
  final originalWidth = decodedImage!.width;
  final originalHeight = decodedImage!.height;
  
  print('DEBUG: Creating mask with original image dimensions: ${originalWidth}x${originalHeight}');

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Create black background with EXACT original dimensions
  canvas.drawRect(
    Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
    Paint()..color = Colors.black,
  );

  if (widget.isAutoDetect) {
    // Auto-detect mode: draw selected rectangles in WHITE
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < detectedObjects.length; i++) {
      if (selectedObjects[i]) {
        // These rectangles are already in original image coordinates
        canvas.drawRect(detectedObjects[i], paint);
      }
    }
  } else {
    // Manual mode: draw paths in WHITE
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 40.0  // Adjust based on image size
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final path in drawnPaths) {
      // IMPORTANT: Scale paths to original image coordinates
      final scaledPath = _scalePathToOriginalImage(path, originalWidth, originalHeight);
      canvas.drawPath(scaledPath, fillPaint);
      canvas.drawPath(scaledPath, paint);
    }
  }

  // Convert to image with EXACT original dimensions
  final picture = recorder.endRecording();
  final image = await picture.toImage(originalWidth, originalHeight);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  final maskBytes = byteData!.buffer.asUint8List();
  print('DEBUG: Created mask with dimensions: ${originalWidth}x${originalHeight}');
  print('DEBUG: Mask size: ${maskBytes.length} bytes');

  return maskBytes;
}

// Helper method to scale drawing paths to original image coordinates
Path _scalePathToOriginalImage(Path originalPath, int targetWidth, int targetHeight) {
  // Get the display widget size
  final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
  if (renderBox == null) return originalPath;
  
  final displaySize = renderBox.size;
  final scaleX = targetWidth / displaySize.width;
  final scaleY = targetHeight / displaySize.height;
  
  final Matrix4 scaleMatrix = Matrix4.identity()
    ..scale(scaleX, scaleY);
  
  return originalPath.transform(scaleMatrix.storage);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          widget.isAutoDetect ? 'Select Objects to Remove' : 'Draw to Select Objects',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!widget.isAutoDetect)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  drawnPaths.clear();
                });
              },
            ),
          IconButton(
            icon: isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : const Icon(Icons.check, color: Colors.green),
            onPressed: isProcessing ? null : () async {
              try {
                // Validate selection
                if (widget.isAutoDetect) {
                  if (!selectedObjects.any((selected) => selected)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one object to remove')),
                    );
                    return;
                  }
                } else {
                  if (drawnPaths.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please draw around objects you want to remove')),
                    );
                    return;
                  }
                }

                setState(() {
                  isProcessing = true;
                  processingStatus = 'Creating mask...';
                });

                print('DEBUG: Creating mask from selection...');
                final mask = await _createMaskFromSelection();
                
                setState(() {
                  processingStatus = 'Removing objects...';
                });

                // Automatically process the removal
                await widget.onProcessRemoval(widget.imageData, mask);
                
                // Close the selection screen after processing
                Navigator.pop(context, true); // Return true to indicate success
              } catch (e) {
                print('ERROR: Failed to process removal: $e');
                setState(() {
                  isProcessing = false;
                  processingStatus = '';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: decodedImage == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.isAutoDetect && detectedObjects.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[800],
                    width: double.infinity,
                    child: const Text(
                      'Tap on the objects you want to remove:',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Processing status overlay
                if (isProcessing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[800],
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          processingStatus,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: widget.isAutoDetect
                          ? _buildAutoDetectView()
                          : _buildManualDrawView(),
                    ),
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
    );
  }

  Widget _buildAutoDetectView() {
    return Stack(
      children: [
        Center(
          child: Image.memory(
            widget.imageData,
            fit: BoxFit.contain,
          ),
        ),
        // Overlay detected objects
        ...detectedObjects.asMap().entries.map((entry) {
          final index = entry.key;
          final rect = entry.value;
          final isSelected = selectedObjects[index];
          
          return Positioned(
            left: rect.left,
            top: rect.top,
            child: GestureDetector(
              onTap: () => _toggleObjectSelection(index),
              child: Container(
                width: rect.width,
                height: rect.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.blue,
                    width: 3,
                  ),
                  color: isSelected 
                      ? Colors.red.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.2),
                ),
                child: Center(
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.red : Colors.blue,
                    size: 30,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildManualDrawView() {
    return Stack(
      children: [
        // Background image
        Center(
          child: Image.memory(
            widget.imageData,
            fit: BoxFit.contain,
          ),
        ),
        // Drawing overlay
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                isDrawing = true;
                drawnPaths.add(Path()..moveTo(details.localPosition.dx, details.localPosition.dy));
              });
              print('DEBUG: Started drawing at ${details.localPosition}');
            },
            onPanUpdate: (details) {
              if (isDrawing && drawnPaths.isNotEmpty) {
                setState(() {
                  drawnPaths.last.lineTo(details.localPosition.dx, details.localPosition.dy);
                });
                print('DEBUG: Drawing to ${details.localPosition}');
              }
            },
            onPanEnd: (details) {
              setState(() {
                isDrawing = false;
              });
              print('DEBUG: Finished drawing. Total paths: ${drawnPaths.length}');
            },
            child: CustomPaint(
              painter: ObjectSelectionPainter(
                imageData: widget.imageData,
                paths: drawnPaths,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.isAutoDetect) ...[
            Text(
              'Selected: ${selectedObjects.where((s) => s).length}/${detectedObjects.length}',
              style: const TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedObjects = List.filled(detectedObjects.length, true);
                });
              },
              child: const Text('Select All'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedObjects = List.filled(detectedObjects.length, false);
                });
              },
              child: const Text('Clear All'),
            ),
          ] else ...[
            const Text(
              'Draw around objects to remove',
              style: TextStyle(color: Colors.white),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  drawnPaths.clear();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

class ObjectSelectionPainter extends CustomPainter {
  final Uint8List imageData;
  final List<Path> paths;

  ObjectSelectionPainter({
    required this.imageData,
    required this.paths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the selection paths with a more visible style
    final pathPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw a white border around the red path for better visibility
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 16.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in paths) {
      // Draw white border first
      canvas.drawPath(path, borderPaint);
      // Draw red path on top
      canvas.drawPath(path, pathPaint);
    }

    // Draw selection area fill with transparency
    final fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (final path in paths) {
      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

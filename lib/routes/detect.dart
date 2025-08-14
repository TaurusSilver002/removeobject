import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:objectremove/services/app_translations.dart';
import 'package:objectremove/routes/save.dart';

class DetectPage extends StatefulWidget {
  final AssetEntity asset;

  const DetectPage({super.key, required this.asset});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  Uint8List? imageData;
  bool isLoading = true;
  bool isFullResolution = true;
  int brushSize = 28;
  bool isEraseMode = true;
  int selectedToolIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFullResolution();
  }

  Future<void> _loadFullResolution() async {
    setState(() => isLoading = true);
    try {
      final data = await widget.asset.originBytes;
      setState(() {
        imageData = data;
        isLoading = false;
        isFullResolution = true;
      });
    } catch (e) {
      print('Error loading image: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 12),
                _buildCenterControls(),
                const SizedBox(height: 12),
                _buildImageDisplay(),
                const SizedBox(height: 12),
                _buildBrushControls(),
                const SizedBox(height: 12),
                _buildBottomTools(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          TranslatableText(
            'Remove Object',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              // Pass the actual image data to save page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavePage(
                    imageData: imageData, // Pass the actual loaded image data
                  ),
                ),
              );
            },
            child: TranslatableText(
              'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _roundButton(Icons.undo, () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Undo')));
        }),
        const SizedBox(width: 20),
        _roundButton(Icons.redo, () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Redo')));
        }),
        const SizedBox(width: 20),
        _roundButton(Icons.settings, () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings')));
        }),
      ],
    );
  }

  Widget _buildImageDisplay() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade800,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageData != null
              ? Image.memory(
                  imageData!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildBrushControls() {
    return Column(
      children: [
        ToggleButtons(
          borderRadius: BorderRadius.circular(30),
          isSelected: [isEraseMode, !isEraseMode],
          onPressed: (index) {
            setState(() {
              isEraseMode = index == 0;
            });
          },
          selectedColor: Colors.black,
          fillColor: isEraseMode ? Colors.redAccent : Colors.yellow,
          color: Colors.white,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('⚡ Erase'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('✨ Replace'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              value: brushSize.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: Colors.redAccent,
              inactiveColor: Colors.white30,
              onChanged: (value) {
                setState(() {
                  brushSize = value.toInt();
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              '$brushSize',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            )
          ],
        )
      ],
    );
  }

  Widget _buildBottomTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _toolButton('Object', Icons.chat_bubble_outline, 0),
          _toolButton('Eraser', Icons.close, 1),
          _toolButton('Detect', Icons.find_in_page, 2),
          _toolButton('Manual', Icons.touch_app, 3),
          _toolButton('Expand', Icons.open_in_full, 4),
        ],
      ),
    );
  }

  Widget _toolButton(String label, IconData icon, int index) {
    final isSelected = selectedToolIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedToolIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? const Color.fromARGB(78, 244, 67, 54) : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.redAccent : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade800,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

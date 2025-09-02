import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:objectremove/services/app_translations.dart';
import 'package:objectremove/services/image_processing_api.dart';
import 'package:objectremove/routes/save.dart';
import 'package:objectremove/widgets/object_selection_widget.dart';

class DetectPage extends StatefulWidget {
  final AssetEntity asset;

  const DetectPage({super.key, required this.asset});

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  Uint8List? imageData;
  Uint8List? processedImageData; // Processed image from API
  bool isLoading = true;
  bool isProcessing = false; // API processing state
  bool isFullResolution = true;
  int brushSize = 28;
  bool isEraseMode = true;
  int selectedToolIndex = 0;
  String processingStatus = ''; // Status message for user

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

  // API Processing Methods
  Future<void> _removeBackground() async {
    print('DEBUG: _removeBackground called');
    
    if (imageData == null) {
      print('DEBUG: imageData is null');
      _showErrorSnackBar('No image loaded');
      return;
    }

    print('DEBUG: Starting background removal');
    setState(() {
      isProcessing = true;
      processingStatus = 'Removing background...';
    });

    try {
      print('DEBUG: Calling ImageProcessingAPI.removeBackground');
      final resultUrl = await ImageProcessingAPI.removeBackground(imageData!);
      print('DEBUG: Got result URL: $resultUrl');
      
      print('DEBUG: Downloading processed image');
      final processedData = await ImageProcessingAPI.downloadImage(resultUrl);
      print('DEBUG: Downloaded ${processedData.length} bytes');
      
      setState(() {
        processedImageData = processedData;
        isProcessing = false;
        processingStatus = '';
      });

      print('DEBUG: Background removal completed successfully');
      _showSuccessSnackBar('Background removed successfully!');
    } catch (e) {
      print('DEBUG: Error in background removal: $e');
      setState(() {
        isProcessing = false;
        processingStatus = '';
      });
      _showErrorSnackBar('Failed to remove background: $e');
    }
  }

  // Wrapper function to log button press
  void _onGenerateBackgroundPressed() {
    print('DEBUG: ===== GENERATE BACKGROUND BUTTON PRESSED =====');
    print('DEBUG: Current time: ${DateTime.now()}');
    print('DEBUG: isProcessing: $isProcessing');
    print('DEBUG: Button should be enabled: ${!isProcessing}');
    _generateBackground();
  }

  Future<void> _generateBackground() async {
    print('DEBUG: ========== GENERATE BACKGROUND START ==========');
    print('DEBUG: _generateBackground called');
    print('DEBUG: Current isProcessing state: $isProcessing');
    print('DEBUG: imageData null check: ${imageData == null}');
    
    if (imageData == null) {
      print('DEBUG: ERROR - imageData is null, showing error snackbar');
      _showErrorSnackBar('No image loaded');
      return;
    }

    print('DEBUG: imageData available, size: ${imageData!.length} bytes');
    print('DEBUG: About to show prompt dialog...');
    
    // Show dialog to get text prompt
    String? textPrompt;
    try {
      textPrompt = await _showPromptDialog();
      print('DEBUG: Dialog completed, result: "$textPrompt"');
      print('DEBUG: Prompt is null: ${textPrompt == null}');
      print('DEBUG: Prompt is empty: ${textPrompt?.isEmpty ?? true}');
    } catch (e) {
      print('DEBUG: ERROR in dialog: $e');
      _showErrorSnackBar('Error showing dialog: $e');
      return;
    }
    
    if (textPrompt == null || textPrompt.isEmpty) {
      print('DEBUG: User cancelled or entered empty prompt, returning');
      return;
    }

    print('DEBUG: Valid prompt received: "$textPrompt"');
    print('DEBUG: Setting processing state to true...');
    
    setState(() {
      isProcessing = true;
      processingStatus = 'Generating background...';
    });

    print('DEBUG: Processing state set, calling API...');

    try {
      print('DEBUG: Calling ImageProcessingAPI.generateBackground with:');
      print('DEBUG: - Image size: ${imageData!.length} bytes');
      print('DEBUG: - Text prompt: "$textPrompt"');
      
      final resultUrl = await ImageProcessingAPI.generateBackground(imageData!, textPrompt);
      print('DEBUG: API call successful! Result URL: $resultUrl');
      
      print('DEBUG: Starting image download...');
      final processedData = await ImageProcessingAPI.downloadImage(resultUrl);
      print('DEBUG: Download successful! Downloaded ${processedData.length} bytes');
      
      print('DEBUG: Setting processed image data and updating state...');
      setState(() {
        processedImageData = processedData;
        isProcessing = false;
        processingStatus = '';
      });

      print('DEBUG: State updated successfully');
      print('DEBUG: Showing success message...');
      _showSuccessSnackBar('Background generated successfully!');
      print('DEBUG: ========== GENERATE BACKGROUND SUCCESS ==========');
    } catch (e) {
      print('DEBUG: ========== GENERATE BACKGROUND ERROR ==========');
      print('DEBUG: Exception caught: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      print('DEBUG: Stack trace will follow...');
      print('DEBUG: Resetting processing state...');
      
      setState(() {
        isProcessing = false;
        processingStatus = '';
      });
      
      print('DEBUG: Showing error message to user...');
      _showErrorSnackBar('Failed to generate background: $e');
      print('DEBUG: ========== GENERATE BACKGROUND ERROR END ==========');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TranslatableText(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<String?> _showPromptDialog() async {
    print('DEBUG: _showPromptDialog called');
    TextEditingController controller = TextEditingController();
    
    print('DEBUG: Creating dialog...');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        print('DEBUG: Dialog builder called');
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: TranslatableText(
            'Generate Background',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TranslatableText(
                'Describe the background you want to generate:',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., beautiful sunset beach, city skyline...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('DEBUG: Cancel button pressed in dialog');
                Navigator.pop(context);
              },
              child: TranslatableText(
                'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                final text = controller.text.trim();
                print('DEBUG: Generate button pressed in dialog');
                print('DEBUG: Controller text: "$text"');
                Navigator.pop(context, text);
              },
              child: TranslatableText(
                'Generate',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    
    print('DEBUG: Dialog closed, result: "$result"');
    return result;
  }

  Future<void> _handleAutoDetectObjects() async {
    try {
      print('DEBUG: Auto detect objects initiated');
      
      if (imageData == null) {
        _showErrorSnackBar('No image loaded');
        return;
      }

      // Navigate to object selection screen in auto-detect mode
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectSelectionWidget(
            imageData: imageData!,
            isAutoDetect: true,
            onMaskCreated: (mask) => mask, // Keep for compatibility
            onProcessRemoval: _processObjectRemovalDirect, // Direct processing
          ),
        ),
      );

      // Success is handled within the ObjectSelectionWidget
      if (success == true) {
        print('DEBUG: Auto detect and removal completed successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Auto detect failed: $e');
    }
  }

  Future<void> _handleManualObjectSelection() async {
    try {
      print('DEBUG: Manual object selection initiated');
      
      if (imageData == null) {
        _showErrorSnackBar('No image loaded');
        return;
      }

      // Navigate to object selection screen in manual mode
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectSelectionWidget(
            imageData: imageData!,
            isAutoDetect: false,
            onMaskCreated: (mask) => mask, // Keep for compatibility
            onProcessRemoval: _processObjectRemovalDirect, // Direct processing
          ),
        ),
      );

      // Success is handled within the ObjectSelectionWidget
      if (success == true) {
        print('DEBUG: Manual selection and removal completed successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Manual selection failed: $e');
    }
  }

  Future<void> _processObjectRemovalDirect(Uint8List imageBytes, Uint8List maskData) async {
    try {
      setState(() {
        isProcessing = true;
        processingStatus = 'Removing selected objects...';
      });

      print('DEBUG: Processing object removal directly');
      print('DEBUG: Image size: ${imageBytes.length} bytes');
      print('DEBUG: Mask size: ${maskData.length} bytes');
      
      final resultUrl = await ImageProcessingAPI.removeObject(imageBytes, maskData);
      print('DEBUG: Got result URL: $resultUrl');
      
      final processedData = await ImageProcessingAPI.downloadImage(resultUrl);
      print('DEBUG: Downloaded ${processedData.length} bytes');
      
      setState(() {
        processedImageData = processedData;
        isProcessing = false;
        processingStatus = '';
      });

      _showSuccessSnackBar('Objects removed successfully!');
    } catch (e) {
      setState(() {
        isProcessing = false;
        processingStatus = '';
      });
      throw e; // Re-throw so ObjectSelectionWidget can handle the error
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
            onPressed: (processedImageData != null || imageData != null) ? () {
              // Pass the processed image if available, otherwise original
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavePage(
                    imageData: processedImageData ?? imageData,
                  ),
                ),
              );
            } : null,
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
        _roundButton(Icons.content_cut, () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Use Detect or Manual buttons below'))
          );
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
          child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 16),
                      TranslatableText(
                        'Loading image...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : isProcessing
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            processingStatus,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : processedImageData != null
                      ? Image.memory(
                          processedImageData!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : imageData != null
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // API Processing Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _removeBackground,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.layers_clear, size: 16),
                  label: const TranslatableText(
                    'Remove BG',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _onGenerateBackgroundPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const TranslatableText(
                    'Generate BG',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Original Tool Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolButton('Object', Icons.chat_bubble_outline, 0),
              _toolButton('Eraser', Icons.close, 1),
              _toolButton('Detect', Icons.find_in_page, 2),
              _toolButton('Manual', Icons.touch_app, 3),
              _toolButton('Expand', Icons.open_in_full, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolButton(String label, IconData icon, int index) {
    final isSelected = selectedToolIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedToolIndex = index;
        });
        
        // Handle specific tool functionality
        switch (index) {
          case 2: // Detect button
            await _handleAutoDetectObjects();
            break;
          case 3: // Manual button
            await _handleManualObjectSelection();
            break;
          default:
            // Handle other tools as needed
            break;
        }
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

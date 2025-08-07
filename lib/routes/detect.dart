import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:objectremove/services/app_translations.dart';

import 'package:photo_manager/src/types/entity.dart';

class DetectPage extends StatefulWidget {
  const DetectPage({Key? key, required AssetEntity asset}) : super(key: key);

  @override
  State<DetectPage> createState() => _DetectPageState();
}

class _DetectPageState extends State<DetectPage> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Detect'.tr(),
      ),
      body: Center(
        child: _selectedImage == null
            ? ElevatedButton(
                onPressed: _pickImage,
                child: 'Pick Image from Gallery'.tr(),
              )
            : Image.file(_selectedImage!),
      ),
    );
  }
}
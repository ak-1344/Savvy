import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imageUrl;
  final Function(String) onImageSelected;

  const ProfileImagePicker({
    Key? key,
    this.imageUrl,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          onImageSelected(image.path);
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: imageUrl != null
            ? FileImage(File(imageUrl!))
            : null,
        child: imageUrl == null
            ? const Icon(Icons.camera_alt, size: 30)
            : null,
      ),
    );
  }
} 
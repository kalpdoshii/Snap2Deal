import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/models/vendor_model.dart';
import '../../core/services/vendor_service.dart';

class UploadMediaScreen extends StatefulWidget {
  final Vendor vendor;

  const UploadMediaScreen({super.key, required this.vendor});

  @override
  State<UploadMediaScreen> createState() => _UploadMediaScreenState();
}

class _UploadMediaScreenState extends State<UploadMediaScreen> {
  File? _logoFile;
  File? _bannerFile;
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Logo & Banner')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Logo Section
              const Text(
                'Logo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildMediaUploadCard(
                'Logo (Square)',
                'JPG, PNG',
                widget.vendor.logo,
                _logoFile,
                () => _pickImage(isLogo: true),
              ),
              const SizedBox(height: 32),
              // Banner Section
              const Text(
                'Banner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildMediaUploadCard(
                'Banner (Landscape)',
                'JPG, PNG',
                widget.vendor.banner,
                _bannerFile,
                () => _pickImage(isLogo: false),
              ),
              const SizedBox(height: 32),
              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadMedia,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload Media'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUploadCard(
    String title,
    String formats,
    String? currentUrl,
    File? selectedFile,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: selectedFile != null
            ? Image.file(selectedFile, fit: BoxFit.cover)
            : currentUrl != null
            ? Image.network(currentUrl, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(formats, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage({required bool isLogo}) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(pickedFile.path);
        } else {
          _bannerFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _uploadMedia() async {
    if (_logoFile == null && _bannerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? logoUrl;
      String? bannerUrl;

      // Upload logo
      if (_logoFile != null) {
        logoUrl = await _uploadToFirebase(
          _logoFile!,
          'vendor_logos/${widget.vendor.id}/logo.jpg',
        );
      }

      // Upload banner
      if (_bannerFile != null) {
        bannerUrl = await _uploadToFirebase(
          _bannerFile!,
          'vendor_banners/${widget.vendor.id}/banner.jpg',
        );
      }

      // Update vendor document
      final success = await VendorService.updateVendorImages(
        widget.vendor.id,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Media uploaded successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadToFirebase(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}

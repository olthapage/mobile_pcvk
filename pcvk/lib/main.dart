import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadFromCameraPage(),
    );
  }
}

class UploadFromCameraPage extends StatefulWidget {
  const UploadFromCameraPage({super.key});

  @override
  State<UploadFromCameraPage> createState() => _UploadFromCameraPageState();
}

class _UploadFromCameraPageState extends State<UploadFromCameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _status = '';
  bool _loading = false;

  // PAKAI URL NGROK DARI COLAB + '/upload'
  final String _colabEndpoint =
      'https://tena-unrepulsed-unintently.ngrok-free.dev/upload';

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _status = 'Mengirim foto ke Colab...';
    });

    await _sendToColab(pickedFile);
  }

  Future<void> _sendToColab(XFile pickedFile) async {
    setState(() {
      _loading = true;
    });

    try {
      final uri = Uri.parse(_colabEndpoint);
      final request = http.MultipartRequest('POST', uri);

      // HARUS sama dengan request.files['image'] di Flask
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pickedFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        setState(() {
          _status =
              'Upload sukses:\n${body['message']}\nNama file: ${body['filename']}';
        });
      } else {
        setState(() {
          _status =
              'Gagal upload (status: ${response.statusCode})\nBody: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error kirim ke Colab: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter → Colab (Upload Foto)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _image == null
                    ? const Text('Belum ada foto')
                    : Image.file(_image!),
              ),
            ),
            if (_loading) const CircularProgressIndicator(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _takePhoto,
              child: const Text('Ambil Foto & Kirim ke Colab'),
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

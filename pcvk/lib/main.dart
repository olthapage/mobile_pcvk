import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Take and Upload Photo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  File? _image;

  Future<void> _takePhoto() async {
    // Gantilah PickedFile ke XFile
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Simpan foto di perangkat lokal
      await _saveToLocalDirectory(pickedFile);
    }
  }

  Future<void> _saveToLocalDirectory(XFile pickedFile) async {
    // Mendapatkan direktori untuk menyimpan file di perangkat
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/photo.jpg';
    final imageFile = File(path);

    // Salin foto ke direktori lokal
    await imageFile.writeAsBytes(await pickedFile.readAsBytes());
    print('Foto disimpan di: $path');

    // Setelah foto tersimpan, kita bisa memberikan link ke pengguna untuk upload ke Google Drive
    _showUploadInstructions(path);
  }

  void _showUploadInstructions(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload ke Google Drive'),
          content: Text('Foto telah disimpan di perangkat Anda di: $filePath\n\n'
              'Sekarang, buka Google Drive, pilih folder yang diinginkan, dan upload file ini secara manual. '
              'Setelah itu, Anda bisa mendapatkan link berbagi untuk digunakan di Google Colab.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take and Upload Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePhoto,
              child: Text('Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}

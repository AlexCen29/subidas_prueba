import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudinary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageUploadScreen(),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage() async {
  final pickedImageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedImageFile == null) {
    return;
  }
  setState(() {
    _imageFile = File(pickedImageFile.path);
  });
}


  Future<void> _uploadImage() async {
    final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dpmzvnqet/image/upload';
    final apiKey = 'AQUI VA TU API KEY';

    if (_imageFile == null) {
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields.addAll({
      "upload_preset": "ml_default",
      "api_key": apiKey,
    });

    var pic = await http.MultipartFile.fromPath('file', _imageFile!.path);
    request.files.add(pic);

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    Map<String, dynamic> decodedResponse = json.decode(responseString);
    String imageUrl = decodedResponse['secure_url'];

    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloudinary'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile == null
                  ? Text('Selecciona una imagen')
                  : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar imagen'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Subir imagen'),
              ),
              SizedBox(height: 20),
              _imageUrl != null
                  ? Text('URL de la imagen subida:\n$_imageUrl')
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kw_inventory/src/firebase/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/helper_functions.dart';
import 'inventory_screen.dart';

class InvoicesScreen extends StatelessWidget {
  InvoicesScreen({Key? key}) : super(key: key);

  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        label: const Text('Add new invoice'),
        spaceBetweenChildren: 15,
        spacing: 20,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            onTap: () async {
              await openCameraAndUpload();
            },
            child: const Icon(Icons.add_a_photo),
            label: 'Take a photo',
          ),
          SpeedDialChild(
            onTap: () async {
              await openGalleryAndUpload(context);
            },
            child: const Icon(Icons.photo_library),
            label: 'Choose from gallery',
          ),
          SpeedDialChild(
            onTap: () async {
              await pickFiles();
            },
            child: const Icon(Icons.file_present),
            label: 'Add document',
          ),
        ],
      )
    );
  }

  Future openCameraAndUpload() async {
    File _imageFile;

    try {
      if (await Permission.camera.request().isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);

          EasyLoading.show(status: 'Uploading...');

          String _imageDownloadURL =
          await firebaseService.uploadImageToFirebase(
              _imageFile,
              'invoice_photos',
              pickedFile.name
          );

         //EasyLoading.showSuccess(profilePhotoAppliedMessage);
        } else {
          EasyLoading.showInfo('No image taken');
        }
      } else {
        showCustomSnackBar(
            'Permission not granted. Please enable permissions', duration: 3);
        await Permission.camera.request();
      }
    } catch (e) {
      showCustomSnackBar(
        'Error encountered. Please try again',
        duration: 3,
        error: true
      );
    }
  }

  Future openGalleryAndUpload(BuildContext context) async {
    File _imageFile;

    try {
      if (await Permission.photos.request().isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);

          String _imageDownloadURL =
          await firebaseService.uploadImageToFirebase(
              _imageFile,
              'invoice_photos',
              pickedFile.name
          );

          //EasyLoading.showSuccess(profilePhotoAppliedMessage);
        } else {
          EasyLoading.showInfo('No image selected');
        }
      } else {
        Navigator.pop(context);
        showCustomSnackBar(
            'Permission not granted. Please enable permissions', duration: 3);
        await Permission.photos.request();
      }
    } catch (e) {
      showCustomSnackBar(
          'Error encountered. Please try again',
          duration: 3,
          error: true
      );
    }
  }

  Future pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        EasyLoading.show(status: 'Uploading...');

        await firebaseService
            .firebaseStorage
            .ref()
            .child('invoice_docs/$fileName')
            .putFile(file);

        EasyLoading.showSuccess('Uploaded');
      } else {
        EasyLoading.showInfo('No files chosen');
      }
    } catch (e) {
      print(e.toString());
    }
  }

}

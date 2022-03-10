import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kw_inventory/src/firebase/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../globals/globals.dart';
import '../utils/helper_functions.dart';
import 'inventory_screen.dart';

class InvoicesScreen extends StatelessWidget {
  InvoicesScreen({Key? key}) : super(key: key);

  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _textEditingController = TextEditingController();

  String alertBoxMessage = '';
  String? _fileURL;
  File? _invoiceFile;

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
              await openCameraAndCapture(context);
            },
            child: const Icon(Icons.add_a_photo),
            label: 'Take a photo',
          ),
          SpeedDialChild(
            onTap: () async {
              await openGalleryAndSelect(context);
            },
            child: const Icon(Icons.photo_library),
            label: 'Choose from gallery',
          ),
          SpeedDialChild(
            onTap: () async {
              await pickFiles(context);
            },
            child: const Icon(Icons.file_present),
            label: 'Add document',
          ),
        ],
      )
    );
  }

  Future openCameraAndCapture(BuildContext context) async {
    try {
      if (await Permission.camera.request().isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          _invoiceFile = File(pickedFile.path);
          showUploadDialog(context, pickedFile.name, Globals.invoiceTypePic);
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

  Future openGalleryAndSelect(BuildContext context) async {
    try {
      if (await Permission.photos.request().isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          _invoiceFile = File(pickedFile.path);
          showUploadDialog(context, pickedFile.name, Globals.invoiceTypePic);
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

  Future uploadInvoice(String subFolderName) async {
    if (_invoiceFile != null) {
      _fileURL = await firebaseService.
      uploadImageToFirebase(_invoiceFile!,
          'invoices/$subFolderName',
          _textEditingController.text
      );
    }
  }



  Future pickFiles(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        _invoiceFile = File(result.files.single.path!);
        String fileName = result.files.single.name;
        showUploadDialog(context, fileName, Globals.invoiceTypeDoc);
      } else {
        EasyLoading.showInfo('No file chosen');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void showUploadDialog(BuildContext context, String fileName, String uploadType) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            child: StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: uploadType == Globals.invoiceTypeDoc
                    ? const Text('Document upload')
                    : const Text('Picture upload'),
                content: Builder(
                  builder: (context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 6,
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Please enter a name for file'),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _textEditingController,
                            decoration: const InputDecoration(
                                hintText: 'Name'
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              alertBoxMessage,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop('Cancel');
                        _textEditingController.clear();
                        alertBoxMessage = '';
                      },
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                            color: Colors.red
                        ),
                      )
                  ),
                  OutlinedButton(
                      onPressed: () {
                        _textEditingController.text = fileName.split('.')[0];
                      },
                      child: const Text('Use default file name')
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_textEditingController.text.trim().isNotEmpty) {
                          EasyLoading.show(status: 'Uploading...');

                          try {
                            if (uploadType == Globals.invoiceTypePic) {
                              await uploadInvoice('invoice_pics/');
                            } else {
                              await uploadInvoice('invoice_docs/');
                            }

                            await firebaseService.addInvoiceToFirestore(
                                _textEditingController.text,
                                uploadType,
                                _fileURL!
                            );
                            print(FieldValue.serverTimestamp());

                            _textEditingController.clear();
                            alertBoxMessage = '';
                            EasyLoading.showSuccess('Uploaded');
                            Navigator.of(context).pop('Submit');
                          } catch (e) {
                            EasyLoading.dismiss();
                            setState(() {
                              alertBoxMessage = e.toString();
                            });
                          }
                        } else {
                          setState(() {
                            alertBoxMessage = 'File name is empty';
                          });
                        }
                      },
                      child: const Text('UPLOAD')
                  )
                ],
              ),
            ),
            onWillPop: () async => false
        )
    );
  }

}

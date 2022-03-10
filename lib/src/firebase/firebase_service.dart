import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService{
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStorage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  Stream<User?> get user => firebaseAuth.authStateChanges();

  Future<String?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return 'Success';
    } on FirebaseAuthException catch(e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> createAccount({required String email, required String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return 'Success';
    } on FirebaseAuthException catch(e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImageToFirebase(
      File imageToUpload, String folderName, String fileName) async {
    final snapshot = await firebaseStorage.ref()
        .child('$folderName/$fileName')
        .putFile(imageToUpload);

    return snapshot.ref.getDownloadURL();
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future addInvoiceToFirestore(
      String invoiceName, String invoiceType, String linkToFile) async {

    firestore
      .collection('Invoices')
        .add(
          {
            'dateAdded': FieldValue.serverTimestamp(),
            'name': invoiceName,
            'type': invoiceType,
            'url': linkToFile,
          }
    );
  }
}
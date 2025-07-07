import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firestore_service.dart';

class NoteProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String title = '';
  String content = '';

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateContent(String newContent) {
    content = newContent;
    notifyListeners();
  }

  void clear() {
    title = '';
    content = '';
    notifyListeners();
  }

  Future<void> saveNote(String title, String content) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestoreService.addNote(uid, title, content);
    notifyListeners();
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestoreService.updateNote(uid, noteId, title, content);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestoreService.deleteNote(uid, noteId);
    notifyListeners();
  }
}

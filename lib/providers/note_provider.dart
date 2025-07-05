import 'package:flutter/material.dart';
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

  // Save Note
  Future<void> saveNote(String title, String content) async {
    await _firestoreService.addNote(title, content);
    notifyListeners();
  }

  // Update Note
  Future<void> updateNote(String noteId, String title, String content) async {
    await _firestoreService.updateNote(noteId, title, content);
    notifyListeners();
  }

  // Delete Note
  Future<void> deleteNote(String noteId) async {
    await _firestoreService.deleteNote(noteId);
    notifyListeners();
  }
}

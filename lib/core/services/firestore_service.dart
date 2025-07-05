import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notesCollection =
  FirebaseFirestore.instance.collection('notes');

  // Add Note
  Future<void> addNote(String title, String content) async {
    await notesCollection.add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Update Note
  Future<void> updateNote(String noteId, String newTitle, String newContent) async {
    await notesCollection.doc(noteId).update({
      'title': newTitle,
      'content': newContent,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Delete Note
  Future<void> deleteNote(String noteId) async {
    await notesCollection.doc(noteId).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getUserNotesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Future<void> addNote(String uid, String title, String content) async {
    await getUserNotesCollection(uid).add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote(String uid, String noteId, String title, String content) async {
    await getUserNotesCollection(uid).doc(noteId).update({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String uid, String noteId) async {
    await getUserNotesCollection(uid).doc(noteId).delete();
  }
}

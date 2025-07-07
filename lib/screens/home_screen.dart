import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/screens/create_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGridView = false;
  bool sortDescending = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,

      //Appbar
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title:
            isSearching
                ? TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                )
                : const Text(
                  "All notes",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                searchController.clear();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            color: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onSelected: (value) {
              setState(() {
                if (value == 'Grid/List') {
                  isGridView = !isGridView;
                } else if (value == 'Sort: Latest') {
                  sortDescending = true;
                } else if (value == 'Sort: Oldest') {
                  sortDescending = false;
                }
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'Grid/List',
                    child: Text(
                      'Toggle Grid/List',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Sort: Latest',
                    child: Text(
                      'Sort: Latest',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Sort: Oldest',
                    child: Text(
                      'Sort: Oldest',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
          ),
        ],
      ),

      //Body
      body:
          user == null
              ? const Center(child: Text("User not logged in"))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('notes')
                        .orderBy('timestamp', descending: sortDescending)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No notes found."));
                  }

                  final notes =
                      snapshot.data!.docs.where((doc) {
                        final title = doc['title'].toString().toLowerCase();
                        final query = searchController.text.toLowerCase();
                        return title.contains(query);
                      }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        isGridView
                            ? _buildGridView(notes, screenWidth)
                            : _buildListView(notes),
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.create_outlined, color: Colors.black),
      ),
    );
  }

  Widget _buildGridView(List<DocumentSnapshot> notes, double screenWidth) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) => _buildNoteCard(notes[index]),
    );
  }

  Widget _buildListView(List<DocumentSnapshot> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) => _buildNoteCard(notes[index]),
    );
  }

  Widget _buildNoteCard(DocumentSnapshot note) {
    final title = note['title'] ?? '';
    final content = note['content'] ?? '';
    final timestamp = (note['timestamp'] as Timestamp?)?.toDate();

    return SizedBox(
      height: 140,
      child: Dismissible(
        key: Key(note.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDeleteDialog(note),
        onDismissed: (_) => _deleteNote(note),
        background: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => CreateNoteScreen(
                      noteId: note.id,
                      existingTitle: title,
                      existingContent: content,
                    ),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (timestamp != null)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteDialog(DocumentSnapshot note) async {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to delete this note?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteNote(DocumentSnapshot note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.id)
          .delete();
    }
  }
}

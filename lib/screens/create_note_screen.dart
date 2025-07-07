import 'package:flutter/material.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

class CreateNoteScreen extends StatefulWidget {
  final String? noteId;
  final String? existingTitle;
  final String? existingContent;

  const CreateNoteScreen({
    super.key,
    this.noteId,
    this.existingTitle,
    this.existingContent,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existingTitle ?? '');
    contentController = TextEditingController(text: widget.existingContent ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      provider.updateTitle(titleController.text);
      provider.updateContent(contentController.text);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 23),
          onPressed: () => _handleBackPress(context, noteProvider, screenWidth),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black, size: 23),
            onPressed: () => _saveNote(context, noteProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: TextField(
                  controller: titleController,
                  onChanged: (val) => noteProvider.updateTitle(val),
                  style: const TextStyle(fontSize: 30, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: TextField(
                    controller: contentController,
                    onChanged: (val) => noteProvider.updateContent(val),
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 23, color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Type something...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackPress(BuildContext context, NoteProvider provider, double screenWidth) {
    final title = provider.title.trim();
    final content = provider.content.trim();
    final isEmpty = title.isEmpty && content.isEmpty;
    final hasChanges = title != (widget.existingTitle?.trim() ?? '') || content != (widget.existingContent?.trim() ?? '');

    if (isEmpty || !hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.06,
            horizontal: screenWidth * 0.05,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 36, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Save changes?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: _dialogButtonStyle(Colors.red, screenWidth * 0.05),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.pop(context);
                    },
                    child: const Text('Discard'),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  ElevatedButton(
                    style: _dialogButtonStyle(Colors.green, screenWidth * 0.06),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _saveNote(context, provider);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote(BuildContext context, NoteProvider provider) async {
    final title = provider.title.trim();
    final content = provider.content.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    try {
      if (widget.noteId != null) {
        await provider.updateNote(widget.noteId!, title, content);
      } else {
        await provider.saveNote(title, content);
      }

      provider.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Error saving note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save note."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ButtonStyle _dialogButtonStyle(Color color, double horizontalPadding) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
    );
  }
}

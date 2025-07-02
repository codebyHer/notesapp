import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditorPage extends StatefulWidget {
  final String noteTitle;
  final String noteContent;
  final String? noteId; // noteId can be null for new notes
  const EditorPage({
    super.key,
    this.noteId, // Made optional for new notes
    required this.noteTitle,
    required this.noteContent,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTitle);
    _contentController = TextEditingController(text: widget.noteContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
  //                       START CHANGES HERE
  // VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

  void _saveNote() async {
    // --- CHANGE 1: Trim whitespace from text fields ---
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    // --- END CHANGE 1 ---

    // --- CHANGE 2: Basic validation - Don't save empty notes ---
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty!')),
      );
      return; // Exit if both are empty
    }
    // --- END CHANGE 2 ---

    // --- CHANGE 3: Robust null check for current user ---
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: User not logged in. Cannot save note.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save notes.')),
      );
      // Optionally, you might want to navigate back to the login screen here.
      // E.g., if (mounted) { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginView()), (Route<dynamic> route) => false); }
      return; // Exit function if no user
    }
    // --- END CHANGE 3 ---

    final userId = user.uid; // User is guaranteed non-null here
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');

    // --- CHANGE 4: Wrap Firestore operations in try-catch for error handling ---
    try {
      // Check if it's an existing note (noteId is not null and not empty)
      if (widget.noteId != null && widget.noteId!.isNotEmpty) {
        await notesCollection.doc(widget.noteId).update({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(), // Update timestamp on modification
        });
        print('Note updated: ${widget.noteId}');
      } else {
        // This is a new note, so add it.
        // --- CHANGE 5: REMOVED DUPLICATE ADD OPERATION ---
        // The previous code had a second, unconditional 'add' operation after this 'else' block.
        // That duplicate 'add' caused two notes to be saved for new entries.
        // Ensure this is the *only* 'add' operation in this method.
        await notesCollection.add({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(), // Initial timestamp for new note
        });
        print('New note added for user: $userId');
      }

      // --- CHANGE 6: Show success message and pop() only after successful save/update ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.noteId != null ? 'Note updated!' : 'Note saved!')),
        );
      }
      Navigator.pop(context); // Pop the EditorPage after successful saving
      // --- END CHANGE 6 ---

    } catch (e) {
      print("Error saving note: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Title'),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveNote, // This is correct, remains the same
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          // --- CHANGE 7: Allow content TextField to expand and handle multiple lines ---
          maxLines: null, // Allows unlimited lines
          expands: true, // Makes the TextField take up available vertical space
          // --- END CHANGE 7 ---
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Start typing your note...'),
        ),
      ),
    );
  }
}
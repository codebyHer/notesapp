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

  

  void _saveNote() async {
    
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    

    
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty!')),
      );
      return; 
    }
    

    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: User not logged in. Cannot save note.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save notes.')),
      );
      
      
      return; 
    }
    

    final userId = user.uid; 
    final notesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes');

    
    try {
      
      if (widget.noteId != null && widget.noteId!.isNotEmpty) {
        await notesCollection.doc(widget.noteId).update({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(), 
        });
        print('Note updated: ${widget.noteId}');
      } else {
        
        
        
        await notesCollection.add({
          'title': title,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(), 
        });
        print('New note added for user: $userId');
      }

      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.noteId != null ? 'Note updated!' : 'Note saved!')),
        );
      }
      Navigator.pop(context); 
      

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
            onPressed: _saveNote, 
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          
          maxLines: null, 
          expands: true, 
          
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Start typing your note...'),
        ),
      ),
    );
  }
}
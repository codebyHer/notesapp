import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/views/editor_view.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Homepage extends StatefulWidget {
  

  const Homepage({super.key, });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  List<Map<String, String>> notes = [];
  
   Future<void> _addNotes () async{
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (Context) => const EditorPage(noteTitle: '', noteContent: '' , noteId: '', ),),
    );
    if (result !=null && result is Map<String, String>) {
      setState(() {
        notes.add({"title": result ['title']?? 'No title',
        'content': result ['content'] ?? 'No content'
        });
      });
    }

   }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My notes'),
        actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/');
          },
        )
      ]
      ),
      
      body: StreamBuilder <QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notes')
        .orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot){
        if (snapshot.connectionState ==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data?.docs ?? [];
        if (notes.isEmpty){
          return const Center(
            child:  Text('No notes yet. Click the + button to add a note.'),
          );
        }
      
      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final title = note['title'] ?? '';
          final content = note['content'] ?? '';

          return ListTile(
            title: Text(title,
            style: TextStyle(fontSize: 20, fontWeight:FontWeight.bold, color: Colors.orange),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorPage(
                    noteTitle: title,
                    noteContent: content,
                    noteId:note.id,
                  ),
                ),
              );
            },
            subtitle: Text(content, style: TextStyle(fontWeight: FontWeight.bold),),
        
            trailing: IconButton(onPressed: () async{
              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).
              collection('notes')
              .doc(note.id)
              .delete();
            }, icon: const Icon(Icons.delete), color: 
          Colors.red,),

          );
        },
      );
    },
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      _addNotes();
    },
    child: const Icon(Icons.add),
    tooltip: 'Add Note',
  ),
);
  }
}
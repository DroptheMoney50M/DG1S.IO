import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일과학고 익명 게시판',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _notesCollection =
      FirebaseFirestore.instance.collection('notes');
  final DocumentReference _vendingMachineDoc =
      FirebaseFirestore.instance.collection('vendingMachine').doc('status');

  Future<void> _addNote() async {
    if (_controller.text.isNotEmpty) {
      await _notesCollection.add({'content': _controller.text});
      _controller.clear();
    }
  }

  Future<void> _addLike() async {
    await _vendingMachineDoc.update({'likes': FieldValue.increment(1)});
  }

  Future<void> _addDislike() async {
    await _vendingMachineDoc.update({'dislikes': FieldValue.increment(1)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DG1S익명게시판'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: _vendingMachineDoc.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null || !snapshot.data!.exists) {
                return const Center(child: Text('No data available'));
              }
              final Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              final likes = data['likes'] ?? 0;
              final dislikes = data['dislikes'] ?? 0;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '자판기 좋아요(현재 클릭된 횟수) $likes',
                        style: TextStyle(fontSize: 24),
                      ),
                      ElevatedButton(
                        onPressed: _addLike,
                        child: const Text(
                          '좋아요',
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        '자판기 싫어요(현재 클릭된 횟수) $dislikes',
                        style: TextStyle(fontSize: 24),
                      ),
                      ElevatedButton(
                        onPressed: _addDislike,
                        child: const Text('싫어요'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 3,
                      ),
                      labelText: '먹고싶은거/요청사항 적기',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: const Text('자판기에게 전송하기'),
                  ),
                  SizedBox(height: 100),
                  Text(
                    '요청된 리스트',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notesCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data!.docs;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 10,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      child: Center(child: Text(note['content'])),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

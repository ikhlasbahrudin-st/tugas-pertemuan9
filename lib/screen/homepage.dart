import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final tugasController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  void tambahTugas() {
    final user = auth.currentUser;

    if (user != null && tugasController.text.isNotEmpty) {
      firestore.collection('users').doc(user.uid).collection('TodoList').add({
        'Tugas': tugasController.text,
        'CreateAt': Timestamp.now(),
      });

      tugasController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
        
          Expanded(
            child: user == null
                ? const Center(child: Text("User belum login"))
                : StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('TodoList')
                        .orderBy('CreateAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Belum ada tugas"));
                      }

                      final doc = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: doc.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.note),
                              title: Text(doc[index]['Tugas']),
                              trailing: IconButton(
                                onPressed: () => doc[index].reference.delete(),
                                icon: const Icon(Icons.delete_forever),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tugasController,
                    decoration: const InputDecoration(
                      labelText: "Masukkan tugas",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: tambahTugas,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

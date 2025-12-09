import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final tugas = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  void tambahtugas() {
    final user = auth.currentUser;

    if (user != null && tugas.text.isNotEmpty) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('TodoList')
          .add({
        'Tugas': tugas.text,
        'CreateAt': Timestamp.now(),
      });

      tugas.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text("Beranda"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: Icon(Icons.logout_outlined),
          )
        ],
      ),

      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tugas,
                    decoration: InputDecoration(
                      hintText: "Tambah tugas...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: tambahtugas,
                  child: Text("Tambah"),
                )
              ],
            ),
          ),

          
          Expanded(
            child: currentUser == null
                ? Center(child: Text("Tidak ada user login"))
                : StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('TodoList')
                        .orderBy('CreateAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Terjadi kesalahan"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("Belum ada tugas"));
                      }

                      final data = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return ListTile(
                            title: Text(item['Tugas']),
                            subtitle: Text(
                              item['CreateAt']
                                  .toDate()
                                  .toString()
                                  .substring(0, 19),
                            ),
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

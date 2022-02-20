import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/add_note.dart';
import 'package:crud/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'note_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = FirebaseAuth.instance;

  GlobalKey<AnimatedListState> completedKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState> incomplete = GlobalKey<AnimatedListState>();

  TextEditingController title = TextEditingController();
  TextEditingController discription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 238, 230, 240),
        actions: [
          IconButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
        centerTitle: true,
        title: const Text(
          "ITEMS",
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink[50],
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              context: context,
              builder: (context) {
                return AddNotes(
                  added: (length) {
                    try {
                      if (length != 0) {
                        if (incomplete.currentState != null) {
                          incomplete.currentState!.insertItem(length - 1);
                        }
                      }
                    } catch (e) {
                      // ignore: avoid_print
                      print(e);
                    }
                  },
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<NoteModel>>(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .withConverter(
                fromFirestore: (s, o) => NoteModel.fromMap(s.data()!),
                toFirestore: (NoteModel v, o) => v.crud())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final List<QueryDocumentSnapshot<NoteModel>> docsIncomplete =
                snapshot.data!.docs.toList();

            return ListView.builder(
              shrinkWrap: true,
              key: incomplete,
              itemCount: docsIncomplete.length,
              itemBuilder: (context, index) {
                return slideTransition(index, docsIncomplete[index]);
              },
            );
          } else {
            // ignore: prefer_const_constructors
            return Center(child: const Text("No Data"));
          }
        },
      ),
    );
  }

  Widget slideTransition(int index, QueryDocumentSnapshot<NoteModel> e) {
    NoteModel notemodel = e.data();

    return Slidable(
      startActionPane: ActionPane(
          extentRatio: 0.2,
          dragDismissible: false,
          motion: const ScrollMotion(),
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.grey.shade200.withOpacity(0.5),
                  )
                ],
                color: Colors.redAccent.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () async {
                  await e.reference.delete();
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, top: 5, left: 15, right: 15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            trailing: CircleAvatar(
              backgroundColor: Colors.lightBlue[50],
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return AddNotes(
                          added: (lenght) {},
                          isEdit: true,
                          documentReference: e.reference,
                          note: notemodel.notes,
                          title: notemodel.title,
                        );
                      });
                },
              ),
            ),
            leading: Container(
              height: 100,
              width: 80,
              color: Colors.grey,
              child: notemodel.url == ""
                  ? const Icon(Icons.image_not_supported_outlined)
                  : Image.network(notemodel.url),
            ),
            title: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text((notemodel.title).toString()),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text((notemodel.notes).toString()),
            ),
          ),
        ),
      ),
    );
  }
}

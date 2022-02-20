// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'note_model.dart';

class AddNotes extends StatefulWidget {
  final bool isEdit;
  final String? title;
  final String? note;
  final String? url;
  final DocumentReference? documentReference;
  final Function(int lenght) added;
  const AddNotes(
      {Key? key,
      this.isEdit = false,
      this.note,
      this.title,
      this.documentReference,
      required this.added,
      this.url})
      : assert(isEdit ? documentReference != null : true),
        super(key: key);

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  late TextEditingController titleController =
      TextEditingController(text: widget.title);
  late TextEditingController notesController =
      TextEditingController(text: widget.note);
  late String _image = widget.url ?? "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.isEdit ? "Edit Item" : "Add Item",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              InkWell(
                onTap: () async {
                  XFile? image = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _image = image.path;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey),
                  child: _image != ""
                      ? _image.contains('http') || _image.contains('https')
                          ? Image.network(_image)
                          : Image.file(
                              File(_image),
                            )
                      : Image.network(
                          "https://cdn.pixabay.com/photo/2017/03/19/03/51/material-icon-2155448_960_720.png"),
                ),
              ),
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: "Input",
                      label: Text("Title"))),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: notesController,
                minLines: 1,
                maxLines: 50,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    hintText: "Input",
                    label: Text("Description")),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 18,
                child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)))),
                    onPressed: () async {
                      if (!widget.isEdit) {
                        String url = _image;
                        if (_image != "") {
                          Reference reference =
                              FirebaseStorage.instance.ref().child('images');
                          UploadTask uploadTask = reference
                              .child(DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString())
                              .putFile(File(_image));
                          await Future.value(uploadTask);
                          url = await uploadTask.snapshot.ref.getDownloadURL();
                        }
                        await FirebaseFirestore.instance
                            .collection("notes")
                            .add(NoteModel(
                              notes: notesController.text,
                              url: url,
                              title: titleController.text,
                            ).crud()

                                );
                        QuerySnapshot<NoteModel> snapshot =
                            await FirebaseFirestore.instance
                                .collection('notes')
                                .withConverter(
                                    fromFirestore: (s, o) =>
                                        NoteModel.fromMap(s.data()!),
                                    toFirestore: (NoteModel v, o) => v.crud())
                                .get();

                        widget.added(snapshot.docs.length);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Notes Added"),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        String url = _image;
                        if ((!_image.contains("http") &&
                            !_image.contains("https") &&
                            _image != "")) {
                          UploadTask uploadTask = FirebaseStorage.instance
                              .ref()
                              .child('images')
                              .child(DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString())
                              .putFile(File(_image));

                          url = await uploadTask.snapshot.ref.getDownloadURL();
                        }
                        widget.documentReference!.update(NoteModel(
                          notes: notesController.text,
                          url: url,
                          title: titleController.text,
                        ).crud());
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Notes Edit")));
                        Navigator.pop(context);
                      }
                    },
                    child: Text(widget.isEdit ? "Update" : "Save")),
              )
            ],
          ),
        ),
      ),
    );
  }
}

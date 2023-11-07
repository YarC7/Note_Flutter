import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/constants/colors.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/screens/edit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/screens/profile.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> sampleNotes =[];
  List<Note> filteredNotes = [];
  bool sorted = false;
  int indexxxx = 1;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  bool isDarkMode = true;



  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getNotesFromFirestoreCollection();

  }



  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }



  // void deleteNote(int index) async {
  //   String noteId = sampleNotes[index].id.toString().trim();
  //   FirebaseFirestore.instance.collection("notes").doc(noteId).delete();
  //
  //   setState(()  {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('You have successfully deleted a product')));
  //     filteredNotes.removeAt(index);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 30,
                      color: isDarkMode ? Colors.white : Colors.black, // Text color
                      fontWeight: FontWeight.bold,
                      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white, // Background color
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // _auth.signOut();
                      // Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => const ProfileScreen())));
                    },
                    icon: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                width: 3
                            ),
                            color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                            borderRadius: BorderRadius.circular(10))
                        ,
                        child:
                        isDarkMode ?
                        const Icon(
                          Icons.person,
                          color: Colors.white,) :
                        const Icon(
                          Icons.person,
                          color: Colors.black,
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: onSearchTextChanged,
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.black : Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Search notes...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:  Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  fillColor: isDarkMode ? Colors.white : Colors.black,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      alignment: Alignment.topRight,
                      onPressed: () {
                        setState(() {
                          isDarkMode = !isDarkMode;
                        });
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                width: 3
                            ),
                            color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      )),
                  IconButton(
                      alignment: Alignment.topLeft,
                      onPressed: () {
                        setState(() {
                          filteredNotes = sortNotesByModifiedTime(filteredNotes);
                        });
                      },
                      padding: const EdgeInsets.all(0),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: isDarkMode ? Colors.grey.shade800 : Colors.black,
                                width: 3
                            ),
                            color: isDarkMode ? Colors.grey.shade800.withOpacity(.8) : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          isDarkMode ? Icons.sort : Icons.sort,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      )),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        color: getRandomColor(),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            onTap: () async {
                              getNotesFromFirestoreCollection();
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EditScreen(note: filteredNotes[index]),
                                ),
                              );
                              if (result != null) {
                                {
                                  String id = sampleNotes[index].id;
                                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('notes').get();
                                  for (QueryDocumentSnapshot document in querySnapshot.docs) {
                                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                    if (data["id"] == id){
                                      String firestoreDocumentId = document.id;
                                      final docNote = FirebaseFirestore.instance.collection('notes').doc(firestoreDocumentId);
                                      docNote.update({
                                        "title": result[0],
                                        "content": result[1],
                                        "style" : result[2],
                                        "image" : result[3],
                                        "record" : result[4],
                                        "modifiedTime": DateTime.now()
                                      });
                                    }
                                  }
                                  filteredNotes.removeAt(index);
                                  getNotesFromFirestoreCollection();


                                };
                              }
                            },
                            title: RichText(
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  text: '${filteredNotes[index].title} \n',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      height: 1.5),
                                  children: [
                                    TextSpan(
                                      text: filteredNotes[index].content,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 1.5),
                                    )
                                  ]),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade800),
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                // final result = await confirmDialog(context);
                                // if (result!=null && result){
                                //
                                // }
                                getNotesFromFirestoreCollection();

                                if (index >= 0 && index < sampleNotes.length) {
                                  // The index is valid, so you can safely access the element
                                  String id = sampleNotes[index].id;


                                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('notes').get();

                                  for (QueryDocumentSnapshot document in querySnapshot.docs) {
                                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                    if (data["id"] == id){
                                      String firestoreDocumentId = document.id;
                                      final docNote = FirebaseFirestore.instance.collection('notes').doc(firestoreDocumentId);
                                      docNote.delete().then((_) {
                                        setState(() {
                                          // Remove the deleted note from the filteredNotes list
                                          filteredNotes.removeAt(index);
                                          getNotesFromFirestoreCollection();

                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('You have successfully deleted a note'),
                                          ));
                                        });
                                      }).catchError((error) {
                                        print('Error deleting note: $error');
                                      });

                                      // Now, firestoreDocumentId contains the Firestore document ID for the note with the provided note ID
                                      break;
                                    }
                                    // Optionally, you can break the loop if you've found the matching document
                                  }
                                } else {
                                  print('Invalid index: $index');
                                }




                                // final docNote = FirebaseFirestore.instance.collection('notes').doc("064XW7x8LeNpECLDLysi");
                                // docNote.delete();
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ))
            ],
          ),
        ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>  EditScreen(),
            ),
          );
          setState(() {
            if (result != null) {
              if (result[0]!=" " && result[1]!=" "){
                String nextId = (filteredNotes.length + 1).toString().trim();

                FirebaseFirestore.instance.collection("notes").add({
                  "id": nextId.toString(),
                  "title": result[0],
                  "content": result[1],
                  "style" : result[2],
                  "image" : result[3],
                  "record" : result[4],
                  "modifiedTime": DateTime.now(),
                });
                indexxxx = indexxxx +1;


                filteredNotes.add(Note(
                  id: nextId.toString(),
                  title: result[0],
                  content: result[1],
                  modifiedTime: DateTime.now(),
                ));
              }

            }
          });

          // setState(() {
          //   sampleNotes.add(Note(
          //       id: sampleNotes.length,
          //       title: result[0],
          //       content: result[1],
          //       modifiedTime: DateTime.now()));
          //   filteredNotes = sampleNotes;
          // });

        },
        elevation: 10,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        child:  Icon(
          isDarkMode ? Icons.add : Icons.add,
          color: isDarkMode ? Colors.white : Colors.black,
          size: 38,
        ),
      ),
    );
  }


  Future<void> getNotesFromFirestoreCollection() async {
    final CollectionReference notesCollection =
    FirebaseFirestore.instance.collection('notes');

    QuerySnapshot querySnapshot = await notesCollection.get();
    if (querySnapshot.docs.isNotEmpty) {
      sampleNotes = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Note(
          id: data["id"],
          title: data['title'],
          content: data['content'],
          style : data['style'],
          image: data["image"],
          record: data["record"],
          modifiedTime: (data['modifiedTime'] as Timestamp).toDate(),
        );
      }).toList();

      filteredNotes = List.from(sampleNotes);

      // print("Done FilterNotes");
      // for (int i = 0; i < filteredNotes.length; i++) {
      //   Note note = filteredNotes[i];
      //   print('Filtered Element $i:');
      //   print('Title: ${note.title}');
      //   print('Content: ${note.content}');
      //   print('Modified Time: ${note.modifiedTime}');
      //   print('\n'); // Add a line break for separation
      // }



    } else {
      print('No documents found in the collection.');
    }
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            icon: const Icon(
              Icons.info,
              color: Colors.grey,
            ),
            title: const Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.white),
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'Yes',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        width: 60,
                        child: Text(
                          'No',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                ]),
          );
        });
  }
}

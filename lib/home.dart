
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'firebase_storage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Firestore',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text fields' controllers
  final Storage storage = Storage();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String sname = "";
  final CollectionReference _products =
  FirebaseFirestore.instance.collection('products');

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'name'),
                ),
                TextField(
                  controller: _marksController,
                  decoration: const InputDecoration(labelText: 'marks'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'email'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String marks = _marksController.text;
                    final String email = _emailController.text;
                    await _products.add({"name": name, "marks": marks, "email": email});

                    _nameController.text = '';
                    _marksController.text = '';
                    _emailController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );

        });
  }
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {

      _nameController.text = documentSnapshot['name'];
      _marksController.text = documentSnapshot['marks'];
      _emailController.text = documentSnapshot['email'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'name'),
                ),
                TextField(
                  controller: _marksController,
                  decoration: const InputDecoration(labelText: 'marks'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'email'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text( 'Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String marks = _marksController.text;
                    final String email = _emailController.text;

                    await _products
                        .doc(documentSnapshot!.id)
                        .update({"name": name, "marks": marks, "email": email});
                    _nameController.text = '';
                    _marksController.text = '';
                    _emailController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _products.doc(productId).delete();
    final desertRef = await storage.storage.ref('$productId');

// Delete the file
    await desertRef.delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a record')));
  }
  // for adding images and shit
  Future<void> _addimage([DocumentSnapshot? documentSnapshot]) async{
    if(documentSnapshot!=null){
      // return;
    }
    final results = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (results == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected.'),

        ),
      );
      return null;
    }
    final path = results.files.single.path!;
    // final fileName = results.files.single.name;
    String fileName = "";
    if(documentSnapshot!=null) {
      fileName = documentSnapshot.id;
    }

    storage.uploadFile(path, fileName).then((value)=> print('Done'));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: const Center(child: Text('Firebase Firestore')),
            title: Card(
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search), hintText: 'Search...'),
                onChanged: (val) {
                  setState(() {
                    sname = val;
                  });
                },
              ),
            )
        ),
        body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  var data = streamSnapshot.data!.docs[index].data()
                  as Map<String, dynamic>;

                  if(data['name']
                      .toString()
                      .toLowerCase()
                      .startsWith(sname.toLowerCase())) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(documentSnapshot['name']),

                        subtitle: Text('${'marks: ' + documentSnapshot['marks']}\nemail: ' + documentSnapshot['email']),

                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _update(documentSnapshot)),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _delete(documentSnapshot.id)),
                              IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _addimage(documentSnapshot)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  else{

                    return Card(

                    );
                  }
                },

              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
// Add new product
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(),
          child: const Icon(Icons.add),

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}
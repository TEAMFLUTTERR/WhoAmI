// main.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Deck {
  String name;
  List<String> imagePaths;

  Deck({required this.name, this.imagePaths = const []});
}

class DecksPage extends StatefulWidget {
  @override
  _DecksPageState createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  late Box decksBox;
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  void _loadDecks() {
    decksBox = Hive.box('decks');
    setState(() {
      decks = decksBox.values
          .map((dynamic value) => Deck(
              name: value['name'], 
              imagePaths: List<String>.from(value['imagePaths'] ?? [])))
          .toList();
    });
  }

  void _createDeck() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Neues Deck erstellen'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Deck Name'),
        ),
        actions: [
          TextButton(
            child: Text('Erstellen'),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  Deck newDeck = Deck(name: nameController.text);
                  decks.add(newDeck);
                  decksBox.add({
                    'name': newDeck.name,
                    'imagePaths': newDeck.imagePaths
                  });
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meine Decks')),
      body: ListView.builder(
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(decks[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckDetailPage(deck: decks[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDeck,
        child: Icon(Icons.add),
      ),
    );
  }
}

class DeckDetailPage extends StatefulWidget {
  final Deck deck;

  DeckDetailPage({required this.deck});

  @override
  _DeckDetailPageState createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _saveImage(image.path);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Datei auswählen'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _saveImage(image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveImage(String imagePath) async {
    final TextEditingController nameController = TextEditingController();
    
    // Show a dialog to get the image name
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bild benennen'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Bildname'),
        ),
        actions: [
          TextButton(
            child: Text('Speichern'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    // Get the directory and create a unique filename
    final directory = await getApplicationDocumentsDirectory();
    final fileName = nameController.text.isNotEmpty 
      ? '${nameController.text}.jpg' 
      : DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    
    final newPath = '${directory.path}/decks/${widget.deck.name}/$fileName';
    
    await Directory('${directory.path}/decks/${widget.deck.name}').create(recursive: true);
    await File(imagePath).copy(newPath);

    setState(() {
      widget.deck.imagePaths.add(newPath);
      Hive.box('decks').put(widget.deck.name, {
        'name': widget.deck.name,
        'imagePaths': widget.deck.imagePaths
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name)),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.deck.imagePaths.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.deck.imagePaths.length) {
            return IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: _addImage,
            );
          }
          return Image.file(File(widget.deck.imagePaths[index]));
        },
      ),
    );
  }
}
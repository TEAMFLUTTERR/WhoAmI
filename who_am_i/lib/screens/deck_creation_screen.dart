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
  const DecksPage({super.key});

  @override
  _DecksPageState createState() => _DecksPageState();
}

/*class _DecksPageState extends State<DecksPage> {
  late Box decksBox;
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    //Hive.deleteBoxFromDisk('decks');
    _openBoxAndLoadDecks();
  }

  Future<void> _openBoxAndLoadDecks() async {
    decksBox = await Hive.openBox('decks');
    _loadDecks();
  }

  void _loadDecks() {
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
        title: const Text('Neues Deck erstellen'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Deck Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final String deckName = nameController.text.trim();
              if (deckName.isNotEmpty) {
                final existingDeck = decksBox.values.firstWhere(
                  (dynamic value) => value['name'] == deckName,
                  orElse: () => null,
                );
                if (existingDeck == null) {
                  decksBox.put(deckName, {
                    'name': deckName,
                    'imagePaths': [],
                  });
                  _loadDecks();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Ein Deck mit diesem Namen existiert bereits.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
              Navigator.of(context).pop();
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Decks')),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}*/
class _DecksPageState extends State<DecksPage> {
  late Box decksBox;
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    //Hive.deleteBoxFromDisk('decks');
    _openBoxAndLoadDecks();
  }

  Future<void> _openBoxAndLoadDecks() async {
    decksBox = await Hive.openBox('decks');
    _loadDecks();
  }

  void _loadDecks() {
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
        title: const Text('Neues Deck erstellen'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Deck Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              final String deckName = nameController.text.trim();
              if (deckName.isNotEmpty) {
                final existingDeck = decksBox.values.firstWhere(
                  (dynamic value) => value['name'] == deckName,
                  orElse: () => null,
                );
                if (existingDeck == null) {
                  // Save the new deck in Hive using the deck name as the key
                  decksBox.put(deckName, {
                    'name': deckName,
                    'imagePaths': [],
                  });
                  // Directly update the state with the new deck
                  setState(() {
                    decks.add(Deck(name: deckName, imagePaths: []));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Ein Deck mit diesem Namen existiert bereits.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                // Debugging output
                print('Current keys in Hive box: ${decksBox.keys}');
                print('Current values in Hive box: ${decksBox.values}');
              }
              Navigator.of(context).pop();
            },
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Decks')),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DeckDetailPage extends StatefulWidget {
  final Deck deck;

  const DeckDetailPage({super.key, required this.deck});

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
                leading: const Icon(Icons.camera),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _saveImage(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Datei auswählen'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
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
        title: const Text('Bild benennen'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Bildname'),
        ),
        actions: [
          TextButton(
            child: const Text('Speichern'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    // Get the directory and create a unique filename
    final directory = await getApplicationDocumentsDirectory();
    final fileName = nameController.text.isNotEmpty
        ? '${nameController.text}.jpg'
        : '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newPath = '${directory.path}/decks/${widget.deck.name}/$fileName';

    await Directory('${directory.path}/decks/${widget.deck.name}')
        .create(recursive: true);
    await File(imagePath).copy(newPath);

    setState(() {
      widget.deck.imagePaths.add(newPath);
      // Debugging output
      print('keys in Hive box (_saveImage): ${Hive.box('decks').keys}');
      print('values in Hive box (_saveImage): ${Hive.box('decks').values}');
      // put updates an entry (if exists otherwise adds it) but it use the key provided by user: The problem here was that,
      // when the user created the Deck for the first time, the key was per default as index
      // beginning with 0 because you used decksBox.add() in createDialog show command!
      // that creates the entry but using index value as key, now here in saveimage, you used
      // put() wher you provid the key as deckname: but that doesn't exists, so it created anew entry with key as deckname
      Hive.box('decks').put(widget.deck.name,
          {'name': widget.deck.name, 'imagePaths': widget.deck.imagePaths});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.deck.imagePaths.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.deck.imagePaths.length) {
            return IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _addImage,
            );
          }
          return Image.file(File(widget.deck.imagePaths[index]));
        },
      ),
    );
  }
}

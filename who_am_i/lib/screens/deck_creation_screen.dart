import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DeckManager extends StatefulWidget {
  @override
  _DeckManagerState createState() => _DeckManagerState();
}

class _DeckManagerState extends State<DeckManager> {
  final ImagePicker _picker = ImagePicker();
  Directory? _appDirectory;
  Directory? _decksDirectory;
  List<String> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFolders();
  }

  Future<void> _initializeFolders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Hauptspeicherpfad abrufen
      _appDirectory = await getApplicationDocumentsDirectory();
      _decksDirectory = Directory('${_appDirectory!.path}/Decks');

      if (!await _decksDirectory!.exists()) {
        await _decksDirectory!.create(recursive: true);
      }

      // Lade bestehende Decks
      _loadDecks();
    } catch (e) {
      print('Fehler beim Initialisieren der Ordner: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadDecks() {
    setState(() {
      _decks = _decksDirectory!
          .listSync()
          .where((entity) => entity is Directory)
          .map((e) => e.path.split('/').last)
          .toList();
    });
  }

  Future<void> _createNewDeck() async {
    try {
      if (_decksDirectory == null) {
        throw Exception('Decks-Verzeichnis ist noch nicht bereit.');
      }

      final deckName = 'Deck_${DateTime.now().millisecondsSinceEpoch}';
      final newDeckPath = '${_decksDirectory!.path}/$deckName';

      // Ordner erstellen
      await Directory(newDeckPath).create();

      // UI aktualisieren
      setState(() {
        _decks.add(deckName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deckName wurde erstellt!')),
      );
    } catch (e) {
      print('Fehler beim Erstellen des Decks: $e');
    }
  }

  Future<void> _addImageToDeck(String deckName, {required bool fromCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image != null && _decksDirectory != null) {
        final deckPath = '${_decksDirectory!.path}/$deckName';
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newImagePath = '$deckPath/$fileName';

        await File(image.path).copy(newImagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bild in $deckName gespeichert!')),
        );
      }
    } catch (e) {
      print('Fehler beim Hinzufügen eines Bildes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Deck Manager')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewDeck,
          ),
        ],
      ),
      body: _decks.isEmpty
          ? Center(
              child: Text(
                'Keine Decks gefunden. Drücke auf "+" um ein neues Deck zu erstellen.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                final deckName = _decks[index];
                return ListTile(
                  title: Text(deckName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: () => _addImageToDeck(deckName, fromCamera: false),
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () => _addImageToDeck(deckName, fromCamera: true),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

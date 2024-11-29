import 'package:flutter/material.dart';

class ExplanationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wie funktioniert die App?'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepCard(
              stepNumber: 1,
              title: 'Neues Deck erstellen',
              description: 'Beginnen Sie, indem Sie ein neues Deck anlegen. '
                  'In diesem Deck können Sie Bilder von Personen hinzufügen, '
                  'die Sie später im Spiel erkennen möchten.',
              icon: Icons.add_box_outlined,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              stepNumber: 2,
              title: 'Bilder hinzufügen',
              description: 'Fügen Sie Bilder mit den Namen der Personen '
                  'zu Ihrem Deck hinzu. Stellen Sie sicher, dass die '
                  'Bilder klar und erkennbar sind.',
              icon: Icons.image_outlined,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              stepNumber: 3,
              title: 'Spiel vorbereiten',
              description: 'Drücken Sie "Spielen starten". Wählen Sie dann '
                  'ein Deck aus, geben Sie die Anzahl der Spieler an und '
                  'wählen Sie eine Spielzeit.',
              icon: Icons.settings_outlined,
            ),
            SizedBox(height: 16),
            _buildStepCard(
              stepNumber: 4,
              title: 'Spielablauf',
              description: 'Das Spiel beginnt! Für jedes gezeigte Bild:',
              icon: Icons.play_arrow_outlined,
              subSteps: [
                '- Kippen Sie das Handy nach RECHTS, wenn das Bild richtig erkannt wurde',
                '- Kippen Sie das Handy nach LINKS, wenn das Bild falsch geraten wurde',
                '- Nach jeder Antwort kommt der nächste Spieler an die Reihe'
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    List<String>? subSteps,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Icon(icon, color: Colors.blue.shade700),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            if (subSteps != null) ...[
              SizedBox(height: 12),
              ...subSteps.map((step) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4),
                    child: Text(
                      step,
                      style: TextStyle(fontSize: 15),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

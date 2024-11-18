// import 'package:flutter/material.dart';
// import '../models/player.dart';

// class LeaderboardScreen extends StatelessWidget {
//   final List<Player> players;

//   const LeaderboardScreen({Key? key, required this.players}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Sort players by score in descending order
//     players.sort((a, b) => b.score.compareTo(a.score));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leaderboard'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Leaderboard',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: players.length,
//                 itemBuilder: (context, index) {
//                   final player = players[index];
//                   return ListTile(
//                     leading: CircleAvatar(
//                       child: Text((index + 1).toString()),
//                     ),
//                     title: Text(
//                       player.name,
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     trailing: Text(
//                       '${player.score} points',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'presentation/screens/playlists_screen.dart';
import '../../utils/theme.dart';


void main() {
  runApp(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: const PlaylistScreen(),
    ),
  );
}

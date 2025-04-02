import 'package:flutter/material.dart';

/// Object that represents a tile on the game grid
class PathTile {
  // x coordinate
  int xCoord;
  // y coordinate
  int yCoord;

  // is part of the path
  bool active;

  // current status of the tile
  TileStatus status;

  PathTile({
    required this.xCoord,
    required this.yCoord,
    required this.active,
    required this.status,
  });

  /// overrides toString() and prints "[xCoord],[yCoord]"
  @override
  String toString() {
    return "$xCoord,$yCoord";
  }
}

/// Represents the status of a current tile
/// [active] highlighting the current path to follow
/// [error] highlights when an incorrect tile is selected
/// [positive] highlights when a correct tile is selected
/// [normal] tile is not highlighted
enum TileStatus { active, error, positive, normal }

extension TileStatusExtension on TileStatus {
  /// returns a gradient based of the current tile status
  LinearGradient tileColor() {
    switch (this) {
      case (TileStatus.active):
        return LinearGradient(
          colors: [Colors.blue.withOpacity(0.8), Colors.blue.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case (TileStatus.error):
        return LinearGradient(
          colors: [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case (TileStatus.positive):
        return LinearGradient(
          colors: [
            Colors.green.withOpacity(0.8),
            Colors.green.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case (TileStatus.normal):
        return LinearGradient(colors: [Colors.white, Colors.white]);
    }
  }
}

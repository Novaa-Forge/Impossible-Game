import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:impossible_game/src/controller/audio_controller.dart';
import 'dart:math';

import 'package:impossible_game/src/model/path_tile.dart';

/// Controller used to manage the state for the overall game
class GameController extends ChangeNotifier {
  // represents the level that the user is currently on
  int levelNumber = 1;
  // maximum level, completion of this level wins the game
  int maxLevel = 12;
  // rows in the grid
  int rows = 6;
  // columns in the grid
  int columns = 6;

  // holds status of all game tiles (true or false depending on if its in the path)
  List<List<PathTile>> gameTiles = [];

  // holds a list of PathTiles that progress through the level
  List<PathTile> path = [];

  // current position in the path
  int currentTileInPath = 0;

  // flag to show if the player has started selecting tiles this round
  bool firstTileSelected = false;

  // current status of the game
  GameStatus gameStatus = GameStatus.inProgress;

  // milliseconds taken on current level
  int levelPlayTime = 0;

  /// Starts the level timer
  void startTimer() {
    levelPlayTime = 0;
    Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      levelPlayTime += 100;
      // if user selected red tile or the level has been completed, stop the timer
      if (gameStatus == GameStatus.failed ||
          gameStatus == GameStatus.levelComplete) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  /// update all game parameters associated with a level progression
  void progressLevel() {
    levelNumber++;
    rows++;
    columns++;
  }

  /// reset the game back to the first level (e.g., when user selects red tile
  void resetGame() {
    levelNumber = 1;
    rows = 5;
    columns = 5;
  }

  /// Handles logic to assess whether a tile selected by the player is on the path or not
  void selectTile(int x, int y) {
    // first tile selection starts the timer and forces other tile markers to disappear
    if (!firstTileSelected) {
      firstTileSelected = true;
      startTimer();
      resetAllTileStatus();
    }

    // if the tile selected matches the next tile in the path
    if (path[currentTileInPath].yCoord == y &&
        path[currentTileInPath].xCoord == x) {
      currentTileInPath++;
      gameTiles[x][y].status = TileStatus.positive;
      // if the user has reached the end of the level (i.e., selected all tiles in path)
      if (currentTileInPath >= path.length) {
        gameStatus = GameStatus.levelComplete;
        AudioController.playSfx(SfxType.complete);
        // if the user has completed all of the levels
        if (levelNumber == maxLevel) {
          gameStatus = GameStatus.completed;
        }
      } else {
        AudioController.playSfx(SfxType.positive);
      }
    }
    // if the tile selected is not the next one in the path
    else {
      gameTiles[x][y].status = TileStatus.error;
      gameStatus = GameStatus.failed;
      AudioController.playSfx(SfxType.negative);
    }
    notifyListeners();
  }

  /// turns all of the tiles from the blue color to white
  /// hiding the path from the user. called when the user selects the first tile
  void resetAllTileStatus() {
    for (int i = 0; i < gameTiles.length; i++) {
      for (int j = 0; j < gameTiles[i].length; j++) {
        gameTiles[i][j].status = TileStatus.normal;
      }
    }
    notifyListeners();
  }

  /// generates a new path. Typically called when the level first loads
  void generatePath() {
    // first reset all of the game settings from any previous levels
    currentTileInPath = 0;
    gameTiles = [];
    path = [];
    firstTileSelected = false;
    gameStatus = GameStatus.inProgress;
    levelPlayTime = 0;

    // sets the grid to an all false state.
    gameTiles = List.generate(columns, (col) {
      return List.generate(rows, (row) {
        return PathTile(
          xCoord: col,
          yCoord: row,
          active: false,
          status: TileStatus.normal,
        );
      });
    });

    // set random number generator
    final random = Random();

    // used to track horizontal progress through the maze for the path generation
    int currentColumn = 0;

    // pick first number
    int currentRow = random.nextInt(rows);

    // set randomly selected starting tile in the grid to active
    gameTiles[currentRow][0].active = true;
    gameTiles[currentRow][0].status = TileStatus.active;

    // add the starting tile to the path list
    path.add(gameTiles[currentRow][0]);
    notifyListeners();

    // while the path has not yet reached the farthest right hand side.
    while (currentColumn < columns - 1) {
      // select new direction [0] == up, [1] == right, [2] == down
      int nextDirection = random.nextInt(3);
      if (checkDirectionIsPossible(nextDirection, currentColumn, currentRow)) {
        // progress
        switch (nextDirection) {
          case (0):
            currentRow -= 1;
            break;
          case (1):
            currentColumn += 1;
            break;
          case (2):
            currentRow += 1;
            break;
          default:
            break;
        }
        // update tile grid with latest tile in the path.
        gameTiles[currentRow][currentColumn].active = true;
        gameTiles[currentRow][currentColumn].status = TileStatus.active;
        // save next position into the path.
        path.add(gameTiles[currentRow][currentColumn]);
      }
    }
    notifyListeners();
  }

  /// checks if the next randomly selected tile from the path generator
  /// is feasible based on the current position and direction
  bool checkDirectionIsPossible(int direction, currentX, currentY) {
    switch (direction) {
      case (0): // if direction is up
        // if already on top row or the tile above is already active.
        if (currentY == 0 || gameTiles[currentY - 1][currentX].active) {
          return false;
        }
      case (1): // if direction is right
        return true;
      case (2): // if direction is down
        // if already on bottom row or tile below is already active.
        if (currentY == rows - 1 || gameTiles[currentY + 1][currentX].active) {
          return false;
        }
      default: // if any other number is provided that isnt 0,1,2.
        return false;
    }
    // if there are other adjoining tiles around the proposed next tile
    if (checkAdjoiningTiles(direction, currentX, currentY)) {
      return false;
    }
    // otherwise... return true, the move is valid.
    return true;
  }

  /// Checks if the proposed next tile has any tiles around it on the grid that
  /// area already part of the path.
  bool checkAdjoiningTiles(int direction, int currentX, int currentY) {
    int nextX = currentX;
    int nextY = currentY;
    if (direction == 0) {
      // up
      nextY--;
    }
    if (direction == 1) {
      // right
      nextX++;
    }
    if (direction == 2) {
      // down
      nextY++;
    }
    // if out of bounds, return false
    if (nextY < 0 || nextY > rows - 1 || nextX < 0 || nextX > columns - 1) {
      return false;
    }

    // will hold a list of tiles with a flag identifying if they're part of the path
    List<bool> surroundingTiles = [];

    /// 0 - 2 relates to the following grid format
    /// _,0,_
    /// 1,_,_
    /// _,2,_
    /// for each surrounding adjacent tile
    for (int i = 0; i < 4; i++) {
      switch (i) {
        case (0):
          if (nextY - 1 >= 0) {
            // if above is not out of bounds
            surroundingTiles.add(gameTiles[nextY - 1][nextX].active);
          } else {
            (surroundingTiles.add(false));
          }
          break;
        case (1):
          if (nextX - 1 >= 0) {
            // if left is not out of bounds
            surroundingTiles.add(gameTiles[nextY][nextX - 1].active);
          } else {
            surroundingTiles.add(false);
          }
          break;
        case (2):
          if (nextY + 1 < rows) {
            // if below is not out of bounds
            surroundingTiles.add(gameTiles[nextY + 1][nextX].active);
          } else {
            surroundingTiles.add(false);
          }
          break;
      }
    }
    // removes direction where it came from
    if (direction == 0) {
      surroundingTiles.removeAt(2);
    } else if (direction == 1) {
      surroundingTiles.removeAt(1);
    } else if (direction == 2) {
      surroundingTiles.removeAt(0);
    }

    // returns true if either other directions contained a previous stepped tile
    return surroundingTiles.contains(true);
  }

  bool checkIfPositiveTile(int x, int y) {
    return true;
  }
}

/// Holds the status of the current game
/// [inProgress] game has started
/// [levelComplete] user has just completed a level
/// [failed] user has just pressed an incorrect tile
/// [completed] user has completed all levels
enum GameStatus { inProgress, levelComplete, failed, completed }

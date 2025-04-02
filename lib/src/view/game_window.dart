import 'package:flutter/material.dart';
import 'package:impossible_game/src/controller/game_controller.dart';
import 'package:impossible_game/src/model/path_tile.dart';
import 'package:provider/provider.dart';

import '../consts.dart';

/// Main scaffold widget that displays the game window (e.g., grid with tiles)
class GameWindow extends StatefulWidget {
  const GameWindow({super.key});

  @override
  State<GameWindow> createState() => _GameWindowState();
}

class _GameWindowState extends State<GameWindow> {
  late GameController gameController = context.watch<GameController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - bottomPanelHeight,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,

                  spacing: 5,
                  children: List.generate(gameController.rows, (rowIndex) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: List.generate(gameController.columns, (
                        colIndex,
                      ) {
                        return GameTile(rowIndex: rowIndex, colIndex: colIndex);
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
          SizedBox(
            height: bottomPanelHeight.toDouble(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text(
                      "Time on level",
                      style: TextStyle(fontFamily: "Saira"),
                    ),
                    Container(
                      height: 100,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (gameController.levelPlayTime / 1000).toString(),
                          style: TextStyle(fontFamily: "Saira", fontSize: 36),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    Text(
                      "Game Progress",
                      style: TextStyle(fontFamily: "Saira"),
                    ),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value:
                            gameController.levelNumber /
                            gameController.maxLevel,
                        color: Colors.deepPurple,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that represents the tiles that are combined to be the grid
class GameTile extends StatelessWidget {
  GameTile({super.key, required this.rowIndex, required this.colIndex});

  // x position in a row
  final int rowIndex;

  // y position in a column
  final int colIndex;

  @override
  Widget build(BuildContext context) {
    GameController gameController = context.watch<GameController>();

    double cellWidth =
        MediaQuery.of(context).size.width / gameController.columns - 5;
    double cellHeight =
        (MediaQuery.of(context).size.height - bottomPanelHeight) /
            gameController.rows -
        5;

    return GestureDetector(
      onTap: () {
        gameController.selectTile(rowIndex, colIndex);
        if (gameController.gameStatus == GameStatus.levelComplete) {
          showSuccessPopupDialog(context, gameController);
        } else if (gameController.gameStatus == GameStatus.failed) {
          showFailurePopupDialog(context, gameController);
        } else if (gameController.gameStatus == GameStatus.completed) {
          showGameCompletedPopupDialog(context, gameController);
        }
      },
      child: Container(
        width: cellWidth,
        height: cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10), // Optional rounded corners
        ),
        padding: EdgeInsets.all(3),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient:
                gameController.gameTiles.isNotEmpty
                    ? gameController.gameTiles[rowIndex][colIndex].status
                        .tileColor()
                    : LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ), // Inner container color
            borderRadius: BorderRadius.circular(5), // Match the border radius
          ),
          child:
              gameController.path.isNotEmpty
                  ? gameController.path[0].xCoord == rowIndex &&
                          gameController.path[0].yCoord == colIndex
                      ? Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Start",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      )
                      : Container()
                  : Container(),
        ),
      ),
    );
  }

  /// Shows a dialog popup when the user completes a level
  void showSuccessPopupDialog(BuildContext context, GameController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(8.0),
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Level ${controller.levelNumber} complete',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${controller.levelPlayTime / 1000} seconds',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.progressLevel();
                      controller.generatePath();
                      Navigator.of(context).pop();
                    },
                    child: Text('Next Level'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  /// shows a popup dialog when the entire game is completed
  void showGameCompletedPopupDialog(
    BuildContext context,
    GameController controller,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 400,
              height: 300,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'You\'ve completed all ${controller.maxLevel} levels of this impossible game!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Icon(Icons.celebration, size: 30),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.resetGame();
                      Navigator.of(context).pop(); //pops the dialog
                      Navigator.of(context).pop(); //pops the page
                    },
                    child: Text('Restart'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }

  /// shows a popup dialog when an incorrect tile is selected
  void showFailurePopupDialog(BuildContext context, GameController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(8.0),

              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Oh no!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'You clicked off the path',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.resetGame();
                      controller.generatePath();
                      Navigator.of(context).pop();
                    },
                    child: Text('Restart'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }
}

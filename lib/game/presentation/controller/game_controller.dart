import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

enum GameStates {
  start,
  gridCreating,
  gridCreatingEnd,
  gridCreated,
  searching,
  maybeWantToDoneSearching,
  end;
}

class GameController {
  final int rows;
  final int columns;

  late final List<List<TextEditingController>> _cellTextControllers;
  final TextEditingController searchController;

  late List<List<bool>> _matchingCells;
  bool isHighlighted(int index) {
    final point = getGridPosition(index);
    return _matchingCells[point.$1][point.$2];
  }

  List<List<TextEditingController>> get textEditingControllers =>
      List.unmodifiable(_cellTextControllers);

  GameController({required this.rows, required this.columns})
      : searchController = TextEditingController() {
    _cellTextControllers = _setCells();
    _matchingCells = _resetMatchingCells();
    start();
  }

  final _lifeCycleEvent = BehaviorSubject<GameStates>();

  ValueStream<GameStates> get lifeCycleEvent => _lifeCycleEvent.stream;

  bool checkAllFilled() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (_cellTextControllers[i][j].text.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void start() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        _cellTextControllers[i][j].addListener(() {
          if (checkAllFilled()) {
            _lifeCycleEvent.add(GameStates.gridCreatingEnd);
          }
        });
      }
    }

    searchController.addListener(() {
      String searchText = searchController.text.trim();
      _matchingCells = _resetMatchingCells();

      if (searchText.isEmpty) {
        _lifeCycleEvent.add(GameStates.maybeWantToDoneSearching);
        return;
      } else {
        _lifeCycleEvent.add(GameStates.searching);
      }

      _search(searchText);
    });

    _lifeCycleEvent.add(GameStates.start);
  }

  void _search(String searchText) {
    searchText = searchText.toLowerCase();

    // for single letter
    if (searchText.length == 1) {
      searchLetter(searchText);
      return;
    }
    // * for multiple letter
    // List<String> searchLetters = searchText.split("");

    // 1. left to right
    if (searchText.length <= columns) {
      findLeftToRight(searchText);
    }
    // 2. top to bottom
    if (searchText.length <= rows) {
      findTopToBottom(searchText);
    }
    // 3. top left to right bottom
    if (searchText.length <= columns * rows) {
      findDiagonally(searchText);
    }
  }

  void searchLetter(String searchText) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        String cellText = _cellTextControllers[i][j].text.toLowerCase();
        if (_cellTextControllers[i][j].text.toLowerCase() == searchText) {
          if (cellText == searchText) {
            _matchingCells[i][j] = true;
            continue;
          }
        }
      }
    }
  }

  void findLeftToRight(String searchText) {
    // check in row horizontally
    for (int i = 0; i < rows; i++) {
      final row = _cellTextControllers[i].map((e) => e.text).toList();
      final currentText = row.join("");

      final windowLength = searchText.length;
      int startIndex = 0;
      int endIndex = startIndex + windowLength;

      while (endIndex <= columns) {
        if (currentText.substring(startIndex, endIndex) == searchText) {
          for (int j = startIndex; j < endIndex; j++) {
            _matchingCells[i][j] = true;
          }
          startIndex = endIndex + 1;
          endIndex = startIndex + windowLength;
        } else {
          startIndex++;
          endIndex++;
        }
      }
    }
  }

  void findTopToBottom(String searchText) {
    // check in row vertically
    for (int i = 0; i < columns; i++) {
      String row = "";
      for (int j = 0; j < rows; j++) {
        row += _cellTextControllers[j][i].text;
      }
      final currentText = row;

      final windowLength = searchText.length;
      int startIndex = 0;
      int endIndex = startIndex + windowLength;

      while (endIndex <= rows) {
        if (currentText.substring(startIndex, endIndex) == searchText) {
          for (int j = startIndex; j < endIndex; j++) {
            _matchingCells[j][i] = true;
          }
          startIndex = endIndex + 1;
          endIndex = startIndex + windowLength;
        } else {
          startIndex++;
          endIndex++;
        }
      }
    }
  }

  void findDiagonally(String searchText) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        final currentLetter = _cellTextControllers[i][j].text;
        if (currentLetter != searchText[0]) continue;

        final windowLength = searchText.length;
        (int, int) startPoint = (i, j);
        (int, int) endPoint = (
          startPoint.$1 + windowLength - 1,
          startPoint.$2 + windowLength - 1
        );
        while (endPoint.$1 < rows && endPoint.$2 < columns) {
          String text = "";
          for (int k = 0; k < windowLength; k++) {
            final point = (startPoint.$1 + k, startPoint.$2 + k);
            text += (_cellTextControllers[point.$1][point.$2].text);
          }
          if (text == searchText) {
            for (int k = 0; k < windowLength; k++) {
              final point = (startPoint.$1 + k, startPoint.$2 + k);
              _matchingCells[point.$1][point.$2] = true;
            }
            startPoint = (endPoint.$1 + 1, endPoint.$2 + 1);
            endPoint = (
              startPoint.$1 + windowLength - 1,
              startPoint.$2 + windowLength - 1
            );
          } else {
            startPoint = (startPoint.$1 + 1, startPoint.$2 + 1);
            endPoint = (endPoint.$1 + 1, endPoint.$2 + 1);
          }
        }
      }
    }
  }

  List<List<bool>> _resetMatchingCells() =>
      List.generate(rows, (index) => List.generate(columns, (index) => false));

  List<List<TextEditingController>> _setCells() => List.generate(rows,
      (index) => List.generate(columns, (index) => TextEditingController()));

  (int, int) getGridPosition(int index) {
    return ((index / columns).truncate(), index % columns);
  }

  void endCreatingGrid() {
    _lifeCycleEvent.add(GameStates.gridCreated);
  }

  void endSearching() {
    _lifeCycleEvent.add(GameStates.gridCreating);
  }

  void dispose() {
    for (var controllerRows in _cellTextControllers) {
      for (var controller in controllerRows) {
        controller.dispose();
      }
    }

    searchController.dispose();
    _lifeCycleEvent.add(GameStates.end);
    _lifeCycleEvent.close();
  }
}

import 'package:flutter/material.dart';

enum AnswerCategory { animals, humanBody, sports, technology }
enum Difficulty { easy, medium, hard }

class GameController extends ChangeNotifier {
  AnswerCategory? selectedCategory;
  Difficulty? selectedDifficulty;
  
  int errors = 0;
  final int maxErrors = 6;
  bool isGameOver = false;
  bool isGameWon = false;

  void setCategory(AnswerCategory category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setDifficulty(Difficulty difficulty) {
    selectedDifficulty = difficulty;
    notifyListeners();
  }

  void resetGame() {
    errors = 0;
    isGameOver = false;
    isGameWon = false;
    notifyListeners();
  }
}
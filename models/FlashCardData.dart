import "package:collection/collection.dart";
import "package:flutter/widgets.dart";

import "./FlashCard.dart";
import "../utils/database.dart";

class FlashCardData with ChangeNotifier {
  List<FlashCard> _flashCardsList = <FlashCard>[];
  bool _isDone = false;

  get flashCardsList => _flashCardsList;
  get allDone => _isDone;

  void isDone(String deckID) {
    if (nextCard(deckID) == null)
      _isDone = true;
    else 
      _isDone = false;
  }

  int getNumberOfDue(String deckID) {
    return _flashCardsList
        .where((fc) => ((fc.deck.id == deckID) && fc.isDue() == true))
        .length;
  }

  int getNumberOfLater(String deckID) {
    return _flashCardsList
        .where((fc) => ((fc.deck.id == deckID) && fc.isLater() == true))
        .length;
  }

  int getNumberOfCards(String deckID) {
    return _flashCardsList.where((fc) => fc.deck.id == deckID).length;
  }

  FlashCard nextCard(String deckID) {
    return _flashCardsList
        .firstWhere((fc) => ((fc.deck.id == deckID) && fc.isDue()));
  }

  Map<DateTime, List<FlashCard>> getSchedule() {
    Map<DateTime, List<FlashCard>> schedule = groupBy(_flashCardsList, (fc) {
      return fc.dueDate;
    });
    return schedule;
  }

  void add(FlashCard fc) async {
    _flashCardsList.add(fc);
    await Database.insert(fc);
    notifyListeners();
  }

  void update(FlashCard fc) async {
    await Database.update(fc);
    notifyListeners();
  }

  void delete(String id) async {
    _flashCardsList.removeWhere((fc) => fc.id == id);
    await Database.delete(id);
    notifyListeners();
  }

  Future read() async {
    _flashCardsList = await Database.read();
    notifyListeners();
  }
}

import "package:flutter/foundation.dart";

import "../utils/database.dart";

class Deck{
  String id;
  String deckName;

Deck({this.id, @required this.deckName});
toMap() {
  return {"id": id, "deckName": deckName,};
  }
static Deck fromMap(var map) {
  return Deck(
    id: map["id"], 
    deckName: map["deckName"]);
  }
}

class Decks with ChangeNotifier{
  List<Deck> _decksList = <Deck>[];
  get decksList => _decksList;

  void addDeck(Deck deck) async {
    _decksList.add(deck);
    await Database.addDeck(deck);
    notifyListeners();
  }
  void deleteDeckAndCards(String deckID) async {
    _decksList.removeWhere((deck) => deck.id == deckID );
    //delete flashcards that are in this deck
    await Database.deleteCardsFromDeletedDeck(deckID);
    await Database.deleteDeck(deckID);
    notifyListeners();
  }
  Future getDecks() async {
    _decksList = await Database.getDecks();
    notifyListeners();
  }
  
}
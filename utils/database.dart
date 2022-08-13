import "package:sembast/sembast_io.dart";
import "package:sembast/sembast.dart";
import "package:path_provider/path_provider.dart" as path;
import "package:path/path.dart";

import "../models/Deck.dart";
import "../models/FlashCard.dart";

class Database {
  static StoreRef<int, Map<String, dynamic>> st() =>
      intMapStoreFactory.store("masters");

  static StoreRef<int, Map<String, dynamic>> deckStore() =>
      intMapStoreFactory.store("decks");

  static Future database() async {
    var dir = await path.getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, "fikira.db");
    var db = await databaseFactoryIo.openDatabase(dbPath);
    return db;
  }

  //###DECK###
  static Future addDeck(Deck deck) async {
    final db = await database();
    var store = deckStore();
    return await store.add(db, deck.toMap());
  }

  static Future getDecks() async {
    final db = await database();
    var store = deckStore();
    final snapshots = await store.find(db);
    return List.generate(snapshots.length, (int index) {
      return Deck.fromMap(snapshots[index]);
    });
  }

  static Future deleteDeck(String id) async {
    final db = await database();
    var store = deckStore();
    var filter = Filter.matches("id", id);
    var finder = Finder(filter: filter);
    return await store.delete(db, finder: finder);
  }

  //###FLASHCARDS###
  static Future getNumberOfCards() async {
    final db = await database();
    var store = st();
    return await store.count(db);
  }
  static Future insert(FlashCard fc) async {
    final db = await database();
    var store = st();
    return await store.add(db, fc.toMap());
  }

  static Future update(FlashCard fc) async {
    final db = await database();
    var store = st();
    var filter = Filter.matches("id", fc.id);
    var finder = Finder(filter: filter);
    return await store.update(db, fc.toMap(), finder: finder);
  }

  static Future<List<FlashCard>> read() async {
    final db = await database();
    var store = st();
    final snapshots = await store.find(db);
    return List.generate(snapshots.length, (int index) {
      return FlashCard.fromMap(snapshots[index]);
    });
  }

  static Future<void> deleteCardsFromDeletedDeck(String deckID) async {
    final db = await database();
    var store = st();
    var filter = Filter.matches("deckID", deckID);
    var finder = Finder(filter: filter);
    return await store.delete(db, finder: finder);
  }

  static Future delete(String id) async {
    final db = await database();
    var store = st();
    var filter = Filter.matches("id", id);
    var finder = Finder(filter: filter);
    return await store.delete(db, finder: finder);
  }
}

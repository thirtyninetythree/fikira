import "dart:io";

import "package:flutter/cupertino.dart";

import '../models/Deck.dart';

enum Rating { Again, Hard, Good, Easy }

class FlashCard {
  String id;
  Deck deck;
  String title;
  String content;
  File titleImage;
  Rating rating;
  DateTime ts;
  DateTime dueDate;
  double easeFactor;
  int reviews;

  FlashCard({
    @required this.id,
    @required this.deck,
    @required this.title,
    @required this.content,
    this.rating,
    @required this.ts,
    @required this.dueDate,
    this.easeFactor = 2.5,
    this.reviews = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "deck": this.deck.toMap(),
      "title": this.title,
      "content": this.content,
      "ts": this.ts.toIso8601String(),
      "dueDate": this.dueDate.toString(),
      "easeFactor": this.easeFactor,
      "reviews": this.reviews,
    };
  }

  static FlashCard fromMap(var map) {
    return FlashCard(
      id: map["id"].toString(),
      deck: Deck(id: map["deck"]["id"], deckName: map["deck"]["deck"]),
      title: map["title"],
      content: map["content"],
      ts: DateTime.tryParse(map["ts"]),
      dueDate: DateTime.tryParse(map["dueDate"]),
      easeFactor: map["easeFactor"],
      reviews: map["reviews"],
    );
  }

  void updateCardState(var rate) {
    this.ts = DateTime.now().toUtc();
    this.reviews += 1;
    this.rating = rate;
    this.calculateEaseFactor();
    this.calculateDueDate();
  }

  void calculateEaseFactor() {
    this.easeFactor = this.easeFactor +
        (0.1 -
            (3 - this.rating.index) * (0.08 + (3 - this.rating.index) * 0.02));
    if (this.easeFactor < 1.3) this.easeFactor = 1.3;
  }

  void calculateDueDate() {
    //only calculate dueDate when card is due or new
    if (this.reviews == 1 || this.rating.index < 2)
      this.dueDate = this.ts.add(Duration(days: 1));
    else if (this.reviews == 2 || this.rating.index < 2)
      this.dueDate = this.ts.add(Duration(days: 6));
    else {
      this.dueDate = this
          .ts
          .add(Duration(days: (this.reviews - 1) * this.easeFactor.floor()));
    }
    this.dueDate =
        (DateTime(dueDate.year, dueDate.month, dueDate.day, 15).toUtc());
  }

  bool isDue() {
    final now = DateTime.now();
    return ((this.dueDate?.isBefore(DateTime.now()) ?? true) ||
        this.dueDate == DateTime(now.year, now.month, now.day) ||
        this.reviews == 0);
  }

  bool isLater() {
    return this.dueDate.isAfter(DateTime.now());
  }
}

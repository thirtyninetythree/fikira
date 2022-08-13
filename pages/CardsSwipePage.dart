import "package:flutter/material.dart";

import "package:flutter_tindercard/flutter_tindercard.dart";
import "package:provider/provider.dart";

import "../models/Deck.dart";
import "../models/FlashCard.dart";
import "../models/FlashcardData.dart";

import "../widgets/FlashCardItem.dart";
import "../widgets/congrats.dart";

class CardsSwipePage extends StatefulWidget {
  static const routeName = "cardSwipe";
  @override
  _CardsSwipePageState createState() => _CardsSwipePageState();
}

class _CardsSwipePageState extends State<CardsSwipePage> {
  FlashCard fc, tmp;
  Deck deck;
  final _formKey = GlobalKey<FormState>();
  CardController controller;
  String title, content;
  var dimensions;
  bool showCard;

  @override
  void initState() {
    super.initState();
    showCard = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dimensions = MediaQuery.of(context).size;
    deck = ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(deck.deckName),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                iconSize: 48.0,
                onPressed: () {
                  buildShowAddNewFlashCardForm(context);
                }),
          ],
        ),
        body: Consumer<FlashCardData>(builder: (context, flashcards, child) {
          return Stack(children: <Widget>[
            Container(
              decoration: BoxDecoration(),
              child: TinderSwapCard(
                swipeUp: true,
                swipeDown: true,
                orientation: AmassOrientation.BOTTOM,
                totalNum: flashcards.getNumberOfDue(deck.id),
                stackNum: 3,
                swipeEdge: 4.0,
                maxWidth: dimensions.width * 0.9,
                maxHeight: dimensions.width * 0.9,
                minWidth: dimensions.width * 0.8,
                minHeight: dimensions.width * 0.8,
                cardBuilder: (context, index) {
                  tmp = flashcards.nextCard(deck.id);
                  return FlashCardItem(fc: tmp);
                },
                cardController: controller = CardController(),
                swipeUpdateCallback:
                    (DragUpdateDetails details, Alignment align) {},
                swipeCompleteCallback:
                    (CardSwipeOrientation orientation, int index) {
                  var rate;

                  if (orientation == CardSwipeOrientation.LEFT)
                    rate = Rating.Hard;
                  if (orientation == CardSwipeOrientation.RIGHT)
                    rate = Rating.Easy;
                  if (orientation == CardSwipeOrientation.UP)
                    rate = Rating.Good;
                  if (orientation == CardSwipeOrientation.DOWN)
                    rate = Rating.Again;
                  if (orientation != CardSwipeOrientation.RECOVER) {
                    tmp.updateCardState(rate);
                    flashcards.update(tmp);
                  }
                  if (flashcards.getNumberOfDue(deck.id) < 1)
                    setState(() {
                      showCard = true;
                    });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                      "CARDS ${flashcards.getNumberOfCards(deck.id).toString()}"),
                  Text("DUE ${flashcards.getNumberOfDue(deck.id).toString()}"),
                  Text(
                      "LATER ${flashcards.getNumberOfLater(deck.id).toString()}"),
                ],
              ),
            ),

            CongratsCard(showCard),

            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: dimensions.height * .4,
              right: showCard ? -100 : 0,
              child: Text(
                "EASY",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: showCard ? -dimensions.height * .2 : dimensions.height * .1,
              right: dimensions.width * .4,
              child: Text(
                "GOOD",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: dimensions.height * .4,
              left: showCard ? -100 : 0,
              child: Text(
                "HARD",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: showCard ? -40 : 0,
              left: dimensions.width * .4,
              child: Text(
                "AGAIN",
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),

            //CongratsCard(),
          ]);
        }),
      ),
    );
  }

  Future buildShowAddNewFlashCardForm(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "ADD NEW FLASHCARD",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "DECK: ${deck.deckName}",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: TextFormField(
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: "Add New Title",
                        labelText: "Title",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      onSaved: (value) => title = value,
                      validator: (value) {
                        if (value.isEmpty) return "Title cannot be empty";
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: TextFormField(
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: "Add New Body",
                        labelText: "Body",
                        labelStyle: const TextStyle(color: Colors.black),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                          borderSide: const BorderSide(
                              color: Colors.black12, width: 0.5),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSaved: (value) => content = value,
                      validator: (value) {
                        if (value.isEmpty) return "Body cannot be empty";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  OutlinedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black12,
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        final now = DateTime.now();
                        fc = FlashCard(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            deck: deck,
                            title: title,
                            content: content,
                            ts: now,
                            dueDate: (DateTime(now.year, now.month, now.day, 15)
                                .toUtc()));
                        Provider.of<FlashCardData>(context, listen: false)
                            .add(fc);
                        _formKey.currentState.reset();
                      }
                    },
                    child: Text(
                      "ADD",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

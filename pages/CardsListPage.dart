import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "../widgets/Badge.dart";
import "../models/Deck.dart";
import "../models/FlashCard.dart";
import "../models/FlashcardData.dart";
import "../pages/CardsSwipePage.dart";
import "../pages/SchedulePage.dart";

class CardsListPage extends StatefulWidget {
  @override
  _CardsListPageState createState() => _CardsListPageState();
}

class _CardsListPageState extends State<CardsListPage> {
  final _formKey = GlobalKey<FormState>();
  var deck, dimensions;

  Map<DateTime, List<FlashCard>> _events;

  @override
  void initState() {
    super.initState();
    Provider.of<FlashCardData>(context, listen: false).read();
    Provider.of<Decks>(context, listen: false).getDecks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dimensions = MediaQuery.of(context).size;
    _events = Provider.of<FlashCardData>(context, listen: false).getSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final fcProvider = Provider.of<FlashCardData>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          elevation: 0.0,
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                "FIKIRA",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text(
                "FLASHCARDS",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              iconSize: 48.0,
              onPressed: () {
                buildShowAddNewDeckForm(context);
              },
            ),
          ],
        ),
        body: Consumer<Decks>(builder: (context, decks, child) {
          return Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("DECKS ${decks.decksList?.length ?? 0}"),
                      OutlinedButton(
                        child: Text("YOUR SCHEDULE"),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              SchedulePage.routeName,
                              arguments: _events);
                        },
                        style: ButtonStyle(
                          // backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.black54),
                        ),
                      ),
                      Text("CARDS ${fcProvider.flashCardsList?.length ?? 0}"),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    itemCount: decks.decksList.length,
                    itemBuilder: (ctx, int index) => Card(
                      child: ListTile(
                        leading: Text(
                          decks.decksList[index].deckName[0]
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        title: Text(
                          decks.decksList[index].deckName,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Badge(
                          child: Icon(Icons.access_time),
                          value: fcProvider
                              .getNumberOfDue(decks.decksList[index].id)
                              .toString(),
                          color: Colors.orangeAccent,
                        ),
                        onTap: () => Navigator.of(context).pushNamed(
                            CardsSwipePage.routeName,
                            arguments: decks.decksList[index]),
                        onLongPress: () => buildShowDeleteDialogConfirmation(
                            context, decks, index),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future buildShowDeleteDialogConfirmation(
      BuildContext context, Decks decks, int index) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure?"),
              content: Text(
                  "Do you want to remove this deck and cards? \n${decks.decksList[index].deckName}"),
              actions: <Widget>[
                TextButton(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () {
                    decks.deleteDeckAndCards(decks.decksList[index].id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future buildShowAddNewDeckForm(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "ADD NEW DECK",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: TextFormField(
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: "Add New Deck",
                        labelText: "Deck",
                        labelStyle: TextStyle(color: Colors.black),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: const BorderSide(
                                color: Colors.black12, width: 0.5)),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSaved: (value) => deck = value,
                      validator: (value) {
                        if (value.isEmpty) return "This cannot be empty";
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
                        Provider.of<Decks>(context, listen: false).addDeck(Deck(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            deckName: deck));
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
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

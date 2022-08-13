import "package:fikira/pages/SchedulePage.dart";
import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "./pages/CardsListPage.dart";
import "./pages/CardsSwipePage.dart";
import "./models/FlashcardData.dart";
import "./models/Deck.dart";

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FlashCardData(),
          child: SchedulePage(),
        ),
        ChangeNotifierProvider(
          create: (context) => Decks(),
        ),
      ],
    child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "FIKIRA FLASHCARDS",
        theme: ThemeData(
          primaryColor: Color(0xFFF2F2F2),
          backgroundColor: Colors.white,
          accentColor: Colors.amberAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Raleway",
        ),
        home: CardsListPage(),
        routes: {
          CardsSwipePage.routeName: (context) => CardsSwipePage(),
          SchedulePage.routeName: (context) => SchedulePage(),
        },
    );
  }
}

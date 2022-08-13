import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "../models/FlashCard.dart";
import "../models/FlashcardData.dart";

class FlashCardItem extends StatefulWidget {
  final FlashCard fc;
  FlashCardItem({this.fc});
  @override
  _FlashCardItemState createState() => _FlashCardItemState();
}

class _FlashCardItemState extends State<FlashCardItem> {
  bool _isContentVisible;
  var provider;

  @override
  void initState() {
    super.initState();
    _isContentVisible = false;
    provider = Provider.of<FlashCardData>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        return buildShowDeleteDialogConfirmation(context);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(widget.fc.title),
            ),
            SizedBox(
              height: 64.0,
            ),
            if (_isContentVisible) Text(widget.fc.content),
            SizedBox(
              height: 64.0,
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
              child: _isContentVisible
                  ? Text("HIDE", style: TextStyle(color: Colors.black))
                  : Text("SHOW", style: TextStyle(color: Colors.black)),
              onPressed: () => setState(() {
                _isContentVisible = !_isContentVisible;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future buildShowDeleteDialogConfirmation(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Are you sure?"),
              content: Text(
                  "Do you want to remove this flashcard? \n${widget.fc.title}"),
              actions: <Widget>[
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    provider.delete(widget.fc.id);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ));
  }
}

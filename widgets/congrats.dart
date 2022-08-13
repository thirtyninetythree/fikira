import 'package:flutter/material.dart';

class CongratsCard extends StatelessWidget {
  bool allDone = false;

  CongratsCard(this.allDone);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedPositioned(
      left: size.width * .09,
      right: size.width * .09,
      top: allDone ? 100 : -420,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: RepaintBoundary(
        child: Card(
          shape: CircleBorder(),
          elevation: 12,
          child: Padding(
            padding:
                EdgeInsets.only(top: 130, left: 50, right: 50, bottom: 140),
            child: _CardContents(allDone),
          ),
        ),
      ),
    );
  }
}

class _CardContents extends StatefulWidget {
  final bool isDone;

  const _CardContents(this.isDone);

  @override
  _CardContentsState createState() => _CardContentsState();
}

class _CardContentsState extends State<_CardContents>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CardContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isDone && widget.isDone) {
      _controller.forward(from: 0);
    } else if (oldWidget.isDone && !widget.isDone) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: CurvedAnimation(
            curve: Interval(
              0.2,
              0.6,
              curve: Curves.elasticOut,
            ),
            parent: _controller,
          ),
          child: SizedBox(
            height: 70,
            child: Image.asset("assets/gifs/congratulations.gif"),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Congratulations!",
          style: TextStyle(fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 30),
          child: TrackedOutText(
            "DONE! Reviewed all cards due today.",
            CurvedAnimation(
              curve: Interval(0.45, 0.7),
              parent: _controller,
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class TrackedOutText extends StatefulWidget {
  final String text;

  final List<TextSpan> _slices;
  final List<TextSpan> _slicesTransparent;

  final Animation<double> progress;

  final TextAlign textAlign;
  final TextStyle style;

  TrackedOutText(
    this.text,
    this.progress, {
    this.textAlign,
    this.style,
  })  : _slices = _generateSlices(text, style, false).toList(growable: false),
        _slicesTransparent =
            _generateSlices(text, style, true).toList(growable: false);

  static Iterable<TextSpan> _generateSlices(
      String text, TextStyle style, bool transparent) sync* {
    const step = 3;
    var i = 0;
    for (; i < text.length - step; i += step) {
      yield TextSpan(
        text: text.substring(i, i + step),
        style: transparent ? style.apply(color: Colors.transparent) : null,
      );
    }
    yield TextSpan(
      text: text.substring(i),
      style: transparent ? style.apply(color: Colors.transparent) : null,
    );
  }

  @override
  _TrackedOutTextState createState() => _TrackedOutTextState();
}

class _TrackedOutTextState extends State<TrackedOutText> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.progress,
      builder: (BuildContext context, Widget child) {
        return Text.rich(
          TextSpan(
            children: [
              for (var i = 0; i < widget._slices.length; i++)
                (i / widget._slices.length < widget.progress.value)
                    ? widget._slices[i]
                    : widget._slicesTransparent[i],
            ],
          ),
          textAlign: widget.textAlign,
          style: widget.style,
        );
      },
    );
  }
}

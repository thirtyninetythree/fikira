import "package:flutter/material.dart";

import "package:table_calendar/table_calendar.dart";

class SchedulePage extends StatefulWidget {
  static const routeName = "/schedule";
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _calendarController.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("YOUR SCHEDULE"),
        ),
        body: Builder(
          builder: (BuildContext newContext) {
            _events = ModalRoute.of(newContext).settings.arguments;
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _buildTableCalendar(),
                const SizedBox(height: 8.0),
                Expanded(child: _buildEventList()),
              ],
            );
          },
        ),
      ),
    );
  }

  TableCalendar _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        // todayDayBuilder: (context, date, _) {
        //   return Container(
        //     margin: const EdgeInsets.all(4.0),
        //     padding: const EdgeInsets.only(top: 5.0, left: 6.0),
        //     color: Colors.amber[400],
        //     width: 100,
        //     height: 100,
        //     child: Text(
        //       '${date.day}',
        //       style: TextStyle().copyWith(fontSize: 16.0),
        //     ),
        //   );
        // },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: null,
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          "${events.length}",
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return _selectedEvents?.isEmpty ?? true
        ? Center(
            child: Text("Nothing in Your Schedule"),
          )
        : ListView(
            children: _selectedEvents.map((event) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: Text(
                    event.deck.deckName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  title: Text(event.title),
                  onTap: () => print("${event.title} tapped!"),
                ),
              );
            }).toList(),
          );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  final Map<DateTime, List<String>> _events = {};
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  
  List<String> _getEventsForDay(DateTime day) {
    final dateKey = DateTime.utc(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

 
  void _addEvent(String event) {
    if (event.trim().isEmpty) return;

    final dateKey = DateTime.utc(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      if (_events[dateKey] == null) {
        _events[dateKey] = [event];
      } else {
        _events[dateKey]!.add(event);
      }
    });

    _eventController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event added for ${_selectedDay.toLocal()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modern Calendar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF154FA3),
        centerTitle: true,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendar(),
                const Divider(thickness: 1, height: 20),
                _buildEventInputSection(isSmallScreen),
                const Divider(thickness: 1, height: 20),
                _buildSelectedDateInfo(),
                _buildEventList(constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
        weekendTextStyle: const TextStyle(color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      eventLoader: _getEventsForDay,
    );
  }

  
  Widget _buildEventInputSection(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8.0 : 16.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: 'Add Event',
                hintText: 'Enter event name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addEvent(_eventController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF154FA3),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildSelectedDateInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Selected Date: ${_selectedDay.toLocal()}'.split(' ')[0],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF154FA3),
        ),
      ),
    );
  }

  
  Widget _buildEventList(BoxConstraints constraints) {
    final events = _getEventsForDay(_selectedDay);

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No events for ${_selectedDay.toLocal()}'.split(' ')[0],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constraints.maxHeight * 0.5,
      ),
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}


class EventCard extends StatelessWidget {
  final String event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF154FA3),
          child: Icon(Icons.event, color: Colors.white),
        ),
        title: Text(
          event,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

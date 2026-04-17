import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'create_category.dart';
import 'expense_category.dart';
import 'more.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool showOptions = false;

  void _goToScreen(BuildContext context, int index) {
    Widget screen;

    if (index == 0) {
      screen = const HomeScreen();
    } else if (index == 1) {
      screen = const CreateCategoryScreen();
    } else if (index == 2) {
      screen = const ExpenseCategoriesScreen();
    } else if (index == 3) {
      screen = const CalendarScreen();
    } else {
      screen = const MoreScreen(previousIndex: 3);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget buildBottomNav(BuildContext context) {
    Widget navItem({
      required IconData icon,
      required String label,
      required int index,
    }) {
      return Expanded(
        child: InkWell(
          onTap: () => _goToScreen(context, index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF4A4A4A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          navItem(icon: Icons.home_outlined, label: 'Home', index: 0),
          navItem(icon: Icons.add_box_outlined, label: 'Allowance', index: 1),
          navItem(icon: Icons.grid_view_rounded, label: 'Expenses', index: 2),
          navItem(
            icon: Icons.calendar_month_outlined,
            label: 'Calendar',
            index: 3,
          ),
          navItem(icon: Icons.more_horiz, label: 'More', index: 4),
        ],
      ),
    );
  }

  Widget dayText(String text, {bool selected = false, bool faded = false}) {
    if (selected) {
      return Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF4A97D6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Text(
      text,
      style: GoogleFonts.poppins(
        color: faded ? Colors.black38 : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget weekHeader(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget calendarRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: children
            .map((child) => Expanded(child: Center(child: child)))
            .toList(),
      ),
    );
  }

  Widget optionChip({required IconData icon, required String label}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF85B8E1),
        border: Border.all(color: const Color(0xFF2A78B6), width: 1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpandedFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        optionChip(icon: Icons.cake_outlined, label: 'Birthday'),
        optionChip(icon: Icons.assignment_outlined, label: 'School Project'),
        optionChip(icon: Icons.event_note_outlined, label: 'Events'),
        optionChip(icon: Icons.more_horiz, label: 'Others'),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 34,
          ),
        ),
      ],
    );
  }

  Widget buildCollapsedFab() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: buildBottomNav(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Calendar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 92),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF3387C5),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sat - 21',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D8D8),
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 18, 10),
                      child: Row(
                        children: [
                          Text(
                            'January 2026',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.black,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.black26),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              weekHeader('Su'),
                              weekHeader('Mo'),
                              weekHeader('Tu'),
                              weekHeader('We'),
                              weekHeader('Th'),
                              weekHeader('Fr'),
                              weekHeader('Sa'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          calendarRow([
                            dayText('1'),
                            dayText('2'),
                            dayText('3', selected: true),
                            dayText('4'),
                            dayText('5'),
                            dayText('6'),
                            dayText('7'),
                          ]),
                          calendarRow([
                            dayText('8'),
                            dayText('9'),
                            dayText('10'),
                            dayText('11'),
                            dayText('12'),
                            dayText('13'),
                            dayText('14'),
                          ]),
                          calendarRow([
                            dayText('15'),
                            dayText('16'),
                            dayText('17'),
                            dayText('18'),
                            dayText('19'),
                            dayText('20'),
                            dayText('21'),
                          ]),
                          calendarRow([
                            dayText('22'),
                            dayText('23'),
                            dayText('24'),
                            dayText('25'),
                            dayText('26'),
                            dayText('27'),
                            dayText('28'),
                          ]),
                          calendarRow([
                            dayText('29'),
                            dayText('30'),
                            dayText('31'),
                            dayText('1', faded: true),
                            dayText('2', faded: true),
                            dayText('3', faded: true),
                            dayText('4', faded: true),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() {
            showOptions = !showOptions;
          });
        },
        child: showOptions ? buildExpandedFab() : buildCollapsedFab(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'create_category.dart';
import 'expense_category.dart';
import 'home.dart';
import 'more.dart';
import 'notifications.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool showEditor = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List<NoteItem> notes = [];
  int? deleteIndex;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loaded = await AppState.loadNotes();

    if (!mounted) return;

    setState(() {
      notes = loaded;
    });
  }

  Future<void> _saveNote() async {
    final title = titleController.text.trim();
    final body = noteController.text.trim();

    if (title.isEmpty && body.isEmpty) return;

    await AppState.addNote(
      NoteItem(
        title: title.isEmpty ? 'Title' : title,
        body: body,
        dateTime: DateTime.now().toIso8601String(),
      ),
    );

    await _loadNotes();

    if (!mounted) return;

    setState(() {
      titleController.clear();
      noteController.clear();
      showEditor = false;
      deleteIndex = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  Future<void> _deleteNote(int index) async {
    await AppState.deleteNoteAt(index);
    await _loadNotes();

    if (!mounted) return;

    setState(() {
      deleteIndex = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note deleted')));
  }

  String _formatDateTime(String rawDateTime) {
    try {
      final dt = DateTime.parse(rawDateTime).toLocal();

      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final month = monthNames[dt.month - 1];
      final day = dt.day.toString();
      final year = dt.year.toString();

      int hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '$month $day, $year  $hour:$minute $period';
    } catch (_) {
      return 'Date & Time';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

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
      screen = const MoreScreen(previousIndex: 0);
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
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _goToScreen(context, index),
          child: SizedBox(
            height: 86,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 25),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
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

  Widget safeLogo() {
    return Image.asset(
      'assets/images/owl_logo.png',
      height: 74,
      width: 74,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.white,
          size: 52,
        );
      },
    );
  }

  Widget noteTile(NoteItem item, int index) {
    final bool showDelete = deleteIndex == index;

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          deleteIndex = deleteIndex == index ? null : index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8C8C8C),
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(12),
                    right: Radius.circular(showDelete ? 0 : 12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title.isEmpty ? 'Title' : item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          _formatDateTime(item.dateTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showDelete)
              GestureDetector(
                onTap: () => _deleteNote(index),
                child: Container(
                  width: 50,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF1F1F),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildMainNotesView() {
    return Column(
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 32,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Notes',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
                size: 25,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF303030),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes yet.',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return noteTile(notes[index], index);
                          },
                        ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showEditor = true;
                        deleteIndex = null;
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEditorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            safeLogo(),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Study Budget',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Notes',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF303030),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title:',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  cursorColor: Colors.white,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Enter title',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: noteController,
                    cursorColor: Colors.white,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.55,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write your note here...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              setState(() {
                showEditor = false;
                deleteIndex = null;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Text(
                'View Other Notes',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: 210,
            height: 44,
            child: ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9D9),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: buildBottomNav(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: showEditor ? buildEditorView() : buildMainNotesView(),
        ),
      ),
    );
  }
}

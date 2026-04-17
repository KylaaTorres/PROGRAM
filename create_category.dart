import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'expense_category.dart';
import 'home.dart';
import 'more.dart';

enum AllowanceView { menu, daily, weekly, monthly }

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  AllowanceView currentView = AllowanceView.menu;
  String selectedMode = 'daily';

  bool dailyEditable = true;
  bool weeklyEditable = false;
  bool monthlyEditable = false;

  final TextEditingController dailyController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController weeklyController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController monthlyController = TextEditingController(
    text: '0.00',
  );

  List<ExpenseItem> allExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final values = await AppState.loadAllowances();
    final expenses = await AppState.loadExpenses();

    if (!mounted) return;

    final double daily = (values['daily'] as double?) ?? 0;
    final double weekly = (values['weekly'] as double?) ?? 0;
    final double monthly = (values['monthly'] as double?) ?? 0;
    final String savedMode = values['selectedMode'] ?? 'daily';

    setState(() {
      dailyController.text = daily.toStringAsFixed(2);
      weeklyController.text = weekly.toStringAsFixed(2);
      monthlyController.text = monthly.toStringAsFixed(2);
      selectedMode = savedMode;
      allExpenses = expenses;

      dailyEditable = false;
      weeklyEditable = false;
      monthlyEditable = false;
    });
  }

  Future<void> _saveAllowances() async {
    double daily = double.tryParse(dailyController.text) ?? 0;
    double weekly = double.tryParse(weeklyController.text) ?? 0;
    double monthly = double.tryParse(monthlyController.text) ?? 0;

    if (selectedMode == 'daily') {
      weekly = 0;
      monthly = 0;
      weeklyController.text = '0.00';
      monthlyController.text = '0.00';
    } else if (selectedMode == 'weekly') {
      daily = 0;
      monthly = 0;
      dailyController.text = '0.00';
      monthlyController.text = '0.00';
    } else if (selectedMode == 'monthly') {
      daily = 0;
      weekly = 0;
      dailyController.text = '0.00';
      weeklyController.text = '0.00';
    }

    await AppState.saveAllowances(
      weekly: weekly,
      daily: daily,
      monthly: monthly,
      selectedMode: selectedMode,
    );

    if (!mounted) return;

    setState(() {
      dailyEditable = false;
      weeklyEditable = false;
      monthlyEditable = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Allowance saved')));
  }

  void _selectMode(String mode) {
    setState(() {
      selectedMode = mode;
      dailyEditable = false;
      weeklyEditable = false;
      monthlyEditable = false;
    });
  }

  void _editSelectedMode(String mode) {
    setState(() {
      selectedMode = mode;
      dailyEditable = mode == 'daily';
      weeklyEditable = mode == 'weekly';
      monthlyEditable = mode == 'monthly';
    });
  }

  DateTime? _parseExpenseDate(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final target = DateTime(date.year, date.month, date.day);
    return !target.isBefore(startOfWeek) && target.isBefore(endOfWeek);
  }

  bool _isInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  List<ExpenseItem> get _filteredExpenses {
    return allExpenses.where((item) {
      final date = _parseExpenseDate(item.dateTime);
      if (date == null) return false;

      if (selectedMode == 'daily') {
        return _isSameDay(date, DateTime.now());
      } else if (selectedMode == 'weekly') {
        return _isInCurrentWeek(date);
      } else if (selectedMode == 'monthly') {
        return _isInCurrentMonth(date);
      }
      return false;
    }).toList();
  }

  double get totalSpent {
    return _filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get currentAllowanceAmount {
    if (selectedMode == 'weekly') {
      return double.tryParse(weeklyController.text) ?? 0;
    }
    if (selectedMode == 'monthly') {
      return double.tryParse(monthlyController.text) ?? 0;
    }
    return double.tryParse(dailyController.text) ?? 0;
  }

  double get remainingAmount {
    final remaining = currentAllowanceAmount - totalSpent;
    return remaining < 0 ? 0 : remaining;
  }

  List<ExpenseItem> get latestExpenses => _filteredExpenses.take(2).toList();

  double _categorySpent(String category) {
    return _filteredExpenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  void dispose() {
    dailyController.dispose();
    weeklyController.dispose();
    monthlyController.dispose();
    super.dispose();
  }

  void _goToMainNav(BuildContext context, int index) {
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
      screen = const MoreScreen(previousIndex: 1);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _mainBottomNav(BuildContext context) {
    Widget item({
      required IconData icon,
      required String label,
      required int index,
    }) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _goToMainNav(context, index),
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
          item(icon: Icons.home_outlined, label: 'Home', index: 0),
          item(icon: Icons.add_box_outlined, label: 'Allowance', index: 1),
          item(icon: Icons.grid_view_rounded, label: 'Expenses', index: 2),
          item(
            icon: Icons.calendar_month_outlined,
            label: 'Calendar',
            index: 3,
          ),
          item(icon: Icons.more_horiz, label: 'More', index: 4),
        ],
      ),
    );
  }

  Widget _topBackTitle({required String title, required VoidCallback onBack}) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _summaryCard({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
      decoration: BoxDecoration(
        color: const Color(0xFF4F9BDE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '₱',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editAmountField(
    TextEditingController controller, {
    required bool enabled,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9E9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            '₱',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              readOnly: !enabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required TextEditingController controller,
    required bool isActive,
    required bool isEditable,
    required VoidCallback onSelect,
    required VoidCallback onArrowTap,
    required VoidCallback onEditTap,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.fromLTRB(12, 13, 12, 11),
        decoration: BoxDecoration(
          color: const Color(0xFF5E5E5E),
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: Colors.white, width: 1.2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            _editAmountField(controller, enabled: isEditable),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: onEditTap,
                  child: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onArrowTap,
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyListTile({
    required String label,
    required String assetPath,
    required double amount,
    bool isOthers = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF4F9BDE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          isOthers
              ? const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.black,
                  size: 19,
                )
              : Image.asset(
                  assetPath,
                  width: 21,
                  height: 21,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            '₱ ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthlyBar({required String weekLabel, required double widthFactor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              weekLabel,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFEF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF236FC1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '₱00.00',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _screenBody({required List<Widget> children}) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _menuScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBackTitle(
          title: 'Set Allowance',
          onBack: () => Navigator.pop(context),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Set Your Allowances',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _screenBody(
          children: [
            _menuCard(
              title: 'Daily Allowance',
              controller: dailyController,
              isActive: selectedMode == 'daily',
              isEditable: dailyEditable,
              onSelect: () => _selectMode('daily'),
              onArrowTap: () {
                setState(() {
                  selectedMode = 'daily';
                  currentView = AllowanceView.daily;
                });
              },
              onEditTap: () => _editSelectedMode('daily'),
            ),
            _menuCard(
              title: 'Weekly Allowance',
              controller: weeklyController,
              isActive: selectedMode == 'weekly',
              isEditable: weeklyEditable,
              onSelect: () => _selectMode('weekly'),
              onArrowTap: () {
                setState(() {
                  selectedMode = 'weekly';
                  currentView = AllowanceView.weekly;
                });
              },
              onEditTap: () => _editSelectedMode('weekly'),
            ),
            _menuCard(
              title: 'Monthly Allowance',
              controller: monthlyController,
              isActive: selectedMode == 'monthly',
              isEditable: monthlyEditable,
              onSelect: () => _selectMode('monthly'),
              onArrowTap: () {
                setState(() {
                  selectedMode = 'monthly';
                  currentView = AllowanceView.monthly;
                });
              },
              onEditTap: () => _editSelectedMode('monthly'),
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 138,
                height: 42,
                child: ElevatedButton(
                  onPressed: _saveAllowances,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dailyScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBackTitle(
          title: 'Allowances',
          onBack: () {
            setState(() {
              currentView = AllowanceView.menu;
            });
          },
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Daily Allowance',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _screenBody(
          children: [
            _summaryCard(label: 'Total Budget', value: dailyController.text),
            const SizedBox(height: 8),
            if (selectedMode == 'daily')
              _summaryCard(
                label: 'Remaining Daily allowance',
                value: remainingAmount.toStringAsFixed(2),
              ),
            const SizedBox(height: 12),
            _sectionTitle("Today's Spending Breakdown"),
            const SizedBox(height: 7),
            _dailyListTile(
              label: 'Food',
              assetPath: 'assets/images/food.png',
              amount: _categorySpent('Food'),
            ),
            _dailyListTile(
              label: 'Personal Use',
              assetPath: 'assets/images/personal.png',
              amount: _categorySpent('Personal'),
            ),
            _dailyListTile(
              label: 'Transportation',
              assetPath: 'assets/images/transport.png',
              amount: _categorySpent('Transportation'),
            ),
            _dailyListTile(
              label: 'School Supplies',
              assetPath: 'assets/images/school_supplies.png',
              amount: _categorySpent('School Supplies'),
            ),
            _dailyListTile(
              label: 'Others',
              assetPath: '',
              amount: _categorySpent('Other Expenses'),
              isOthers: true,
            ),
            const SizedBox(height: 12),
            _sectionTitle('Daily Insights'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF4F9BDE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/food.png',
                    width: 21,
                    height: 21,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You spend most on Food.',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6FAD),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    'You saved ',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    '₱',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '00.00',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weeklyScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBackTitle(
          title: 'Allowances',
          onBack: () {
            setState(() {
              currentView = AllowanceView.menu;
            });
          },
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Weekly Allowance',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _screenBody(
          children: [
            _summaryCard(label: 'Total Budget', value: weeklyController.text),
            const SizedBox(height: 8),
            if (selectedMode == 'weekly')
              _summaryCard(
                label: 'Remaining Weekly allowance',
                value: remainingAmount.toStringAsFixed(2),
              ),
            const SizedBox(height: 12),
            _sectionTitle('Spending Summary'),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              height: 154,
              child: Stack(
                children: [
                  Positioned(
                    left: 50,
                    right: 2,
                    top: 18,
                    child: Container(height: 1, color: Colors.white54),
                  ),
                  Positioned(
                    left: 50,
                    right: 2,
                    top: 60,
                    child: Container(height: 1, color: Colors.white54),
                  ),
                  Positioned(
                    left: 50,
                    right: 2,
                    top: 102,
                    child: Container(height: 1, color: Colors.white54),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₱00.00',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: 21),
                              Text(
                                '₱00.00',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: 21),
                              Text(
                                '₱00.00',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              _MiniBar(
                                height: 34,
                                label: 'Mon',
                                color: Color(0xFFE47D95),
                              ),
                              _MiniBar(
                                height: 58,
                                label: 'Tue',
                                color: Color(0xFFD94F7D),
                              ),
                              _MiniBar(
                                height: 58,
                                label: 'Wed',
                                color: Color(0xFFD94F7D),
                              ),
                              _MiniBar(
                                height: 36,
                                label: 'Thu',
                                color: Color(0xFFE47D95),
                              ),
                              _MiniBar(
                                height: 80,
                                label: 'Fri',
                                color: Color(0xFFC5104C),
                              ),
                              _MiniBar(
                                height: 64,
                                label: 'Sat',
                                color: Color(0xFFD81956),
                              ),
                              _MiniBar(
                                height: 18,
                                label: 'Sun',
                                color: Color(0xFFE9A2B4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Recent Expenses',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'View All',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ...latestExpenses.map((item) {
              IconData icon = Icons.shopping_cart_outlined;
              if (item.category == 'Food') {
                icon = Icons.restaurant_outlined;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5CA3DD),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Text(
                      '- ₱${item.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _monthlyScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBackTitle(
          title: 'Allowances',
          onBack: () {
            setState(() {
              currentView = AllowanceView.menu;
            });
          },
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            'Monthly Allowance',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _screenBody(
          children: [
            _summaryCard(label: 'Total Budget', value: monthlyController.text),
            const SizedBox(height: 8),
            if (selectedMode == 'monthly')
              _summaryCard(
                label: 'Remaining Monthly allowance',
                value: remainingAmount.toStringAsFixed(2),
              ),
            const SizedBox(height: 12),
            _sectionTitle('Weekly Breakdown'),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E5E5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _monthlyBar(weekLabel: 'Week 1', widthFactor: 0.62),
                  _monthlyBar(weekLabel: 'Week 2', widthFactor: 0.74),
                  _monthlyBar(weekLabel: 'Week 3', widthFactor: 0.42),
                  _monthlyBar(weekLabel: 'Week 4', widthFactor: 0.25),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Spacer(),
                Text(
                  'View All',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _sectionTitle('Monthly Insights'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF4F9BDE),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/food.png',
                    width: 21,
                    height: 21,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You spend most on Food.',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6FAD),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    'You saved ',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    '₱',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '00.00',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ' compared to last Month.',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentBody() {
    if (currentView == AllowanceView.daily) return _dailyScreen();
    if (currentView == AllowanceView.weekly) return _weeklyScreen();
    if (currentView == AllowanceView.monthly) return _monthlyScreen();
    return _menuScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: _mainBottomNav(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: _buildCurrentBody(),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final double height;
  final String label;
  final Color color;

  const _MiniBar({
    required this.height,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 17,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

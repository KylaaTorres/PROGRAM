import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'home.dart';
import 'create_category.dart';
import 'more.dart';
import 'notifications.dart';

enum ExpensePageView { list, detail }

class ExpenseCategoryItem {
  final String title;
  final String? imagePath;
  final List<ExpenseSubItem> subItems;
  final bool isOthers;

  const ExpenseCategoryItem({
    required this.title,
    this.imagePath,
    this.subItems = const [],
    this.isOthers = false,
  });
}

class ExpenseSubItem {
  final String title;
  final IconData icon;

  const ExpenseSubItem({required this.title, required this.icon});
}

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  ExpensePageView currentView = ExpensePageView.list;
  bool showAddExpense = false;
  ExpenseCategoryItem? selectedCategory;
  ExpenseSubItem? selectedSubItem;

  final TextEditingController amountController = TextEditingController(
    text: '00.00',
  );
  final TextEditingController otherTypeController = TextEditingController();

  List<ExpenseItem> allExpenses = [];
  double budgetAmount = 0;
  double totalSpent = 0;

  final List<ExpenseCategoryItem> categories = const [
    ExpenseCategoryItem(
      title: 'Food',
      imagePath: 'assets/images/food.png',
      subItems: [
        ExpenseSubItem(title: 'Drinks', icon: Icons.local_drink_outlined),
        ExpenseSubItem(title: 'Groceries', icon: Icons.shopping_bag_outlined),
        ExpenseSubItem(title: 'Fast Food', icon: Icons.fastfood_outlined),
        ExpenseSubItem(title: 'Dining Out', icon: Icons.restaurant_outlined),
      ],
    ),
    ExpenseCategoryItem(
      title: 'Transportation',
      imagePath: 'assets/images/transport.png',
      subItems: [
        ExpenseSubItem(title: 'Train', icon: Icons.train_outlined),
        ExpenseSubItem(title: 'Taxi', icon: Icons.local_taxi_outlined),
        ExpenseSubItem(title: 'Airplane', icon: Icons.flight_outlined),
        ExpenseSubItem(title: 'Jeep', icon: Icons.airport_shuttle_outlined),
        ExpenseSubItem(title: 'Bus', icon: Icons.directions_bus_outlined),
        ExpenseSubItem(title: 'Grab', icon: Icons.person_pin_circle_outlined),
        ExpenseSubItem(title: 'Tricycle', icon: Icons.pedal_bike_outlined),
      ],
    ),
    ExpenseCategoryItem(
      title: 'School Supplies',
      imagePath: 'assets/images/school_supplies.png',
      subItems: [
        ExpenseSubItem(title: 'Notebook', icon: Icons.menu_book_outlined),
        ExpenseSubItem(title: 'Pens', icon: Icons.edit_outlined),
        ExpenseSubItem(title: 'Paper', icon: Icons.description_outlined),
        ExpenseSubItem(title: 'Projects', icon: Icons.folder_open_outlined),
      ],
    ),
    ExpenseCategoryItem(
      title: 'Personal',
      imagePath: 'assets/images/personal.png',
      subItems: [
        ExpenseSubItem(title: 'Clothing', icon: Icons.checkroom_outlined),
        ExpenseSubItem(
          title: 'Self-Care',
          icon: Icons.face_retouching_natural_outlined,
        ),
        ExpenseSubItem(
          title: 'Personal Care',
          icon: Icons.shopping_bag_outlined,
        ),
        ExpenseSubItem(
          title: 'Health & Wellness',
          icon: Icons.medication_outlined,
        ),
      ],
    ),
    ExpenseCategoryItem(title: 'Other Expenses', isOthers: true),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedExpenses = await AppState.loadExpenses();
    final selectedBudget = await AppState.getSelectedAllowanceAmount();

    if (!mounted) return;

    setState(() {
      allExpenses = loadedExpenses;
      budgetAmount = selectedBudget;
      totalSpent = AppState.getTotalSpent(loadedExpenses);
    });
  }

  List<ExpenseItem> get currentCategoryExpenses {
    if (selectedCategory == null) return [];
    return allExpenses
        .where((e) => e.category == selectedCategory!.title)
        .toList();
  }

  Future<void> _saveExpense() async {
    if (selectedCategory == null) return;

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) return;

    String subType = '';

    if (selectedCategory!.isOthers) {
      subType = otherTypeController.text.trim();
      if (subType.isEmpty) {
        subType = 'Others';
      }
    } else {
      if (selectedSubItem == null) return;
      subType = selectedSubItem!.title;
    }

    final item = ExpenseItem(
      category: selectedCategory!.title,
      subType: subType,
      amount: amount,
      dateTime: DateTime.now().toString(),
    );

    await AppState.addExpense(item);
    await _loadData();

    if (!mounted) return;

    setState(() {
      showAddExpense = false;
      selectedSubItem = null;
      amountController.text = '00.00';
      otherTypeController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense added')));
  }

  @override
  void dispose() {
    amountController.dispose();
    otherTypeController.dispose();
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
      screen = const MoreScreen(previousIndex: 2);
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

  Widget safeCategoryImage(
    String? path, {
    double width = 180,
    double height = 130,
  }) {
    if (path == null || path.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(
          Icons.category_outlined,
          color: Colors.white70,
          size: 70,
        ),
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Icon(
            Icons.image_outlined,
            color: Colors.white70,
            size: 70,
          ),
        );
      },
    );
  }

  Widget buildTopStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        height: 92,
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF737373),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₱',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(color: valueColor, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAmountField({String hint = '00.00'}) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            '₱',
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 34),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubItem(ExpenseSubItem item) {
    final bool isSelected = selectedSubItem?.title == item.title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubItem = item;
        });
      },
      child: SizedBox(
        width: 86,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 3)
                    : null,
              ),
              child: Icon(item.icon, color: Colors.black, size: 36),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryTile(ExpenseCategoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF666666),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = item;
            currentView = ExpensePageView.detail;
            showAddExpense = false;
            selectedSubItem = null;
            amountController.text = '00.00';
            otherTypeController.clear();
          });
        },
        child: Row(
          children: [
            if (item.isOthers)
              const SizedBox(
                width: 54,
                height: 54,
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white54,
                  size: 30,
                ),
              )
            else
              Image.asset(
                item.imagePath ?? '',
                width: 54,
                height: 54,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 54,
                    height: 54,
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                      size: 30,
                    ),
                  );
                },
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title == 'Other Expenses' ? 'Others' : item.title,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black, size: 36),
          ],
        ),
      ),
    );
  }

  Widget buildListView() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 34,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF5D5D5D),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              'Expense Categories',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListView(
              children: categories.map(buildCategoryTile).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOthersAddPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAddExpense = false;
                    });
                  },
                  child: const Icon(Icons.close, color: Colors.black, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECEC),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: otherTypeController,
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 18),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Type of Expense',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildAmountField(),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNormalAddPanel(ExpenseCategoryItem category) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Add new Expense',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAddExpense = false;
                    });
                  },
                  child: const Icon(Icons.close, color: Colors.black, size: 34),
                ),
              ],
            ),
            const SizedBox(height: 22),
            buildAmountField(),
            const SizedBox(height: 26),
            Wrap(
              spacing: 18,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: category.subItems.map(buildSubItem).toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget expenseRow(ExpenseItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF666666),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.subType,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            '- ₱${item.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildDetailView() {
    final category = selectedCategory!;
    final bool isOthers = category.isOthers;
    final String title = category.title;
    final String recentTitle = isOthers
        ? 'Recent Other Expenses'
        : 'Recent $title Expenses';

    final double remainingAmount = budgetAmount - totalSpent;

    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  currentView = ExpensePageView.list;
                  showAddExpense = false;
                  selectedSubItem = null;
                });
              },
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
              ),
            ),
            const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!isOthers) ...[
          Center(
            child: safeCategoryImage(
              category.imagePath,
              width: title == 'Transportation' ? 230 : 170,
              height: title == 'Transportation' ? 150 : 130,
            ),
          ),
          const SizedBox(height: 2),
        ] else
          const SizedBox(height: 76),
        Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isOthers ? 24 : 26,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            buildTopStat(
              label: 'Total Spent',
              value: totalSpent.toStringAsFixed(2),
              valueColor: const Color(0xFFFF2D2D),
            ),
            const SizedBox(width: 2),
            buildTopStat(
              label: 'Budget',
              value: budgetAmount.toStringAsFixed(2),
              valueColor: const Color(0xFFFF2D2D),
            ),
            const SizedBox(width: 2),
            buildTopStat(
              label: 'Left to Spend',
              value: remainingAmount.toStringAsFixed(2),
              valueColor: remainingAmount < 0
                  ? const Color(0xFFFF2D2D)
                  : const Color(0xFF29FF39),
            ),
          ],
        ),
        Expanded(
          child: showAddExpense
              ? (isOthers
                    ? buildOthersAddPanel()
                    : buildNormalAddPanel(category))
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recentTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: currentCategoryExpenses.isEmpty
                            ? Center(
                                child: Text(
                                  'No Expenses yet',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF1E1E),
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : ListView(
                                children: currentCategoryExpenses
                                    .map(expenseRow)
                                    .toList(),
                              ),
                      ),
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showAddExpense = true;
                                selectedSubItem = null;
                                amountController.text = '00.00';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD9D9D9),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Add Expense',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.black,
                              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: buildBottomNav(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 16, 6, 0),
          child: currentView == ExpensePageView.list
              ? buildListView()
              : buildDetailView(),
        ),
      ),
    );
  }
}

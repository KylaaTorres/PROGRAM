import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'home.dart';
import 'create_category.dart';
import 'expense_category.dart';
import 'more.dart';
import 'notifications.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double budgetAmount = 0;
  List<ExpenseItem> expenses = [];
  int? deleteIndex;
  String selectedMode = 'daily';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final loadedExpenses = await AppState.loadExpenses();
    final selectedBudget = await AppState.getSelectedAllowanceAmount();
    final allowanceData = await AppState.loadAllowances();

    if (!mounted) return;

    setState(() {
      budgetAmount = selectedBudget;
      expenses = loadedExpenses;
      selectedMode = allowanceData['selectedMode'] ?? 'daily';
    });
  }

  String get budgetTitle {
    if (selectedMode == 'weekly') {
      return 'Weekly Budget';
    }
    if (selectedMode == 'monthly') {
      return 'Monthly Budget';
    }
    return 'Daily Budget';
  }

  Future<void> _deleteExpense(int index) async {
    await AppState.deleteExpenseAt(index);
    await _loadWalletData();

    if (!mounted) return;

    setState(() {
      deleteIndex = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
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

  Widget expenseTile({required ExpenseItem item, required int index}) {
    final bool showDelete = deleteIndex == index;

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          deleteIndex = deleteIndex == index ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B8B8B),
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(18),
                    right: Radius.circular(showDelete ? 0 : 18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.category} - ${item.subType}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.dateTime.split(' ').first,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-${item.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF2B2B),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showDelete)
              GestureDetector(
                onTap: () => _deleteExpense(index),
                child: Container(
                  width: 60,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF2D2D),
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(18),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalSpent = AppState.getTotalSpent(expenses);
    final double leftToSpend = budgetAmount - totalSpent;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: buildBottomNav(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          child: Column(
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
                  Text(
                    'Wallet',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
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
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Text(
                      budgetTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₱',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 58,
                            ),
                          ),
                          TextSpan(
                            text: ' ${budgetAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF38FF4C),
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Spent',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₱',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 44,
                                      ),
                                    ),
                                    TextSpan(
                                      text: totalSpent.toStringAsFixed(2),
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFFF2B2B),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Left to Spend',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₱',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 44,
                                      ),
                                    ),
                                    TextSpan(
                                      text: leftToSpend.toStringAsFixed(2),
                                      style: GoogleFonts.poppins(
                                        color: leftToSpend < 0
                                            ? const Color(0xFFFF2B2B)
                                            : const Color(0xFF38FF4C),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Column(
                children: [
                  Text(
                    'Expenses',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 175,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses yet.',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          return expenseTile(
                            item: expenses[index],
                            index: index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

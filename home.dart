import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_state.dart';
import 'calendar.dart';
import 'create_category.dart';
import 'expense_category.dart';
import 'more.dart';
import 'notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double budgetAmount = 0;
  double totalSpent = 0;
  List<ExpenseItem> recentExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final expenses = await AppState.loadExpenses();
    final selectedBudget = await AppState.getSelectedAllowanceAmount();

    if (!mounted) return;

    setState(() {
      budgetAmount = selectedBudget;
      totalSpent = AppState.getTotalSpent(expenses);
      recentExpenses = expenses.take(5).toList();
    });
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

  Widget summaryCard({
    required String title,
    required String amount,
    required Color titleColor,
    double height = 100,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '₱',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: amount,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget expenseTile(ExpenseItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF666666),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.category} - ${item.subType}',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '- ₱${item.amount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF2B2B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget safeLogo() {
    return Image.asset(
      'assets/images/owl_logo.png',
      height: 70,
      width: 70,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.white,
          size: 46,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double leftToSpend = budgetAmount - totalSpent;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: buildBottomNav(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    safeLogo(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Study Budget',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
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
                summaryCard(
                  title: 'Total Spent',
                  amount: totalSpent.toStringAsFixed(2),
                  titleColor: const Color(0xFFFF2B2B),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: summaryCard(
                        title: 'Budget',
                        amount: budgetAmount.toStringAsFixed(2),
                        titleColor: const Color(0xFF38FF4C),
                        height: 84,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: summaryCard(
                        title: 'Left to Spend',
                        amount: leftToSpend.toStringAsFixed(2),
                        titleColor: leftToSpend < 0
                            ? const Color(0xFFFF2B2B)
                            : const Color(0xFF38FF4C),
                        height: 84,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (recentExpenses.isEmpty)
                        SizedBox(
                          height: 250,
                          child: Center(
                            child: Text(
                              'No Expenses yet.',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF2B2B),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...recentExpenses.map(expenseTile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

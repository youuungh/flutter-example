import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market/home/product_add_screen.dart';
import 'package:market/home/widgets/home_widget.dart';
import 'package:market/home/widgets/seller_widget.dart';
import 'package:market/login/provider/login_provider.dart';
import 'package:market/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color accentColor = Color(0xFFFF5722);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color buttonColor = Colors.black87;

  Future<bool?> _showLogoutConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.orange[600],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "로그아웃",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "정말 로그아웃 하시겠습니까?",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    splashColor: Colors.orange.withValues(alpha: 0.1),
                    highlightColor: Colors.orange.withValues(alpha: 0.05),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        "로그아웃",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(height: 0.5, color: Colors.grey[300]),
                Material(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    splashColor: Colors.grey.withValues(alpha: 0.1),
                    highlightColor: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "취소",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut();

      ref.read(userCredentialProvider.notifier).state = null;

      userCredential = null;

      if (mounted) {
        context.go("/login");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "로그아웃되었습니다",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "로그아웃 중 오류가 발생했습니다",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "_market",
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: IconThemeData(color: textPrimary),
            actions: [
              if (_selectedIndex == 0)
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search, color: textPrimary),
                ),
              IconButton(
                onPressed: () async {
                  final result = await _showLogoutConfirmDialog();
                  if (result == true) {
                    await _handleLogout(ref);
                  }
                },
                icon: Icon(Icons.logout, color: textPrimary),
                tooltip: "로그아웃",
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [HomeWidget(), SellerWidget()],
          ),
          floatingActionButton: Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(userCredentialProvider);
                return switch (_selectedIndex) {
                  0 => FloatingActionButton(
                    onPressed: () {
                      final uid = user?.user?.uid;
                      if (uid == null) return;
                      context.go("/cart/$uid");
                    },
                    backgroundColor: buttonColor,
                    foregroundColor: cardColor,
                    child: Icon(Icons.shopping_cart_outlined),
                  ),
                  1 => FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ProductAddScreen()),
                      );
                    },
                    backgroundColor: buttonColor,
                    foregroundColor: cardColor,
                    child: Icon(Icons.add),
                  ),
                  _ => Container(),
                };
              }
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: cardColor,
            indicatorColor: buttonColor.withValues(alpha: 0.1),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.store_outlined, color: textSecondary),
                selectedIcon: Icon(Icons.store, color: buttonColor),
                label: "홈",
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined, color: textSecondary),
                selectedIcon: Icon(Icons.storefront, color: buttonColor),
                label: "판매자",
              ),
            ],
          ),
        );
      },
    );
  }
}
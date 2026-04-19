import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBaseLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;       // 앱바 우측 버튼
  final Widget? floatingActionButton;
  final bool showBackButton;         // 뒤로가기 버튼 표시 여부
  final Color? backgroundColor;
  // ✅ 추가 - 하단 버튼 (예약하기, 검색 등 고정 버튼용)
  final Widget? bottomNavigationBar;
  // ✅ 추가 - 탭바 (예약내역 화면 탭용)
  final PreferredSizeWidget? bottom;

  const AppBaseLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottomNavigationBar,  // ✅ 추가
    this.bottom,               // ✅ 추가
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: showBackButton,
        actions: actions,
        // ✅ 추가 - 탭바
        bottom: bottom,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      // ✅ 추가 - 하단 고정 버튼
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
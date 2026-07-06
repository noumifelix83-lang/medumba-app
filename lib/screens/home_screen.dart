import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _tabs = [
    {'icon': Icons.home_rounded,         'label': 'ACCUEIL',      'path': '/home/dashboard'},
    {'icon': Icons.menu_book_rounded,    'label': 'PHRASEBOOK',   'path': '/home/phrasebook'},
    {'icon': Icons.style_rounded,        'label': 'FICHES',       'path': '/home/wordcards'},
    {'icon': Icons.flash_on_rounded,     'label': 'DÉFI',         'path': '/home/challenge'},
    {'icon': Icons.person_rounded,       'label': 'COMPTE',       'path': '/home/profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final active = _tab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tab = i);
                      context.go(tab['path'] as String);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 26,
                          color: active ? kBlue : const Color(0xFFB0B8C1),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? kBlue : const Color(0xFFB0B8C1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

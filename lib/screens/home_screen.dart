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
    {'icon': Icons.home_rounded, 'label': 'Accueil', 'path': '/home/dashboard'},
    {'icon': Icons.menu_book_rounded, 'label': 'Leçons', 'path': '/home/lessons'},
    {'icon': Icons.headphones_rounded, 'label': 'Audio', 'path': '/home/phrasebook'},
    {'icon': Icons.search_rounded, 'label': 'Dico', 'path': '/home/dictionary'},
    {'icon': Icons.person_rounded, 'label': 'Profil', 'path': '/home/profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
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
                        Icon(tab['icon'] as IconData,
                            size: 24,
                            color: active ? kBlue : kMuted),
                        const SizedBox(height: 4),
                        Text(tab['label'] as String,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                color: active ? kBlue : kMuted)),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/state_management/locale_provider.dart';
import 'package:app_vendor/main.dart'; // pour le retour Home()

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const Color _bgScaffold = Color(0xFFF7F7F8);
  static const Color _topbar = Color(0xFF2F2F2F);
  static const Color _primary = Color(0xFFE51742); // Rouge sélectionné
  static const Color _stroke = Color(0xFFE6E6E8); // Bordure grise
  static const Color _hint = Color(0x5A000000);

  late String selectedLanguage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final code = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    if (code == 'ar') {
      selectedLanguage = 'arabic';
    } else if (code == 'fr') {
      selectedLanguage = 'french';
    } else {
      selectedLanguage = 'english';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final all = <_LangItem>[
      _LangItem(
        label: t.english,
        value: 'english',
        flag: '🇬🇧',
        locale: const Locale('en'),
      ),
      _LangItem(
        label: t.arabic,
        value: 'arabic',
        flag: '🇸🇦',
        locale: const Locale('ar'),
      ),

    ];

    final q = _searchController.text.trim().toLowerCase();
    final filtered = all.where((e) {
      if (q.isEmpty) return true;
      return e.label.toLowerCase().contains(q) || e.value.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: const _TopBar(),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text(
                t.language,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Column(
                    children: [
                      _SearchField(
                        controller: _searchController,
                        hintText: t.search,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _noResultsText(context),
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemBuilder: (_, i) {
                              final item = filtered[i];
                              final isSelected = selectedLanguage == item.value;
                              return _LanguageCard(
                                item: item,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() => selectedLanguage = item.value);
                                  Provider.of<LocaleProvider>(context, listen: false).setLocale(item.locale);
                                },
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: filtered.length,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _noResultsText(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ar':
        return 'لا توجد نتائج';
      case 'fr':
        return 'Aucun résultat';
      default:
        return 'No results';
    }
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar();

  static const Color _topbar = Color(0xFF2F2F2F);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _topbar,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 56,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  static const Color _stroke = Color(0xFFE6E6E8);
  static const Color _hint = Color(0x5A000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: Colors.black54, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: _hint, fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54, size: 20),
              onPressed: () {
                controller.clear();
                FocusScope.of(context).unfocus();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _LangItem item;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFFE51742); // Rose sélectionné
  static const Color _stroke = Color(0xFFE6E6E8); // Bordure grise

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(isSelected ? 16 : 20),
          border: Border.all(
            color: isSelected ? _primary : _stroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Text(item.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ),
            _RadioPill(isOn: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RadioPill extends StatelessWidget {
  const _RadioPill({required this.isOn});
  final bool isOn;

  static const Color _primary = Color(0xFFE51742);
  static const Color _off = Color(0xFFE6E6E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isOn ? _primary : _off, width: 3),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: isOn ? 10 : 0,
        height: isOn ? 10 : 0,
        decoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _LangItem {
  final String label;
  final String value;
  final String flag;
  final Locale locale;

  const _LangItem({
    required this.label,
    required this.value,
    required this.flag,
    required this.locale,
  });
}
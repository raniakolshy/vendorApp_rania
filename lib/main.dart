import 'package:app_vendor/presentation/analytics/customer_analytics_screen.dart';
import 'package:app_vendor/presentation/dashboard/dashboard_screen.dart';
import 'package:app_vendor/presentation/orders/orders_list_screen.dart';
import 'package:app_vendor/presentation/payouts/payouts_screen.dart';
import 'package:app_vendor/presentation/products/add_product_screen.dart';
import 'package:app_vendor/presentation/products/drafts_list_screen.dart';
import 'package:app_vendor/presentation/products/products_list_screen.dart';
import 'package:app_vendor/presentation/revenue/revenue_screen.dart';
import 'package:app_vendor/presentation/reviews/reviews_screen.dart';
import 'package:app_vendor/presentation/transactions/transactions_screen.dart';
import 'package:app_vendor/presentation/translation/Language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'presentation/common/app_shell.dart';
import 'presentation/common/nav_key.dart';
import 'state_management/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const KolshyApp(),
    ),
  );
}

class KolshyApp extends StatelessWidget {
  const KolshyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kolshy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      locale: provider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LanguageScreen(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NavKey _selected = NavKey.dashboard;

  /// The top bar in AppShell has: 0=menu, 1=home, 2=chat, 3=bell
  int _bottomIndex = 1;
  int _unreadCount = 4;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      scaffoldKey: _scaffoldKey,
      selected: _selected,
      onSelect: (k) {
        setState(() {
          _selected = k;
          _scaffoldKey.currentState?.closeDrawer();
        });
      },
      bottomIndex: _bottomIndex,
      onBottomTap: (i) {
        setState(() {
          _bottomIndex = i;
          _selected = _navKeyForBottomIndex(i);
          if (i == 3) {
            // user tapped the bell; clear unread badge
            _unreadCount = 0;
          }
        });
      },
      unreadCount: _unreadCount,
      child: _screenFor(_selected),
    );
  }

  /// Map NavKey to the screen widget shown in the body.
  Widget _screenFor(NavKey key) {
    switch (key) {
      case NavKey.dashboard:
        return const DashboardScreen();
      case NavKey.orders:
        return const OrdersListScreen();
      case NavKey.productAdd:
        return const AddProductScreen();
      case NavKey.productList:
        return const ProductsListScreen();
      case NavKey.productDrafts:
        return const DraftsListScreen();
      case NavKey.analytics:
        return const CustomerAnalyticsScreen();
      case NavKey.transactions:
        return const TransactionsScreen();
      case NavKey.payouts:
        return const PayoutsScreen();
      case NavKey.revenue:
        return const RevenueScreen();
      case NavKey.review:
        return const ReviewsScreen();
    }
  }

  /// Decide which NavKey to select when a top bar icon is tapped.
  NavKey _navKeyForBottomIndex(int index) {
    switch (index) {
      case 1:
        return NavKey.dashboard; // home
      case 2:
        return NavKey.orders; // using "chat" icon to jump to Orders
      case 3:
      // bell doesn't navigate to a new page; keep current selection
        return _selected;
      case 0:
      default:
        return _selected;
    }
  }
}

import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const CustomerAnalyticsApp());

class CustomerAnalyticsApp extends StatelessWidget {
  const CustomerAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF111111),
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F3F4),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFF1B1B1B),
          displayColor: const Color(0xFF1B1B1B),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: const CustomerAnalyticsScreen(),
    );
  }
}

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _timeFilter = 'all_time';
  static const int _pageSize = 2;
  int _shown = _pageSize;
  bool _loadingMore = false;

  final List<Customer> _allCustomers = [
    Customer(
      name: 'John Doe',
      email: 'john.doe@example.com',
      contact: '+1 234 567 890',
      gender: Gender.male,
      address: '123 Main St, New York',
      baseTotal: '\$1,234.00',
      orders: '5',
      imageAsset: 'assets/male_avatar.png',
    ),
    Customer(
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      contact: '+1 987 654 321',
      gender: Gender.female,
      address: '456 Oak Ave, Los Angeles',
      baseTotal: '\$2,345.00',
      orders: '8',
      imageAsset: 'assets/female_avatar.png',
    ),
  ];

  List<Customer> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _allCustomers.where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q)).toList();
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _filtered.length);
      _loadingMore = false;
    });
  }

  void _onSearchChanged() {
    setState(() => _shown = _pageSize);
  }

  void _onTimeFilterChanged(String? v) {
    if (v == null) return;
    setState(() {
      _timeFilter = v;
      _shown = _pageSize;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final visible = _filtered.take(_shown).toList();
    final canLoadMore = _shown < _filtered.length && !_loadingMore;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.customerAnalytics,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _timeFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      dropdownColor: Colors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: [
                        DropdownMenuItem(value: 'all_time', child: Text(loc.allTime)),
                        DropdownMenuItem(value: 'last_7_days', child: Text(loc.last7days)),
                        DropdownMenuItem(value: 'last_30_days', child: Text(loc.last30days)),
                        DropdownMenuItem(value: 'last_year', child: Text(loc.lastYear)),
                      ],
                      onChanged: _onTimeFilterChanged,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          loc.customers,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InputSurface(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: loc.searchCustomer,
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(.35),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, size: 22, color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
                      itemBuilder: (context, i) => _CustomerRow(customer: visible[i]),
                    ),
                    const SizedBox(height: 22),
                    if (_filtered.isNotEmpty)
                      Center(
                        child: Opacity(
                          opacity: canLoadMore ? 1 : 0.6,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: canLoadMore ? _loadMore : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_loadingMore)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    const Icon(Icons.refresh, size: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    loc.loadMore,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            loc.noCustomers,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text("${loc.name}: ${customer.name}"),
        Text("${loc.email}: ${customer.email}"),
        Text("${loc.contact}: ${customer.contact}"),
        Text("${loc.address}: ${customer.address}"),
      ],
    );
  }
}

class _InputSurface extends StatelessWidget {
  const _InputSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
    );
  }
}

enum Gender { male, female }

class Customer {
  Customer({
    required this.name,
    required this.email,
    required this.contact,
    required this.gender,
    required this.address,
    required this.baseTotal,
    required this.orders,
    required this.imageAsset,
  });

  final String name;
  final String email;
  final String contact;
  final Gender gender;
  final String address;
  final String baseTotal;
  final String orders;
  final String imageAsset;
}

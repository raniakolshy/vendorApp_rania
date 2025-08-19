import 'package:flutter/material.dart';
import 'nav_key.dart';

class KolshyDrawer extends StatelessWidget {
  final NavKey selected;
  final ValueChanged<NavKey> onSelect;

  const KolshyDrawer({
    Key? key,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Text(
              "Kolshy Menu",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          _buildItem(context, navKey: NavKey.dashboard, label: "Dashboard", icon: Icons.dashboard),
          _buildItem(context, navKey: NavKey.orders, label: "Orders", icon: Icons.shopping_cart),
          _buildItem(context, navKey: NavKey.productAdd, label: "Add Product", icon: Icons.add_box),
          _buildItem(context, navKey: NavKey.productList, label: "Products List", icon: Icons.list),
          _buildItem(context, navKey: NavKey.productDrafts, label: "Drafts", icon: Icons.drafts),
          _buildItem(context, navKey: NavKey.analytics, label: "Analytics", icon: Icons.bar_chart),
          _buildItem(context, navKey: NavKey.transactions, label: "Transactions", icon: Icons.swap_horiz),
          _buildItem(context, navKey: NavKey.revenue, label: "Revenue", icon: Icons.attach_money),
          _buildItem(context, navKey: NavKey.review, label: "Reviews", icon: Icons.rate_review),
          _buildItem(context, navKey: NavKey.payouts, label: "Payouts", icon: Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context,
      {required NavKey navKey,
        required String label,
        required IconData icon}) {
    final bool isSelected = selected == navKey;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => onSelect(navKey),
    );
  }
}

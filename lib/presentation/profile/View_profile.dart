import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Use ONE import; keep it namespaced so there are no clashes.
import 'package:app_vendor/services/api_client.dart' as api;

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  api.VendorProfile? _profile;
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final p = await api.VendorApiClient().getVendorProfileMe(); // returns VendorProfile
      _profile = p;

      // customerId is int? — only load products if it’s non-null
      if (p.customerId != null) {
        final raw = await api.VendorApiClient()
            .getProductsByVendor(vendorId: p.customerId!, pageSize: 50); // <-- non-null now

        // Convert List<dynamic> -> List<Map<String, dynamic>>
        final items = raw
            .whereType<Map>() // drop non-maps safely
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        _products = items;
      } else {
        _products = [];
      }
    } catch (e) {
      // optionally show a snackbar
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------- UI helpers ----------
  ImageProvider? _bannerProvider() {
    if (_profile == null) return null;
    if (_profile!.bannerUrl?.isNotEmpty == true) {
      final rel = _profile!.bannerUrl!;
      final full = rel.startsWith('http')
          ? rel
          : '${api.VendorApiClient().mediaBaseUrlForVendor}/${rel.startsWith('/') ? rel.substring(1) : rel}';
      return NetworkImage(full);
    }
    if (_profile!.bannerBase64?.isNotEmpty == true) {
      try {
        final bytes = base64Decode(_profile!.bannerBase64!.split(',').last);
        return MemoryImage(bytes);
      } catch (_) {}
    }
    return null;
  }

  ImageProvider? _logoProvider() {
    if (_profile == null) return null;
    if (_profile!.logoUrl?.isNotEmpty == true) {
      final rel = _profile!.logoUrl!;
      final full = rel.startsWith('http')
          ? rel
          : '${api.VendorApiClient().mediaBaseUrlForVendor}/${rel.startsWith('/') ? rel.substring(1) : rel}';
      return NetworkImage(full);
    }
    if (_profile!.logoBase64?.isNotEmpty == true) {
      try {
        final bytes = base64Decode(_profile!.logoBase64!.split(',').last);
        return MemoryImage(bytes);
      } catch (_) {}
    }
    return null;
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final banner = _bannerProvider();
    final logo = _logoProvider();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: _loading
            ? const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: CircularProgressIndicator(),
          ),
        )
            : Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(16),
                      image: banner != null
                          ? DecorationImage(image: banner, fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                          image: logo != null
                              ? DecorationImage(image: logo, fit: BoxFit.cover)
                              : null,
                        ),
                        child: logo == null
                            ? const Icon(Icons.business, color: Colors.black38, size: 36)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Vendor info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile?.companyName?.isNotEmpty == true ? _profile!.companyName! : '—',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _profile?.country?.isNotEmpty == true ? _profile!.country! : '—',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Socials
                            Wrap(
                              spacing: 8.0,
                              children: [
                                if ((_profile?.twitter?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.twitter, color: Colors.black87),
                                if ((_profile?.instagram?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.instagram, color: Colors.black87),
                                if ((_profile?.youtube?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.youtube, color: Colors.black87),
                                if ((_profile?.facebook?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.facebook, color: Colors.black87),
                                if ((_profile?.pinterest?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.pinterest, color: Colors.black87),
                                if ((_profile?.tiktok?.isNotEmpty ?? false))
                                  const Icon(FontAwesomeIcons.tiktok, color: Colors.black87),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  _sectionCard(title: 'About Us', children: [
                    Text(_profile?.bio?.isNotEmpty == true ? _profile!.bio! : '—'),
                  ]),

                  // Products
                  _sectionCard(title: 'Our Products', children: [
                    if (_products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No products found.'),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];

                          // Try to extract an image path from media_gallery_entries or image attr
                          String imagePath = '';
                          final mg = product['media_gallery_entries'];
                          if (mg is List && mg.isNotEmpty) {
                            final first = mg.first;
                            if (first is Map && first['file'] != null) {
                              imagePath = first['file'].toString();
                            }
                          } else if (product['image'] != null) {
                            imagePath = product['image'].toString();
                          }

                          final imageUrl = api.VendorApiClient().productImageUrl(imagePath);
                          final price = (product['price'] is num)
                              ? (product['price'] as num).toDouble()
                              : double.tryParse('${product['price']}');
                          final name = (product['name'] ?? '').toString();
                          final type = (product['type_id'] ?? '').toString();

                          return _buildProductCard(
                            name: name,
                            price: price,
                            category: type,
                            imageUrl: imageUrl,
                          );
                        },
                      ),
                  ]),

                  // Back
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required double? price,
    required String category,
    required String imageUrl,
  }) {
    final image = (imageUrl.isNotEmpty)
        ? Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover)
        : Image.asset('assets/img_square.jpg', height: 120, width: double.infinity, fit: BoxFit.cover);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: image,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  price == null ? '—' : 'AED ${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
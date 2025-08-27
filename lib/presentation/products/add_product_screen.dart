import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../common/description_markdown_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();

  // Controllers
  final _title = TextEditingController();
  final _sku = TextEditingController();
  final _desc = TextEditingController();
  final _shortDesc = TextEditingController();
  final _amount = TextEditingController(text: '8');
  final _sp = TextEditingController();
  final _minQty = TextEditingController(text: '0');
  final _maxQty = TextEditingController(text: '0');
  final _stock = TextEditingController();
  final _weight = TextEditingController();
  final _cities = TextEditingController();
  final _url = TextEditingController();
  final _metaTitle = TextEditingController();
  final _metaKeywords = TextEditingController();
  final _metaDesc = TextEditingController();
  final _tagInput = TextEditingController();

  // State
  String? _category;
  String? _tag; // only one tag
  bool _hasSpecial = false;
  bool _taxes = true;
  String? _stockAvail;
  String? _visibility;
  bool _submitting = false;
  Uint8List? _coverBytes;
  String? _coverName;

  // Dropzone (web)
  DropzoneViewController? _dzController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    _category ??= localizations.categoryFood;
    _stockAvail ??= localizations.stockInStock;
    _visibility ??= localizations.visibilityInvisible;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _title.dispose();
    _sku.dispose();
    _desc.dispose();
    _shortDesc.dispose();
    _amount.dispose();
    _sp.dispose();
    _minQty.dispose();
    _maxQty.dispose();
    _stock.dispose();
    _weight.dispose();
    _cities.dispose();
    _url.dispose();
    _metaTitle.dispose();
    _metaKeywords.dispose();
    _metaDesc.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  // ---------- styling helpers ----------
  BorderRadius get _radius => BorderRadius.circular(16);

  // Neutral input with optional $ prefix block
  InputDecoration _dec(BuildContext context, {String? hint, Widget? prefix}) {
    final divider = const Color(0xFFE5E5E5);
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefix == null
          ? null
          : Container(
        width: 48,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius:
          const BorderRadius.horizontal(left: Radius.circular(14)),
          border: const Border(right: BorderSide(color: Color(0xFFE5E5E5))),
        ),
        alignment: Alignment.center,
        child: prefix,
      ),
      border: OutlineInputBorder(borderRadius: _radius, borderSide: BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderRadius: _radius, borderSide: BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.black87, width: 1.5), // black focus
      ),
    );
  }

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

  Widget _label(String text, {String help = ''}) {
    final hasHelp = help.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              softWrap: true,
            ),
          ),
          if (hasHelp) const SizedBox(width: 6),
          if (hasHelp)
            Tooltip(
              message: help,
              triggerMode: TooltipTriggerMode.tap,
              waitDuration: const Duration(milliseconds: 150),
              showDuration: const Duration(seconds: 4),
              preferBelow: false,
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline, size: 16, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // important for web
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _coverBytes = file.bytes;
        _coverName = file.name;
      });
    }
  }

  // ---------- actions ----------
  void _setTag() {
    final t = _tagInput.text.trim();
    if (t.isNotEmpty) {
      setState(() => _tag = t);
    }
  }

  void _removeTag() => setState(() => _tag = null);

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    await _submit(isDraft: true);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final localizations = AppLocalizations.of(context)!;
    if (_hasSpecial && _sp.text.trim().isNotEmpty) {
      final p = double.tryParse(_amount.text);
      final s = double.tryParse(_sp.text);
      if (p != null && s != null && s >= p) {
        _snack(localizations.specialPriceError, error: true);
        return;
      }
    }
    await _submit(isDraft: false);
  }

  Future<void> _submit({required bool isDraft}) async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // TODO: call your API here
    final localizations = AppLocalizations.of(context)!;
    _snack(isDraft ? localizations.draftSaved : localizations.productPublished);
    setState(() => _submitting = false);
  }

  void _delete() {
    // TODO: delete API call
    final localizations = AppLocalizations.of(context)!;
    // ⛳️ FIX: productDeleted est une *fonction* générée par l10n (signature souvent: String productDeleted(Object arg))
    // Si tu n'as pas d'argument à passer, fournis une chaîne vide:
    _snack(localizations.productDeleted(''));
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Force black switches (no purple)
    final switchTheme = SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: MaterialStateProperty.resolveWith((s) => Colors.white),
      trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? Colors.black87 : const Color(0xFFD6D6D6),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );

    // Dynamic lists for dropdowns
    final categories = [
      localizations.categoryFood,
      localizations.categoryElectronics,
      localizations.categoryApparel,
      localizations.categoryBeauty,
      localizations.categoryHome,
      localizations.categoryOther,
    ];
    final stockOptions = [localizations.stockInStock, localizations.stockOutOfStock];
    final visibilityOptions = [localizations.visibilityInvisible, localizations.visibilityVisible];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Theme( // local theme override for switches
          data: Theme.of(context).copyWith(switchTheme: switchTheme),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(localizations.productTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          child: Column(
                            children: [
                              // Name & description
                              _sectionCard(title: localizations.nameAndDescriptionTitle, children: [
                                _label(localizations.productTitleLabel, help: localizations.productTitleHelp),
                                TextFormField(
                                  controller: _title,
                                  decoration: _dec(context, hint: localizations.inputYourText),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? localizations.requiredField : null,
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.categoryLabel, help: localizations.categoryHelp),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _category = v ?? _category),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.tagsLabel, help: localizations.tagsHelp),
                                _buildTagInput(localizations.clickOrDropImage, localizations.inputYourText),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: localizations.descriptionLabel,
                                  help: localizations.descriptionHelp,
                                  controller: _desc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: localizations.shortDescriptionLabel,
                                  help: localizations.shortDescriptionHelp,
                                  controller: _shortDesc,
                                  minLines: 5,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.skuLabel, help: localizations.skuHelp),
                                TextFormField(
                                  controller: _sku,
                                  decoration: _dec(context, hint: 'Ex: SKU-12345'),
                                ),
                              ]),

                              // Price
                              _sectionCard(title: localizations.priceTitle, children: [
                                _label(localizations.amountLabel, help: localizations.amountHelp),
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  decoration: _dec(
                                    context,
                                    hint: '8',
                                    prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty || num.tryParse(v) == null) ? localizations.validNumber : null,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(child: _label(localizations.specialPriceLabel, help: localizations.specialPriceHelp)),
                                    Switch(value: _hasSpecial, onChanged: (v) => setState(() => _hasSpecial = v)),
                                  ],
                                ),
                                const Divider(height: 24, color: Color(0xFFE5E5E5)),

                                if (_hasSpecial) ...[
                                  _label(localizations.specialPriceLabel2, help: localizations.specialPriceHelp2),
                                  TextFormField(
                                    controller: _sp,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    decoration: _dec(
                                      context,
                                      hint: localizations.priceExample,
                                      prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                _label(localizations.minAmountLabel, help: localizations.minAmountHelp),
                                TextFormField(
                                  controller: _minQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: '0'),
                                ),
                                const SizedBox(height: 16),

                                _label(localizations.maxAmountLabel, help: localizations.maxAmountHelp),
                                TextFormField(
                                  controller: _maxQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: '0'),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(child: _label(localizations.taxesLabel, help: localizations.taxesHelp)),
                                    Switch(value: _taxes, onChanged: (v) => setState(() => _taxes = v)),
                                  ],
                                ),
                              ]),

                              // Stock & availability
                              _sectionCard(title: localizations.stockAndAvailabilityTitle, children: [
                                _label(localizations.stockLabel, help: localizations.stockHelp),
                                TextFormField(
                                  controller: _stock,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: localizations.stockExample),
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.weightLabel, help: localizations.weightHelp),
                                TextFormField(
                                  controller: _weight,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))],
                                  decoration: _dec(context, hint: localizations.weightExample),
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.allowedQuantityLabel, help: localizations.allowedQuantityHelp),
                                TextFormField(
                                  controller: _maxQty, // or a different controller if distinct logic
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: localizations.allowedQuantityExample),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return null; // optional
                                    final n = int.tryParse(v);
                                    if (n == null || n < 0) return localizations.nonNegativeNumber;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.stockAvailabilityLabel, help: localizations.stockAvailabilityHelp),
                                DropdownButtonFormField<String>(
                                  value: _stockAvail,
                                  items: stockOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) => setState(() => _stockAvail = v ?? _stockAvail),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.visibilityLabel, help: localizations.visibilityHelp),
                                DropdownButtonFormField<String>(
                                  value: _visibility,
                                  items: visibilityOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) => setState(() => _visibility = v ?? _visibility),
                                  decoration: _dec(context),
                                ),
                              ]),

                              // Meta
                              _sectionCard(title: localizations.metaInfosTitle, children: [
                                _label(localizations.urlKeyLabel, help: localizations.urlKeyHelp),
                                TextFormField(
                                  controller: _url,
                                  decoration: _dec(context, hint: localizations.urlKeyExample),
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.metaTitleLabel, help: localizations.metaTitleHelp),
                                TextFormField(
                                  controller: _metaTitle,
                                  decoration: _dec(context, hint: localizations.metaTitleExample),
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: localizations.metaKeywordsLabel,
                                  help: localizations.metaKeywordsHelp,
                                  controller: _metaKeywords,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: localizations.metaDescriptionLabel,
                                  help: localizations.metaDescriptionHelp,
                                  controller: _metaDesc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label(localizations.coverImagesLabel, help: localizations.coverImagesHelp),
                                Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFE5E5E5)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Preview
                                      if (_coverBytes != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image.memory(_coverBytes!, fit: BoxFit.cover),
                                        ),

                                      // Click target (always)
                                      Center(
                                        child: InkWell(
                                          onTap: _pickCover,
                                          borderRadius: BorderRadius.circular(24),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.95),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(color: const Color(0xFFE5E5E5)),
                                              boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.download_rounded, color: Colors.black87),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _coverName == null ? localizations.clickOrDropImage : _coverName!,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // True drag & drop on web using flutter_dropzone
                                      if (kIsWeb)
                                        IgnorePointer(
                                          ignoring: false,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: DropzoneView(
                                                operation: DragOperation.copy,
                                                mime: const ['image/png', 'image/jpeg', 'image/webp'],
                                                onCreated: (ctrl) => _dzController = ctrl,
                                                onDrop: (ev) async {
                                                  if (_dzController == null) return;
                                                  try {
                                                    final bytes = await _dzController!.getFileData(ev);
                                                    final name  = await _dzController!.getFilename(ev);
                                                    setState(() {
                                                      _coverBytes = bytes;
                                                      _coverName  = name;
                                                    });
                                                  } catch (_) {
                                                    // ignore runtime errors silently for UX
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom actions
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : _saveDraft,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.black87),
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(localizations.saveDraftButton),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _publish,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                            ),
                            child: _submitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Text(localizations.publishNowButton),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.outlined(
                          onPressed: _submitting ? null : _delete,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFE5E5E5)),
                            foregroundColor: Colors.redAccent,
                          ),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: localizations.deleteButton,
                        ),
                      ],
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

  // Tag input (single tag + black chip)
  Widget _buildTagInput(String hint, String remove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          if (_tag != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_tag!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _removeTag,
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: TextField(
                controller: _tagInput,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _setTag(),
              ),
            ),
        ],
      ),
    );
  }
}

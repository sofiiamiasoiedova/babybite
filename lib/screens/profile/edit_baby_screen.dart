import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import 'models/baby_info.dart';

class EditBabyScreen extends StatefulWidget {
  final BabyInfo baby;
  const EditBabyScreen({super.key, required this.baby});

  @override
  State<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends State<EditBabyScreen> {
  static const List<String> _allergySuggestions = [
    'None',
    'Dairy',
    'Eggs',
    'Peanuts',
    'Tree nuts',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
    'Sesame',
  ];

  static const List<String> _weightSuggestions = [
    '5.5',
    '6.0',
    '6.5',
    '7.0',
    '7.5',
    '8.0',
    '8.5',
    '9.0',
    '9.5',
    '10.0',
  ];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _weightCtrl;
  late List<String> _allergyTags;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.baby.name);
    _allergiesCtrl = TextEditingController();
    _weightCtrl = TextEditingController(text: _extractWeightNumber(widget.baby.weight));
    _allergyTags = _parseAllergyTags(widget.baby.allergies);
    _birthDate = widget.baby.birthDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _allergiesCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.blueAccent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.blueDeep,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  /// Định dạng ngày sinh: 11/08/2025
  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _extractWeightNumber(String rawWeight) {
    final cleaned = rawWeight.replaceAll(RegExp(r'[^0-9.]'), '');
    return cleaned;
  }

  List<String> _parseAllergyTags(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return ['None'];

    final tags = normalized
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return tags.isEmpty ? ['None'] : tags;
  }

  List<String> get _filteredAllergySuggestions {
    final query = _allergiesCtrl.text.trim().toLowerCase();
    return _allergySuggestions.where((item) {
      final selected = _allergyTags.any(
        (tag) => tag.toLowerCase() == item.toLowerCase(),
      );
      if (selected) return false;
      if (query.isEmpty) return true;
      return item.toLowerCase().contains(query);
    }).toList();
  }

  void _addAllergyTag(String rawTag) {
    final value = rawTag.trim().replaceAll(',', '');
    if (value.isEmpty) return;

    final exists = _allergyTags.any(
      (tag) => tag.toLowerCase() == value.toLowerCase(),
    );
    if (exists) {
      _allergiesCtrl.clear();
      setState(() {});
      return;
    }

    final isNone = value.toLowerCase() == 'none';
    setState(() {
      if (isNone) {
        _allergyTags = ['None'];
      } else {
        _allergyTags.removeWhere((tag) => tag.toLowerCase() == 'none');
        _allergyTags.add(value);
      }
      _allergiesCtrl.clear();
    });
  }

  void _removeAllergyTag(String tag) {
    setState(() {
      _allergyTags.remove(tag);
      if (_allergyTags.isEmpty) _allergyTags = ['None'];
    });
  }

  String _formatWeightForSave(String rawInput) {
    final normalized = rawInput.replaceAll(',', '.').trim();
    if (normalized.isEmpty) return '';
    return '$normalized kg';
  }

  void _selectWeight(String value) {
    _weightCtrl
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
  }

  Future<void> _showWeightPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Weight',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDeep,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _weightSuggestions.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      color: AppColors.cardBorder,
                    ),
                    itemBuilder: (_, index) {
                      final value = _weightSuggestions[index];
                      final isActive = value == _weightCtrl.text.trim();
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                        title: Text(
                          '$value kg',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.blueAccent
                                : AppColors.blueDeep,
                          ),
                        ),
                        trailing: isActive
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.blueAccent,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(value),
                      ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      _selectWeight(selected);
      setState(() {});
    }
  }

  void _save() {
    final pending = _allergiesCtrl.text.trim();
    if (pending.isNotEmpty) {
      _addAllergyTag(pending);
    }

    Navigator.of(context).pop(
      widget.baby.copyWith(
        name: _nameCtrl.text.trim(),
        birthDate: _birthDate,
        clearBirthDate: _birthDate == null,
        allergies: _allergyTags.join(', '),
        weight: _formatWeightForSave(_weightCtrl.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Basic Info'),
                  const SizedBox(height: 12),
                  _buildCard(children: [
                    _field(
                      controller: _nameCtrl,
                      label: "Baby's name",
                      icon: Icons.child_care_rounded,
                    ),
                    _divider(),
                    _birthDateRow(),
                  ]),
                  const SizedBox(height: 20),
                  _sectionLabel('Health'),
                  const SizedBox(height: 12),
                  _buildCard(children: [
                    _allergiesField(),
                    _divider(),
                    _weightField(),
                  ]),
                  const SizedBox(height: 32),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _birthDateRow() {
    final hasDate = _birthDate != null;
    return InkWell(
      onTap: _pickBirthDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.cake_rounded,
                size: 20, color: AppColors.blueSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of birth',
                    style: GoogleFonts.quicksand(
                        fontSize: 13, color: AppColors.placeholder),
                  ),
                  if (hasDate) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_birthDate!),
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blueDeep,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasDate) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EDFB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  // tính tuổi tạm thời để hiển thị preview
                  BabyInfo(
                    name: '',
                    birthDate: _birthDate,
                    allergies: '',
                    weight: '',
                  ).age,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.calendar_month_outlined,
                size: 20, color: AppColors.placeholder),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.heroTop, AppColors.heroBottom],
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 12, 20, 20),
        child: Row(
          children: [
            _iconBtn(Icons.arrow_back_ios_new_rounded,
                () => Navigator.of(context).pop()),
            Expanded(
              child: Text(
                'Edit Baby Info',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDeep,
                ),
              ),
            ),
            _iconBtn(Icons.check_rounded, _save,
                color: AppColors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: Colors.white.withValues(alpha: .75),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color ?? AppColors.blueDeep, size: 20),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.fredoka(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.blueDeep,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueSoft.withValues(alpha: .15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.blueSoft),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDeep,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.quicksand(
                    fontSize: 13, color: AppColors.placeholder),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allergiesField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 20, color: AppColors.blueSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _allergiesCtrl,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _addAllergyTag,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDeep,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Allergies (type to see suggestions)',
                    labelStyle: GoogleFonts.quicksand(
                        fontSize: 13, color: AppColors.placeholder),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
                if (_allergyTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergyTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6EDFB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blueDeep,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeAllergyTag(tag),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.blueMid,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                if (_filteredAllergySuggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filteredAllergySuggestions.map((suggestion) {
                      return ActionChip(
                        onPressed: () => _addAllergyTag(suggestion),
                        label: Text(
                          suggestion,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueMid,
                          ),
                        ),
                        backgroundColor: const Color(0xFFF4F8FD),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight_outlined,
              size: 20, color: AppColors.blueSoft),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDeep,
              ),
              decoration: InputDecoration(
                labelText: 'Weight',
                hintText: 'Enter number or pick',
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    'kg',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueMid,
                    ),
                  ),
                ),
                labelStyle: GoogleFonts.quicksand(
                    fontSize: 13, color: AppColors.placeholder),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _showWeightPicker,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EDFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.unfold_more_rounded,
                  color: AppColors.blueAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, indent: 48, endIndent: 16, color: AppColors.cardBorder);

  Widget _saveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7EC8F0), Color(0xFF4A9FD8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueAccent.withValues(alpha: .35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Save Changes',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

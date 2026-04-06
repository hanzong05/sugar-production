import 'package:flutter/material.dart';
import 'package:sugar_production/core/theme/app_theme.dart';
import 'package:sugar_production/core/theme/theme_extensions.dart';

class SearchPickerScreen extends StatefulWidget {
  const SearchPickerScreen({
    super.key,
    required this.title,
    required this.items,
    required this.selectedId,
    required this.getId,
    required this.getLabel,
    required this.searchKeys,
    required this.onSelected,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final int? selectedId;
  final int Function(Map<String, dynamic>) getId;
  final String Function(Map<String, dynamic>) getLabel;
  final List<String> searchKeys;
  final void Function(int? id, String label, [String? code]) onSelected;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> items,
    required int? selectedId,
    required int Function(Map<String, dynamic>) getId,
    required String Function(Map<String, dynamic>) getLabel,
    required List<String> searchKeys,
    required void Function(int? id, String label, [String? code]) onSelected,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPickerScreen(
          title: title,
          items: items,
          selectedId: selectedId,
          getId: getId,
          getLabel: getLabel,
          searchKeys: searchKeys,
          onSelected: onSelected,
        ),
      ),
    );
  }

  @override
  State<SearchPickerScreen> createState() => _SearchPickerScreenState();
}

class _SearchPickerScreenState extends State<SearchPickerScreen> {
  late List<Map<String, dynamic>> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.items);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      final lower = q.toLowerCase();
      _filtered = q.isEmpty
          ? List.from(widget.items)
          : widget.items
                .where(
                  (item) => widget.searchKeys.any(
                    (key) => (item[key]?.toString().toLowerCase() ?? '')
                        .contains(lower),
                  ),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: context.gradients.header,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search field ──────────────────────────────────
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: colors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(fontSize: 14, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textHint,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onChanged: _onSearch,
              ),
            ),
          ),

          Divider(height: 1, color: colors.border),

          // ── None option ───────────────────────────────────
          Material(
            color: colors.surface,
            child: InkWell(
              onTap: () {
                widget.onSelected(null, '');
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Icon(
                        Icons.block_rounded,
                        size: 16,
                        color: colors.textHint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'None',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Results ───────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 28,
                            color: colors.textHint,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final id = widget.getId(item);
                      final label = widget.getLabel(item);
                      final isSelected = id == widget.selectedId;

                      return Material(
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.05)
                            : colors.surface,
                        child: InkWell(
                          onTap: () {
                            final code =
                                item['plsrc_code']?.toString() ??
                                item['fr_code']?.toString();
                            widget.onSelected(id, label, code);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: colors.border),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppTheme.primary
                                          : colors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: AppTheme.primary,
                                      size: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

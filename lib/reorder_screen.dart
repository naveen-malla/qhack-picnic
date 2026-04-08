import 'package:flutter/material.dart';

class ReorderItem {
  const ReorderItem({
    required this.name,
    required this.description,
    required this.price,
    required this.assetPath,
  });

  final String name;
  final String description;
  final double price;
  final String assetPath;
}

const _recommended = <ReorderItem>[
  ReorderItem(
    name: 'Leerdammer Original',
    description: '140g · €20.64/kg',
    price: 2.89,
    assetPath: 'assets/foods/leer_dammer.jpg',
  ),
  ReorderItem(
    name: 'Salatgurke',
    description: '1 Stück mind. 300g',
    price: 0.89,
    assetPath: 'assets/foods/salatgurke.jpg',
  ),
  ReorderItem(
    name: 'Geflügel-Mortadella',
    description: 'Wiesenhof · 100g · €16.90/kg',
    price: 1.69,
    assetPath: 'assets/foods/geflügel.jpg',
  ),

  ReorderItem(
    name: 'Bio Tomaten stückig',
    description: 'Edeka Bio · 400g · €1.98/kg',
    price: 0.79,
    assetPath: 'assets/foods/tomaten.jpg',
  ),
];

class ReorderScreen extends StatefulWidget {
  const ReorderScreen({super.key});

  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  final List<bool> _selected = List.filled(
    _recommended.length,
    true,
    growable: false,
  );

  int get _selectedCount => _selected.where((s) => s).length;

  double get _selectedTotal {
    double sum = 0;
    for (int i = 0; i < _recommended.length; i++) {
      if (_selected[i]) sum += _recommended[i].price;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bestellen Sie wieder',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 120),
          itemCount: _recommended.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final item = _recommended[index];
            return _ReorderItemRow(
              item: item,
              selected: _selected[index],
              onChanged: (val) =>
                  setState(() => _selected[index] = val ?? false),
            );
          },
        ),
      ),
      bottomNavigationBar: _AddToCartButton(
        count: _selectedCount,
        total: _selectedTotal,
        onPressed: _selectedCount == 0
            ? null
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$_selectedCount Artikel zum Warenkorb hinzugefügt',
                    ),
                    backgroundColor: const Color(0xFF3E7D2A),
                  ),
                );
                Navigator.of(context).pop();
              },
      ),
    );
  }
}

// ── Item Row ─────────────────────────────────────────────────────────────────

class _ReorderItemRow extends StatelessWidget {
  const _ReorderItemRow({
    required this.item,
    required this.selected,
    required this.onChanged,
  });

  final ReorderItem item;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  item.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF2F2F2),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 24,
                      color: Color(0xFFBBBBBB),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Middle: title + description + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF888888),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _SuperscriptPrice(price: item.price),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right: checkbox
            Checkbox(
              value: selected,
              onChanged: onChanged,
              activeColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Superscript price ─────────────────────────────────────────────────────────

class _SuperscriptPrice extends StatelessWidget {
  const _SuperscriptPrice({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    final parts = price.toStringAsFixed(2).split('.');
    final euros = parts[0];
    final cents = parts[1];

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.w800,
        ),
        children: [
          TextSpan(text: euros, style: const TextStyle(fontSize: 18)),
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                cents,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom add-to-cart button ─────────────────────────────────────────────────

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.count,
    required this.total,
    required this.onPressed,
  });

  final int count;
  final double total;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final parts = total.toStringAsFixed(2).split('.');
    final euros = parts[0];
    final cents = parts[1];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Material(
          color: onPressed == null
              ? const Color(0xFFCCCCCC)
              : const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      count == 0
                          ? 'Artikel auswählen'
                          : '$count Artikel zum Warenkorb hinzufügen',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (count > 0)
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          const TextSpan(
                            text: '€ ',
                            style: TextStyle(fontSize: 14),
                          ),
                          TextSpan(
                            text: euros,
                            style: const TextStyle(fontSize: 20),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.top,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                cents,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
}

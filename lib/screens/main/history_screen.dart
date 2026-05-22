import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'inspection_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<InspectionModel> _items = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('history')
          .orderBy('inspectedAt', descending: true)
          .get();

      final data = snapshot.docs.map<InspectionModel>((doc) {
        final json = doc.data();
        return InspectionModel.fromJson(json, doc.id);
      }).toList();

      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal load history: $e')),
        );
      }
    }
  }

  List<InspectionModel> get _filtered {
    if (_filter == 'fresh') return _items.where((e) => e.isFresh).toList();
    if (_filter == 'non-fresh') return _items.where((e) => !e.isFresh).toList();
    return _items;
  }

  Future<void> _delete(InspectionModel item) async {
    if (item.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus data ${item.fishName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('history')
          .doc(item.id!)
          .delete();
      await _load();
    }
  }

  String _formatDate(dynamic value) {
    try {
      DateTime dt;
      if (value is Timestamp) {
        dt = value.toDate().toLocal();
      } else {
        dt = DateTime.parse(value.toString()).toLocal();
      }

      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];

      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return '$day $month $year, $hour:$minute';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FRESHNET',
          style: TextStyle(
            color: Color(0xFF0D1B3E),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D1B3E)),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  if (_filtered.isEmpty)
                    _buildEmpty()
                  else
                    ..._filtered.map((item) => _buildCard(item)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat\nPemeriksaan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B3E),
            height: 1.2,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D1B3E)),
            onPressed: _load,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final fresh = _items.where((e) => e.isFresh).length;
    final nonFresh = _items.length - fresh;
    final freshPct = _items.isEmpty
        ? 0
        : ((fresh / _items.length) * 100).round();
    final nonFreshPct = _items.isEmpty ? 0 : 100 - freshPct;

    return Column(
      children: [
        _StatCard(
          label: 'TOTAL',
          value: _items.length.toString(),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.archive_outlined, color: Color(0xFF8A9BB5)),
          ),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'SEGAR',
          value: fresh.toString(),
          valueColor: const Color(0xFF0A7A5A),
          background: const Color(0xFFF0FBF7),
          trailing: _PctBadge(
            percent: '$freshPct%',
            bgColor: const Color(0xFFD6F5E9),
            textColor: const Color(0xFF0A7A5A),
          ),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'TIDAK SEGAR',
          value: nonFresh.toString(),
          valueColor: const Color(0xFFCC2929),
          background: const Color(0xFFFDF2F2),
          trailing: _PctBadge(
            percent: '$nonFreshPct%',
            bgColor: const Color(0xFFFAD4D4),
            textColor: const Color(0xFFCC2929),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        _FilterPill(
          label: 'Semua',
          active: _filter == 'all',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'all'),
        ),
        const SizedBox(width: 10),
        _FilterPill(
          label: 'Segar',
          active: _filter == 'fresh',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'fresh'),
        ),
        const SizedBox(width: 10),
        _FilterPill(
          label: 'Tidak Segar',
          active: _filter == 'non-fresh',
          activeColor: const Color(0xFF0D1B3E),
          onTap: () => setState(() => _filter = 'non-fresh'),
        ),
      ],
    );
  }

  Widget _buildCard(InspectionModel item) {
    final isFresh = item.isFresh;
    final badgeColor =
        isFresh ? const Color(0xFF0A7A5A) : const Color(0xFFCC2929);
    final badgeBg =
        isFresh ? const Color(0xFFD6F5E9) : const Color(0xFFFAD4D4);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 60,
            child: _buildThumbnail(item),
          ),
        ),
        title: Text(
          item.fishName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1B3E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              _formatDate(item.inspectedAt),
              style: const TextStyle(color: Color(0xFF8A9BB5), fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.freshnessLabel.toUpperCase(),
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFCC2929)),
          onPressed: () => _delete(item),
        ),
      ),
    );
  }

  Widget _buildThumbnail(InspectionModel item) {
    final path = item.eyeImagePath ?? item.gillImagePath;

    if (path == null) {
      return Container(
        color: const Color(0xFFEEF2F8),
        child: const Icon(Icons.set_meal, color: Color(0xFF8A9BB5)),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFEEF2F8),
          child: const Icon(Icons.broken_image, color: Color(0xFF8A9BB5)),
        ),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        color: const Color(0xFFEEF2F8),
        child: const Icon(
          Icons.image_not_supported,
          color: Color(0xFF8A9BB5),
        ),
      );
    }

    return Image.file(file, fit: BoxFit.cover);
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history,
                size: 40,
                color: Color(0xFF8A9BB5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat pemeriksaan',
              style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color background;
  final Widget trailing;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trailing,
    this.valueColor = const Color(0xFF0D1B3E),
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A9BB5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _PctBadge extends StatelessWidget {
  final String percent;
  final Color bgColor;
  final Color textColor;

  const _PctBadge({
    required this.percent,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        percent,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF8A9BB5),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
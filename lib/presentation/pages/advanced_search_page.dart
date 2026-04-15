import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class AdvancedSearchPage extends ConsumerStatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  ConsumerState<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends ConsumerState<AdvancedSearchPage> {
  final _titleCtrl = TextEditingController();
  String? _status;
  String? _contentRating;
  int? _year;

  final _statuses = [
    {'value': 'ongoing', 'label': 'En cours'},
    {'value': 'completed', 'label': 'Terminé'},
    {'value': 'hiatus', 'label': 'En pause'},
    {'value': 'cancelled', 'label': 'Annulé'},
  ];

  final _ratings = [
    {'value': 'safe', 'label': 'Tout public'},
    {'value': 'suggestive', 'label': 'Suggestif'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre du manga',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _sectionLabel('Statut'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _statuses.map((s) => ChoiceChip(
                label: Text(s['label']!),
                selected: _status == s['value'],
                selectedColor: AppColors.primary.withOpacity(0.3),
                onSelected: (v) => setState(() => _status = v ? s['value'] : null),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            _sectionLabel('Classification'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _ratings.map((r) => ChoiceChip(
                label: Text(r['label']!),
                selected: _contentRating == r['value'],
                selectedColor: AppColors.primary.withOpacity(0.3),
                onSelected: (v) => setState(() => _contentRating = v ? r['value'] : null),
              )).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            _sectionLabel('Année de publication'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(10, (i) {
                final year = 2024 - i;
                return ChoiceChip(
                  label: Text('$year'),
                  selected: _year == year,
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  onSelected: (v) => setState(() => _year = v ? year : null),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('RECHERCHER'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.clear),
                label: const Text('RÉINITIALISER'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15));
  }

  void _search() {
    ref.read(searchParamsProvider.notifier).state = SearchParams(
      query: _titleCtrl.text,
      status: _status,
      contentRating: _contentRating,
      year: _year,
    );
    context.go('/search');
  }

  void _reset() {
    setState(() {
      _titleCtrl.clear();
      _status = null;
      _contentRating = null;
      _year = null;
    });
  }
}
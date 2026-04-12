import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdvancedSearchPage extends ConsumerStatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  ConsumerState<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends ConsumerState<AdvancedSearchPage> {
  final _titleController = TextEditingController();
  String? selectedStatus;
  String? selectedContentRating;
  int? selectedYear;

  final List<Map<String, String>> statuses = [
    {'value': 'ongoing', 'label': 'En cours'},
    {'value': 'completed', 'label': 'Terminé'},
    {'value': 'hiatus', 'label': 'En pause'},
    {'value': 'cancelled', 'label': 'Annulé'},
  ];

  final List<Map<String, String>> contentRatings = [
    {'value': 'safe', 'label': 'Tout public'},
    {'value': 'suggestive', 'label': 'Suggestif'},
    {'value': 'erotica', 'label': 'Erotique'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du manga',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Statut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statuses.map((status) {
                final isSelected = selectedStatus == status['value'];
                return ChoiceChip(
                  label: Text(status['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C63FF),
                  onSelected: (selected) {
                    setState(() {
                      selectedStatus = selected ? status['value'] : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text('Classification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contentRatings.map((rating) {
                final isSelected = selectedContentRating == rating['value'];
                return ChoiceChip(
                  label: Text(rating['label']!),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C63FF),
                  onSelected: (selected) {
                    setState(() {
                      selectedContentRating = selected ? rating['value'] : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text('Année de publication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(15, (index) {
                final year = 2024 - index;
                final isSelected = selectedYear == year;
                return ChoiceChip(
                  label: Text('$year'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C63FF),
                  onSelected: (selected) {
                    setState(() {
                      selectedYear = selected ? year : null;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('RECHERCHER', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6C63FF),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.clear),
                label: const Text('RÉINITIALISER'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _search() {
    final params = <String, String>{};
    if (_titleController.text.isNotEmpty) params['title'] = _titleController.text;
    if (selectedStatus != null) params['status'] = selectedStatus!;
    if (selectedContentRating != null) params['rating'] = selectedContentRating!;
    if (selectedYear != null) params['year'] = selectedYear!.toString();

    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    context.go('/search?$queryString');
  }

  void _reset() {
    setState(() {
      _titleController.clear();
      selectedStatus = null;
      selectedContentRating = null;
      selectedYear = null;
    });
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/preferences.dart';

class ReaderState {
  final bool isVertical;
  final double zoom;
  final String theme; // dark, light, sepia
  final bool showControls;

  const ReaderState({
    this.isVertical = false,
    this.zoom = 1.0,
    this.theme = 'dark',
    this.showControls = true,
  });

  ReaderState copyWith({
    bool? isVertical,
    double? zoom,
    String? theme,
    bool? showControls,
  }) {
    return ReaderState(
      isVertical: isVertical ?? this.isVertical,
      zoom: zoom ?? this.zoom,
      theme: theme ?? this.theme,
      showControls: showControls ?? this.showControls,
    );
  }
}

final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  return ReaderNotifier(ref.watch(preferencesProvider));
});

class ReaderNotifier extends StateNotifier<ReaderState> {
  final Preferences _prefs;

  ReaderNotifier(this._prefs) : super(const ReaderState()) {
    _load();
  }

  Future<void> _load() async {
    final isVertical = await _prefs.getUseVerticalReader();
    final zoom = await _prefs.getReaderZoom();
    final theme = await _prefs.getReaderTheme();
    state = ReaderState(isVertical: isVertical, zoom: zoom, theme: theme);
  }

  Future<void> toggleOrientation() async {
    final newValue = !state.isVertical;
    await _prefs.setUseVerticalReader(newValue);
    state = state.copyWith(isVertical: newValue);
  }

  Future<void> setTheme(String theme) async {
    await _prefs.setReaderTheme(theme);
    state = state.copyWith(theme: theme);
  }

  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
  }

  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/preferences.dart';

final readerPreferencesProvider = StateNotifierProvider<ReaderPreferencesNotifier, ReaderPreferences>((ref) {
  return ReaderPreferencesNotifier(ref.watch(preferencesProvider));
});

class ReaderPreferences {
  final bool verticalReader;
  final double zoom;
  final bool tapToScroll;
  final bool showPageNumber;
  final String backgroundColor;

  ReaderPreferences({
    this.verticalReader = false,
    this.zoom = 1.0,
    this.tapToScroll = true,
    this.showPageNumber = true,
    this.backgroundColor = 'black',
  });

  ReaderPreferences copyWith({
    bool? verticalReader,
    double? zoom,
    bool? tapToScroll,
    bool? showPageNumber,
    String? backgroundColor,
  }) {
    return ReaderPreferences(
      verticalReader: verticalReader ?? this.verticalReader,
      zoom: zoom ?? this.zoom,
      tapToScroll: tapToScroll ?? this.tapToScroll,
      showPageNumber: showPageNumber ?? this.showPageNumber,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

class ReaderPreferencesNotifier extends StateNotifier<ReaderPreferences> {
  final Preferences _prefs;

  ReaderPreferencesNotifier(this._prefs) : super(ReaderPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _prefs.init();
    final isVertical = await _prefs.getUseVerticalReader();
    final zoom = await _prefs.getReaderZoom();
    state = ReaderPreferences(
      verticalReader: isVertical,
      zoom: zoom,
    );
  }

  Future<void> setVerticalReader(bool value) async {
    await _prefs.setUseVerticalReader(value);
    state = state.copyWith(verticalReader: value);
  }

  Future<void> setZoom(double value) async {
    await _prefs.setReaderZoom(value);
    state = state.copyWith(zoom: value);
  }
}
import 'word_frequency.dart';

/// An immutable snapshot of the analysis data displayed by the app
class AnalysisState {
  AnalysisState({
    this.sourceText = '',
    Map<String, int> wordCounts = const {},
    List<WordFrequency> displayedWords = const [],
    Set<String> selectedWords = const {},
  }) : wordCounts = Map.unmodifiable(wordCounts),
       displayedWords = List.unmodifiable(displayedWords),
       selectedWords = Set.unmodifiable(selectedWords);

  final String sourceText;
  final Map<String, int> wordCounts;
  final List<WordFrequency> displayedWords;
  final Set<String> selectedWords;

  AnalysisState copyWith({
    Map<String, int>? wordCounts,
    List<WordFrequency>? displayedWords,
    Set<String>? selectedWords,
  }) {
    return AnalysisState(sourceText: sourceText,
    wordCounts: wordCounts ?? this.wordCounts,
    displayedWords: displayedWords ?? this.displayedWords,
    selectedWords: selectedWords ?? this.selectedWords,
    );
  }
}
import 'package:flutter/foundation.dart';
import '../models/analysis_state.dart';
import '../services/text_analayzer.dart';

/// Responsible for publishing analysis data without constructing or owning UI objects
class AnalysisController extends ChangeNotifier {
  AnalysisController({TextAnalayzer analyzer = const TextAnalayzer()}) : _analayzer = analyzer;

  final TextAnalayzer _analayzer;
  AnalysisState _state = AnalysisState();

  AnalysisState get state => _state;

  void analyze(String text){
    _state = _analayzer.analyze(text);
    notifyListeners();
  }

  void setWordSelected(String word, bool selected){
    if (!_state.displayedWords.any((entry) => entry.word == word) || _state.selectedWords.contains(word) == selected) {
      return;
    }
    final selectedWords = {..._state.selectedWords};
    if (selected){
      selectedWords.add(word);
    } else {
      selectedWords.remove(word);
    }

    _state = _state.copyWith(selectedWords: selectedWords);
    notifyListeners();
  }

  void clearWordCounts(){
    if (_state.wordCounts.isEmpty){
      return;
    }
    _state = _state.copyWith(wordCounts: {});
    notifyListeners();
  }

  //TODO: This does not work anymore....
  void removeSelected(){
    if (_state.displayedWords.isEmpty){
      return;
    }
    _state = _state.copyWith(displayedWords: []);
    notifyListeners();
  }

  double averageSentenceLength(){
    return _analayzer.averageSentenceLength(_state.sourceText);
  }
}
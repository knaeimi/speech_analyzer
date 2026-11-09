import 'dart:collection';
import '../models/analysis_state.dart';
import '../models/word_frequency.dart';

/// Text analysis class indepenedent from flutter ui or application state
class TextAnalayzer {
  const TextAnalayzer();

  AnalysisState analyze(String text){
    final words = text
      .replaceAll(RegExp(r"[,.;@#?!&$'-/()]"), '')
      .replaceAll("\n", " ")
      .replaceAll("\t"," ")
      .replaceAll("  ", " ")
      .split(' ');
    
    final counts = HashMap<String, int>();
    for (final word in words){
      if (word.isNotEmpty) {
        counts.update(word, (count) => count+1, ifAbsent: () => 1);
      }
    }

    final entries = counts.entries.toList()
      ..sort((e2,e1)=>e1.value.compareTo(e2.value));
    final possiblySortedCounts = HashMap<String, int>.fromEntries(entries); //TODO: This doesn't always work
    return AnalysisState(
      sourceText: text,
      wordCounts: possiblySortedCounts,
      displayedWords: possiblySortedCounts.entries
        .take(10)
        .map((entry) => WordFrequency(word: entry.key, count: entry.value))
        .toList(),
    );
  }

  double averageSentenceLength(String text){
    final sentences = text
      .replaceAll(RegExp(r"[?!]"), '.')
      .replaceAll("\n", "")
      .replaceAll("\t","")
      .replaceAll("  ", " ")
      .split('.');
    final lengths = <int>[];
    
    for (final sentence in sentences.take(sentences.length - 1)){
      final words = sentence.trim().split(' ');
      if(words.isNotEmpty){
        lengths.add(words.length);
      }
    }
    if (lengths.isEmpty){
      return 0;
    }
    return lengths.reduce((a,b) => a + b) / lengths.length;  
  }
}
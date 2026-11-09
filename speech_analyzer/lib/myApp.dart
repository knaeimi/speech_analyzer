import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'textInputPage.dart';
import 'analysisPage.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Speech Analyzer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 195, 157, 246)
          , surface: Color.fromARGB(230, 0, 11, 69)),
        ),
        home: TextInputPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final myController = TextEditingController(); 
  final GlobalKey<AnalysisState> analysis = GlobalKey<AnalysisState>();
  HashMap<String,int> textMap = HashMap<String,int>();
  HashMap<String,bool?> selectedText = HashMap<String,bool?>();
  List<MapEntry<String,int>> textList = [];
  List<DataRow> dataList = [];
  List<String> wordList = [];
  List<String> sentenceList = [];
  List<String> selected = [];
  String initialWords = '';

  void baseAnalysis(String words){
    wordList.clear();
    textMap.clear();
    selectedText.clear();
    dataList.clear(); //reset each rows state
    initialWords = words;
    wordList = words.replaceAll(RegExp(r"[,.;@#?!&$'-/()]"), '').replaceAll("\n", " ").replaceAll("/t"," ").replaceAll("  ", " ").split(' ');
    
    for (String word in wordList){ // Empty input was counted as word, this check fixes that and also don't need trim anymore
      if (word.isNotEmpty) textMap.update(word, (value) => ++value, ifAbsent: () => 1);
    }

    textMap = HashMap.fromEntries(textMap.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value)));
    textList = textMap.entries.toList().sublist(0,[10,textMap.entries.toList().length].min);
    populateMaps(textList);
  }

  void populateMaps(List<MapEntry<String,int>> textList){
    for (MapEntry<String,int> set in textList){
      selectedText.putIfAbsent(set.key, () => false); // only set to false if not in map, otherwise it just keeps resetting to false
      dataList.add(DataRow(
        cells: [
          DataCell(
           createCheckbox(selectedText, set)
          ),
          DataCell(
            Text(set.key)
          ),
          DataCell(
            Text(set.value.toString())
          )
        ]
      ));
    }
  }

  Checkbox createCheckbox( HashMap<String,bool?>  selectedText, MapEntry<String,int> set){
    return Checkbox(
      value: selectedText[set.key],
      onChanged: (bool? value) { 
        selectedText[set.key] = value; //flutter handles updating based on prev value

        dataList.clear(); // clear old state before repopulating
        populateMaps(textList);    
        notifyListeners(); //have to use this instead of setState bc we extend ChangeNotifier
      },
    );
  }

  void removePrepositions(){
   List<String> prepositions = ['the','a','an','is','am','are','be','do','to','it','and','of','that','at','was','had'];

    textMap.clear();
    for (String word in wordList){
      if (!prepositions.contains(word)&word.isNotEmpty){
        textMap.update(word, (value) => ++value, ifAbsent: () => 1);
      }
    }
    textMap = HashMap.fromEntries(textMap.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value)));
    textList = textMap.entries.toList().sublist(0,[10,textMap.entries.toList().length].min);
    populateMaps(textList); // if we still want to use removePrepositions later, we need to use populateMaps for the checkbox column
  }

  void removeSelected(){ //very similar to removePrepositions
    textMap.clear();
    
    for (String word in wordList){
      bool selected = selectedText.containsKey(word) && selectedText[word] == false;

      if (selected){ // if word is in wordList but hasn't been selected, keep it in the textMap
        textMap.update(word, (value) => ++value, ifAbsent: () => 1); //now only unselected words are in textMap
      }
      
    }
    textMap = HashMap.fromEntries(textMap.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value)));
    textList = textMap.entries.toList().sublist(0,[10,textMap.entries.toList().length].min);
    populateMaps(textList);
  }

  double avgSentenceLength(){
    List<String> word = [];
    List<int> lengths = [];
    sentenceList = initialWords.replaceAll(RegExp(r"[?!]"), '.').replaceAll("\n", "").replaceAll("/t","").replaceAll("  ", " ").split('.');
    sentenceList = sentenceList.sublist(0,sentenceList.length-1);
    for (String sentence in sentenceList){
      word = sentence.trim().split(' ');
      if(word.isNotEmpty){
        lengths.add(word.length);
      }
    }
    if (lengths.isEmpty){
      return 0;
    }
    double average = lengths.reduce((a,b) => a + b) / lengths.length;  
    return average;  
  }
}
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(MyApp());
}

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
        home: InputPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final myController = TextEditingController();  
  HashMap<String,int> textMap = HashMap<String,int>();
  List<MapEntry<String,int>> textList = [];
  List<DataRow> dataList = [];
  List<String> wordList = [];
  List<String> sentenceList = [];
  String initialWords = '';

  void baseAnalysis(String words){
    wordList.clear();
    textMap.clear();
    initialWords = words;
    wordList = words.replaceAll(RegExp(r"[,.;@#?!&$'-/()]"), '').replaceAll("\n", " ").replaceAll("/t"," ").replaceAll("  ", " ").split(' ');
    for (String word in wordList){
      textMap.update(word, (value) => ++value, ifAbsent: () => 1);
    }
    textMap = HashMap.fromEntries(textMap.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value)));
    textList = textMap.entries.toList().sublist(0,[10,textMap.entries.toList().length].min);
    for (MapEntry<String,int> set in textList){
      dataList.add(DataRow(
        cells: [
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

  void removePrepositions(){
    List<String> prepositions = ['the','a','an','is','am','are','be','do','to','it','and','of','that','at','was','had'];

    textMap.clear();
    for (String word in wordList){
      if (!prepositions.contains(word)){
        textMap.update(word, (value) => ++value, ifAbsent: () => 1);
      }
    }
    textMap = HashMap.fromEntries(textMap.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value)));
    textList = textMap.entries.toList().sublist(0,[10,textMap.entries.toList().length].min);
    for (MapEntry<String,int> set in textList){
      dataList.add(DataRow(
        cells: [
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
    double average = lengths.reduce((a,b) => a + b) / lengths.length;  
    return average;  
  }
}

/**
 * Input page class
 */
class InputPage extends StatelessWidget {
  const InputPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var myController = appState.myController;
    HashMap<String,int> textMap = appState.textMap;
    List<DataRow> dataList = appState.dataList;
    String words = '';

    return Center(
      child: Scaffold(
        body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Speech Analyzer",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white
            )
          ),
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  textMap.clear();
                },
                label: Text('Text'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                },
                child: Text('Speech'),
              ),
            ],
          ),
          SizedBox(height: 30),
          SizedBox(
            height:200,
            width:500,
            child: TextField(
              style: TextStyle(color: Colors.white),
              maxLines: 10,
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your speech here...',
                hintStyle: TextStyle(color: Colors.white)
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  myController.clear();
                }, 
                child: Text("Clear")
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  textMap.clear();
                  dataList.clear(); // trim() for leading & trailing spaces that were being counted
                  words = myController.text.trim().toLowerCase();
                  appState.baseAnalysis(words);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalysisPage())
                    );
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
      )
    );
  }
}

/**
 * Analysis page class
 */
class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<DataRow> dataList = appState.dataList;

    return Scaffold(
      body: Center( 
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            "Analysis",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white
            )
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  dataList.clear();
                  appState.removePrepositions();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                    builder: (BuildContext context) => AnalysisPage()));
                },
                child: Text("Remove Prepositions"),
              ),SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  double average = appState.avgSentenceLength();
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                    return AlertDialog(
                      content: Text("Your average sentence length is ${average.toStringAsFixed(2)} words per sentence."),
                      );
                    },
                  );
                },
                child: Text("Average Sentence Length"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => InputPage()) // Switches but analysis page is
                    );
                },
                child: Text("Back"),
              ),
            ],
          ),
          SizedBox(height:20),
          // Source - https://stackoverflow.com/a/67434006
          // Posted by LihnNguyen
          // Retrieved 2026-10-09, License - CC BY-SA 4.0
          DataTable(
            dataTextStyle: TextStyle(color: Colors.white),
            columnSpacing: 50,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Word',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              DataColumn(
                label: Text(
                  'Times used',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                headingRowAlignment: MainAxisAlignment.center
              ),
            
            ],
            rows: dataList
          ),
        ],
      ),
      )
    );
  }

}


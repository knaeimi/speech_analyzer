import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:speech_to_text_pro/speech_to_text_pro.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

// Can probably just make this a stateful widget then get rid of the speech and speech state classes
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
  HashMap<String,int> textMap = HashMap<String,int>();
  List<MapEntry<String,int>> textList = [];
  List<DataRow> dataList = [];
  List<String> wordList = [];
  List<String> sentenceList = [];
  String initialWords = '';

  
  // final _plugin = SpeechToTextPro(); 
  // StreamSubscription? _subscription;
  // String? _text; // make sure this is right

  void baseAnalysis(String words){
    wordList.clear();
    textMap.clear();
    initialWords = words;
    wordList = words.replaceAll(RegExp(r"[,.;@#?!&$'-/()]"), '').replaceAll("\n", " ").replaceAll("/t"," ").replaceAll("  ", " ").split(' ');
    for (String word in wordList){ // Empty input was counted as word, this check fixes that and also don't need trim anymore
      if (word.isNotEmpty) textMap.update(word, (value) => ++value, ifAbsent: () => 1);
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
      if (!prepositions.contains(word)&word.isNotEmpty){
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
    if (lengths.isEmpty){
      return 0;
    }
    double average = lengths.reduce((a,b) => a + b) / lengths.length;  
    return average;  
  }
}

// Class Created for the initialization of speech library
class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

// Class where speech library is initialized
class _SpeechState extends State<Speech> {
  final _plugin = SpeechToTextPro();
  StreamSubscription? _subscription;
  String? _text; // make sure this is right
  bool isAvailable = false;
  var micPermission;
  // bool hasPermission = await _plugin.hasPermission();

  // Figure out which of these is necessary and which isn't 

  // State (for both modes)
  List<String> _availableLocales = [];
  String _selectedLocale = 'en-US';
  bool _isListening = false;
  double _volume = 0.0;
  String _status = 'Idle';

  // Pro Mode State
  String _finalizedText = '';
  String _partialText = '';
  double _wpm = 0.0;
  int _totalWords = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _plugin.onListeningStateChanged.listen((listening) {
      setState(() {
        _isListening = listening;
        _status = listening ? 'Listening' : 'Idle';
      });
    });
    
    micPermission = await Permission.microphone.request();
    if (micPermission.isGranted) {
        isAvailable = await _plugin.initialize(
        onStatus: (status) => print('Engine Status: $status'),
        onError: (error) => print("Engine Error: $error"),
      );
      if (isAvailable) {
        _subscription = _plugin.onTranscriptUpdate.listen((transcript) {
          setState(() =>
            _text = transcript.fullText,
          );
        });
      }
    } else {
      print(micPermission.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _plugin.stop();
    super.dispose();
  }

  // Change, edit, refactor if necessary
  // Speech Input page UI
  @override
  Widget build(BuildContext context) {
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
                  // textMap.clear();
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => AnalysisPage())
                    );
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
              // controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Speak...',
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
                  // myController.clear();
                }, 
                child: Text("Clear")
                
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _plugin.onTranscriptUpdate.listen((transcript) {
                    print(transcript.fullText);
                    }
                  ); 
                },
                child: Text("Submit"),
              ),
            ],
          ),
              // Button placement temporary
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  _plugin.onTranscriptUpdate.listen((transcript) => 
                    setState(() {
                      _finalizedText = transcript.finalizedText;
                      _partialText = transcript.partialText; 
                      print(_partialText);
                    }),
                  );
                  await _plugin.start(localeId: 'en-US');
                  Text(_partialText);
                }, 
                child: Icon(
                  Icons.mic,
                  semanticLabel: "Mic button: press and begin speech",
                )
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _plugin.stop();
                }, 
                child: Text("Pause")
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print(_finalizedText);
                }, 
                child: Text("Continue")
              ),
        ],
      ),
      )
    );
  }
}

/**
 * Text Input page class
 */
class TextInputPage extends StatelessWidget {
  const TextInputPage({super.key});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Speech()) 
                    );
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
                hintText: 'Input your text here...',
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
                  dataList.clear(); 
                  words = myController.text.toLowerCase();
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
                  if (average==0){
                    showDialog<void>(
                    context: context,
                    builder: (context) {
                    return AlertDialog(
                      content: Text("You need to include a period to return a sentence length."),
                      );
                    },
                  );
                  }
                  else {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                      return AlertDialog(
                        content: Text("Your average sentence length is ${average.toStringAsFixed(2)} words per sentence."),
                        );
                      },
                    );
                  }
                },
                child: Text("Average Sentence Length"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => TextInputPage()) // Switches but analysis page is
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


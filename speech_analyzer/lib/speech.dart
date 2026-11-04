import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'analysisPage.dart';
import 'myApp.dart';
import 'package:provider/provider.dart';


// Class Created for the initialization of speech library
class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

// Class where speech library is initialized
class _SpeechState extends State<Speech> {
  final recorder = AudioRecorder();
  bool isAvailable = false;
  var micPermission;
  var stat;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _currentWords = '';

  final audioFilePath = 'web/myRecording.wav';
  // bool hasPermission = await _plugin.hasPermission();

  // Figure out which of these is necessary and which isn't 

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
    // maybe remove?
    micPermission = await Permission.microphone.request();
    stat = await Permission.microphone.status;
  }

  void _startListening() async {
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
      onResult: _onSpeechResult, 
      listenOptions: 
      SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true),
    );
    setState(() {
      _speechEnabled = true;
    });
  }

  void _stopListening() async{
    setState(() {
      _speechEnabled = false;
    });
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
    });
  }

  void _statusListener(String status) async {
    if (status == "done" && _speechEnabled) {
      setState(() {
        _lastWords += " $_currentWords ";
        _currentWords = "";
        _speechEnabled = false;
      });
    }
    _startListening();
  }

  final recordConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 24000,
    numChannels: 1,
    autoGain: true,
    echoCancel: true,
    noiseSuppress: true,
  );  

  // Change, edit, refactor if necessary
  // Speech Input page UI
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var myController = appState.myController;

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
                  print(_lastWords); 
                },
                child: Text("Submit"),
              ),
            ],
          ),
              // Button placement temporary
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (await Permission.microphone.request().isGranted) {
                    //recorder.start(recordConfig, path: audioFilePath);
                    _startListening();
                  }
                }, 
                child: Icon(
                  Icons.mic,
                  semanticLabel: "Mic button: press and begin speech",
                )
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _stopListening();
                  //final String? path = await recorder.stop();
                  print('stop');
                  _statusListener("done");
                  //print(path);
                  print(_lastWords);

                  appState.baseAnalysis(_lastWords);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalysisPage())
                    );
                }, 
                child: Text("Stop")
              ),
              SizedBox(height: 20),
        ],
      ),
      )
    );
  }
}
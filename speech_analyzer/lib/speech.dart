import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'analysisPage.dart';
import 'controllers/analysis_controller.dart';
import 'package:provider/provider.dart';


// Class Created for the initialization of speech library
class Speech extends StatefulWidget {
  const Speech({super.key});

  @override
  State<Speech> createState() => _SpeechState();
}

// Class where speech library is initialized
class _SpeechState extends State<Speech> {
  bool isAvailable = false;
  var micPermission;
  var stat;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _currentWords = '';
  double _pluginConfidenceScore = 1.0;

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

  // TODO: change such that we no longer use the delay. 
  // Have something on UI that shows when speechToText starts listening
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

  // TODO: speechToText does not stop listening when you click stop
  Future _stopListening() async {
    setState(() {
      _speechEnabled = false;
    });
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
      if (result.hasConfidenceRating && result.confidence > 0) {
        _pluginConfidenceScore = result.confidence;
      }
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _speechToText.cancel();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                label: Text(
                  'Text',
                  style: TextStyle(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18 
                  )
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Speech',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18 
                  )
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
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
                  _currentWords = _currentWords.toLowerCase();
                  context.read<AnalysisController>().analyze(_currentWords);
                  print(_pluginConfidenceScore);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnalysisPage())
                    ); 
                },
                child: Text("Submit"),
              ),
              SizedBox(width:20),
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
              SizedBox(width: 20),
              // TODO: speechToText does not stop listening when you click stop
              ElevatedButton(
                onPressed: () async {
                  await _stopListening();
                  if (!context.mounted) return;
                  print('stop');
                  _statusListener("done");
                  print(_lastWords);

                  context.read<AnalysisController>().analyze(_lastWords);
                }, 
                child: Text("Stop")
              ),
            ],
          ),
          SizedBox(height:30),
          SizedBox(
            height:200,
            width:500,
            child: TextField(
              style: TextStyle(color: Colors.white),
              maxLines: 10,
              // controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: _currentWords,
                hintStyle: TextStyle(color: Colors.white)
              ),
            ),
          ),
          SizedBox(height:30),
          Container(
            width: 500,
            height: 200,
            padding: EdgeInsetsGeometry.fromLTRB(10,10,10,10),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: SingleChildScrollView(
              child: Text(
                _currentWords,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white),
                softWrap: true,
                maxLines: 20,
              )
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
      )
    );
    
  }
}
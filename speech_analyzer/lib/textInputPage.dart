import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analysisPage.dart';
import 'speech.dart';
import 'controllers/analysis_controller.dart';

/**
 * Text Input page class
 */
class TextInputPage extends StatefulWidget {
  const TextInputPage({super.key});

  @override
  State<TextInputPage> createState()  => _TextInputPageState();

}

class _TextInputPageState extends State<TextInputPage> {
  final _textController = TextEditingController();


  @override
  void dispose(){
    _textController.dispose();
    super.dispose();
  }

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
                  context.read<AnalysisController>().clearWordCounts();
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
              controller: _textController,
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
                  _textController.clear();
                }, 
                child: Text("Clear")
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AnalysisController>().analyze(_textController.text.toLowerCase());
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

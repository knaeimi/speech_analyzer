import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/analysis_controller.dart';
import 'analysisPage.dart';

class SeeSpeechPage extends StatelessWidget{
  const SeeSpeechPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnalysisController>().state;

    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              "See Speech",
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
                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => AnalysisPage())
                    );
                  },
                  label: Text(
                    'Analysis',
                    style: TextStyle(
                      fontSize: 18 
                    )
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text(
                    'See Speech',
                    style: TextStyle(
                      fontSize: 18 
                    )
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: 500,
              height: 200,
              padding: EdgeInsetsGeometry.fromLTRB(10,10,10,10),
              decoration: BoxDecoration(border: Border.all(color: Colors.white)),
              child: SingleChildScrollView(
                child: Text(
                  state.sourceText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                  softWrap: true,
                  maxLines: 20,
                )
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back"),
            ),
          ]
        )
      )
    );
  }
}
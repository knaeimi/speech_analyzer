import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'myApp.dart';
import 'textInputPage.dart';

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
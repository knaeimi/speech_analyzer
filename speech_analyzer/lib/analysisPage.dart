import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/analysis_controller.dart';
import 'seeSpeechPage.dart';

/**
 * Analysis page class
 */
class AnalysisPage extends StatelessWidget{
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnalysisController>().state;

    return Scaffold(
      body: Center( 
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            "Analysis",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white
            )
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                label: Text(
                  'Analysis',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18 
                  )
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SeeSpeechPage()) 
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'See Speech',
                  style: TextStyle(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18 
                  )
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Source - https://stackoverflow.com/a/67434006
          // Posted by LihnNguyen
          // Retrieved 2026-10-09, License - CC BY-SA 4.0
          DataTable(
            dataTextStyle: TextStyle(color: Colors.white),
            columnSpacing: 50,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Select',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
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
            rows: [
              for(final entry in state.displayedWords)
                DataRow(
                  key: ValueKey(entry.word),
                  cells: [
                    DataCell(
                      Checkbox(
                        value: state.selectedWords.contains(entry.word),
                        onChanged: (value) => context
                            .read<AnalysisController>()
                            .setWordSelected(entry.word, value ?? false),
                      ),
                    ),
                    DataCell(Text(entry.word)),
                    DataCell(Text(entry.count.toString())),
                  ],
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                  context.read<AnalysisController>().removeReplace(),
                child: Text("Remove Selected"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => context.read<AnalysisController>().removeShortWords(), 
                child: Text("Remove Short Words")
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  final average = context
                    .read<AnalysisController>()
                    .averageSentenceLength();
                  final message = average == 0
                    ? 'You need to include a period to return a sentence length.'
                    : 'Your average sentence length is ${average.toStringAsFixed(2)} words per sentence.';
                  final wordCount = context
                    .read<AnalysisController>()
                    .totalWordCount();
                  final wordMessage = 'Your total word count is ${wordCount.toStringAsFixed(0)} words.';
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(content: Text('$message\n$wordMessage')),
                  );
                },
                child: Text("Length Analysis"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back"),
              ),
            ],
          ),
        ],
      ),
      )
    );
  }
}

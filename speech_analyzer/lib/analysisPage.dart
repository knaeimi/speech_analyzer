import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/analysis_controller.dart';

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
          SizedBox(height: 40),
          Text(
            "Analysis",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white
            )
          ),
          SizedBox(height: 20),
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
                  context.read<AnalysisController>().removeSelected(),
                child: Text("Remove Selected"),
              ),SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  final average = context
                    .read<AnalysisController>()
                    .averageSentenceLength();
                  final message = average == 0
                    ? 'You need to include a period to return a sentence length.'
                    : 'Your average sentence length is ${average.toStringAsFixed(2)} words per sentence.';
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(content: Text(message)),
                  );
                },
                child: Text("Average Sentence Length"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back"),
              ),
            ],
          ),
          SizedBox(height:20),
        ],
      ),
      )
    );
  }
}

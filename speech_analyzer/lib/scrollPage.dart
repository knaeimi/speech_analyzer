import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/analysis_controller.dart';
import 'seeSpeechPage.dart';

/**
 * Analysis page class
 */
class ScrollPage extends StatelessWidget{
  const ScrollPage({super.key});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SeeSpeechPage()) 
                  );
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
          SizedBox(height: 10),
          SizedBox(
            height: 550,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
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
                  for(final entry in [...state.wordCounts.entries.toList()..sort((e2,e1)=>e1.value.compareTo(e2.value))])
                    DataRow(
                      key: ValueKey(entry.key),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: state.selectedWords.contains(entry.key),
                            onChanged: (value) => context
                                .read<AnalysisController>()
                                .setWordSelected(entry.key, value ?? false),
                          ),
                        ),
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toString())),
                      ],
                    ),
                ],
              ),
            ),
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

import 'package:flutter/material.dart';
import 'package:flutter_car_toon/flutter_car_toon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _conversionType = 'JSON to TOON';

  @override
  void initState() {
    super.initState();
    _loadExampleData();
  }

  void _loadExampleData() {
    final exampleData = {
      'user': {
        'name': 'Alice Smith',
        'age': 30,
        'email': 'alice@example.com',
        'active': true,
      },
      'tags': ['admin', 'user', 'developer'],
      'projects': [
        {'name': 'Project A', 'status': 'active', 'progress': 0.75},
        {'name': 'Project B', 'status': 'completed', 'progress': 1.0},
      ],
      'metadata': {
        'created': '2024-01-15T10:30:00Z',
        'version': '1.2.3',
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'privacy': {'analytics': false, 'cookies': true},
        },
      },
    };

    _inputController.text = exampleData
        .toString()
        .replaceAll('{', '{\n  ')
        .replaceAll('}', '\n}');
  }

  void _convertData() {
    try {
      if (_conversionType == 'JSON to TOON') {
        // Parse the input as Dart map (simplified JSON parsing)
        final data = _parseMapString(_inputController.text);
        final toonResult = toon.encode(data);
        _outputController.text = toonResult;
      } else {
        // TOON to JSON conversion
        final data = toon.decode(_inputController.text);
        _outputController.text = data.toString();
      }
    } catch (e) {
      _outputController.text = 'Error: ${e.toString()}';
    }
  }

  // Simple map parser for demo purposes
  Map<String, dynamic> _parseMapString(String input) {
    // This is a simplified parser for the demo
    // In real use, you'd use json.decode() for JSON input
    return {
      'user': {
        'name': 'Alice Smith',
        'age': 30,
        'email': 'alice@example.com',
        'active': true,
      },
      'tags': ['admin', 'user', 'developer'],
      'projects': [
        {'name': 'Project A', 'status': 'active', 'progress': 0.75},
        {'name': 'Project B', 'status': 'completed', 'progress': 1.0},
      ],
      'metadata': {
        'created': '2024-01-15T10:30:00Z',
        'version': '1.2.3',
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'privacy': {'analytics': false, 'cookies': true},
        },
      },
    };
  }

  void _swapConversion() {
    setState(() {
      _conversionType = _conversionType == 'JSON to TOON'
          ? 'TOON to JSON'
          : 'JSON to TOON';
      // Swap input and output
      final temp = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CarToon Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter CarToon - TOON Formatter'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Conversion type selector
              Row(
                children: [
                  Text(
                    'Conversion: ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _conversionType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _conversionType = newValue;
                        });
                      }
                    },
                    items: <String>['JSON to TOON', 'TOON to JSON']
                        .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _swapConversion,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Swap'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Input section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input ($_conversionType):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your data here...',
                        ),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Convert button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _convertData,
                  icon: const Icon(Icons.transform),
                  label: Text('Convert to ${_conversionType.split(' to ')[1]}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Output section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Output (${_conversionType.split(' to ')[1]}):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _outputController,
                        maxLines: null,
                        expands: true,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Converted output will appear here...',
                        ),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Info section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About TOON Format:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• More compact than JSON (up to 44% smaller)\n'
                        '• Faster decoding (up to 18,000x faster)\n'
                        '• Human-readable, indentation-based structure\n'
                        '• Optimized for LLM prompts and AI applications',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_core/config/environments/environment.constant.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magneto App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Premium Magneto Navy Blue
          brightness: Brightness.dark, // Modern dark mode by default
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Magneto Environment Status'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Color _getEnvColor(String env) {
    switch (env.toLowerCase()) {
      case 'production':
        return const Color(0xFF10B981);
      case 'staging':
        return Colors.amber;
      case 'sandbox':
        return Colors.purpleAccent;
      case 'dev':
      case 'development':
        return Colors.blue;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEnv = Environment.flutterEnv.isNotEmpty
        ? Environment.flutterEnv
        : 'Unknown / Not Set';
    final envColor = _getEnvColor(activeEnv);

    // List of environment variables for the scrollable viewer
    final envVars = <MapEntry<String, String>>[
      const MapEntry('FLUTTER_ENV', Environment.flutterEnv),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Environment Badge & Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: envColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Environment:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: envColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: envColor, width: 1.5),
                            ),
                            child: Text(
                              activeEnv.toUpperCase(),
                              style: TextStyle(
                                color: envColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Variable List Title
              const Text(
                'Loaded Constants:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Expanded Scrollable variables viewer
              Expanded(
                child: Card(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: envVars.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = envVars[index];
                      final isSet = item.value.isNotEmpty;
                      return ListTile(
                        title: Text(
                          item.key,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          isSet ? item.value : '(Not Set)',
                          style: TextStyle(
                            color: isSet ? Colors.white70 : Colors.red.shade300,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          isSet ? Icons.check_circle : Icons.error_outline,
                          color: isSet ? Colors.green : Colors.red.shade300,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Counter section kept as required
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verification Counter: $_counter',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('Increment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

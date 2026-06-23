import 'package:flutter/material.dart';
import 'package:flutter_core/config/environments/environment.constant.dart';
import 'package:flutter_core/config/router/app_routes.dart';
import 'package:flutter_core/core/utils/env_color_util.dart';
import 'package:go_router/go_router.dart';

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeEnv = Environment.flutterEnv.isNotEmpty
        ? Environment.flutterEnv
        : 'Unknown / Not Set';
    final envColor = envColorFor(activeEnv);

    final envVars = <MapEntry<String, String>>[
      const MapEntry('FLUTTER_ENV', Environment.flutterEnv),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Status'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              'Active Environment:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
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
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: envColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
              const Text(
                'Loaded Constants:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.counter),
                icon: const Icon(Icons.exposure_plus_1),
                label: const Text('Open Counter Example'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Environment {
  const Environment._();

  static const String flutterEnv = String.fromEnvironment('FLUTTER_ENV');
  static const String nameApp = String.fromEnvironment('NAME_APP');
}

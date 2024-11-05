import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDay = true;

  void updateTheme(bool isDay) {
    setState(() {
      _isDay = isDay;
      _setStatusBarColor();
    });
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: _isDay ? Brightness.dark : Brightness.light,
    ));
  }

  @override
  void initState() {
    super.initState();
    _setStatusBarColor();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.black,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      themeMode: _isDay ? ThemeMode.light : ThemeMode.dark,
      home: MyHomePage(onThemeUpdate: updateTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(bool) onThemeUpdate;

  const MyHomePage({super.key, required this.onThemeUpdate});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _location = 'Edremit Balıkesir TR';
  Map<String, dynamic>? _weatherData;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchWeather() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/get/$_location'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _weatherData = data;
      });
      widget.onThemeUpdate(data['isDay'] ?? true);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Location'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Enter city name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _location = _searchController.text;
                });
                _fetchWeather();
                Navigator.of(context).pop();
                _searchController.clear();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getConditionColor(String condition, Brightness brightness) {
    bool isLightTheme = brightness == Brightness.light;
    String lowercaseCondition = condition.toLowerCase();

    // Check if the condition contains any of these keywords
    if (lowercaseCondition.contains('sunny')) {
      return isLightTheme ? Colors.orange : Colors.orange.shade700;
    } else if (lowercaseCondition.contains('cloud')) {
      return isLightTheme ? Colors.blue.shade200 : Colors.blue.shade400;
    } else if (lowercaseCondition.contains('wind')) {
      return isLightTheme ? Colors.blue.shade300 : Colors.blue.shade500;
    } else if (lowercaseCondition.contains('rain')) {
      return isLightTheme ? Colors.blue : Colors.blue.shade700;
    } else if (lowercaseCondition.contains('snow')) {
      return isLightTheme ? Colors.blue.shade100 : Colors.blue.shade300;
    } else if (lowercaseCondition.contains('thunder') ||
        lowercaseCondition.contains('storm')) {
      return isLightTheme ? Colors.purple : Colors.purple.shade700;
    } else {
      return isLightTheme ? Colors.grey : Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _weatherData == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 16.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        _weatherData!['date'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: GestureDetector(
                        onTap: _showSearchDialog,
                        child: Flexible(
                          child: Text(
                            _weatherData!['name'],
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                overflow: TextOverflow.fade),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.yellow.withOpacity(0.15),
                                      spreadRadius: 0,
                                      blurRadius: 150,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  'http://localhost:5000/icons/${_weatherData!['icon']}',
                                  width: 350,
                                  height: 350,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${_weatherData!['temp']}°',
                                  style: const TextStyle(
                                      fontSize: 144,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _weatherData!['condition'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: _getConditionColor(
                                        _weatherData!['condition'],
                                        Theme.of(context).brightness),
                                  ),
                                ),
                              ),
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
}

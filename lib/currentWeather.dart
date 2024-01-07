import 'package:flutter/material.dart';
import 'package:weather/models/weather.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrentWeatherPage extends StatefulWidget {
  const CurrentWeatherPage({Key? key}) : super(key: key);

  @override
  CurrentWeatherPageState createState() => CurrentWeatherPageState();
}

class CurrentWeatherPageState extends State<CurrentWeatherPage> {
  Weather? _weather; // Declare _weather with type Weather?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Your current weather display
          Center(
            child: FutureBuilder(
              builder: (context, snapshot) {
                _weather = snapshot.data;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text("Error getting weather");
                } else if (_weather == null) {
                  return const Text("No weather data");
                } else {
                  return weatherBox(_weather!);
                }
              },
              future: getCurrentWeather(),
            ),
          ),

          // Upcoming 7 days weather display
          Center(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FutureBuilder<List<Weather>>(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text("Error getting upcoming weather");
                    } else {
                      List<Weather>? upcomingWeather = snapshot.data;
                      return Row(
                        children: upcomingWeather?.map((weather) {
                          return SizedBox(
                            width: 150,
                            child: weatherBox(weather),
                          );
                        }).toList() ?? [],
                      );
                    }
                  },
                  future: getUpcomingWeather(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget weatherBox(Weather weather) {
    String imageUrl = getImageUrlForWeather(weather.description);

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          Text(
            "${weather.temp}°C",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(weather.description),
          SizedBox(height: 8),
          Text("Feels: ${weather.feelsLike}°C"),
          Text("High: ${weather.high}°C"),
          Text("Low: ${weather.low}°C"),
        ],
      ),
    );
  }

  String getImageUrlForWeather(String description) {
    Map<String, String> imageUrls = {
      'clear sky': 'assets/sunny_image.png',
      'few clouds': 'assets/cloudy_image.png',
      'scattered clouds': 'assets/cloudy_image.png',
      'broken clouds': 'assets/cloudy_image.png',
      'shower rain': 'assets/rainy_image.png',
      'rain': 'assets/rainy_image.png',
      'thunderstorm': 'assets/thunderstorm_image.png',
      'snow': 'assets/snowy_image.png',
      'mist': 'assets/misty_image.png',
    };

    String defaultImageUrl = 'assets/default_image.png';

    return imageUrls[description.toLowerCase()] ?? defaultImageUrl;
  }

  Future<Weather?> getCurrentWeather() async {
    Weather? weather;
    String city = "calgary";
    String apiKey = "cbed3a0e0fa8c2e0ee28bef06dfcd89a";
    var url = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      weather = Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }

    return weather;
  }

  Future<List<Weather>> getUpcomingWeather() async {
    List<Weather> upcomingWeather = [];

    String city = "calgary";
    String apiKey = "cbed3a0e0fa8c2e0ee28bef06dfcd89a";
    var url = "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> list = jsonResponse['list'];

      // Add the upcoming weather data
      for (int i = 0; i < 7 && i<list.length; i ++) {
        final Map<String, dynamic> data = list[i];
        upcomingWeather.add(Weather.fromJson(data));
      }
    } else {
      throw Exception('Failed to load upcoming weather data');
    }

    return upcomingWeather;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CurrentWeatherPage(),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config/helpers/human_format.dart';
import 'package:weather_app/infrastructure/services/extended_weather_service.dart';
import 'package:weather_app/infrastructure/services/weather_service.dart';
import 'package:weather_app/presentation/providers/weather_bg_provider.dart';
import '../../infrastructure/models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Weather? weatherHomeScreen;
  List<Map<String, dynamic>>? extendedWeatherHomeScreen;
  late WeatherBgProvider _weatherBgProvider;
  final _weatherService = WeatherService();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Map<String, dynamic>>? dailyWeatherData;

  final scrollController = ScrollController(); //? scroll controller

  bool isScrollingUp = false;
  bool isExtendedWeatherVisible = false;
  bool needsScroll = true; //? if didn't scroll yet -> true

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _weatherBgProvider = Provider.of<WeatherBgProvider>(context);
  }

  @override
  void initState() {
    super.initState();
  
    scrollController.addListener(onScroll);
    _fetchWeather();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  _fetchWeather() async {
    final cityName = await _weatherService.getCity();
  
    try {
      final weather = await _weatherService.getWeather(cityName);
      final _extendedWeatherService = ExtendedWeatherService(cityName: cityName);
      
      final _dailyWeatherData = await _extendedWeatherService.fetchWeatherDataPerDay();
      final time = Time();
      final hourNow = time.now.hour;
      const dayUntil = 20;
      const nightUntil = 5;
      late bool isDay = false;
      
      if (hourNow >= nightUntil && hourNow <= dayUntil) {
        isDay = true;
      } else if (hourNow > dayUntil && hourNow < nightUntil) {
        isDay = false;
      } else {
        isDay = true;
      }

      extendedWeatherHomeScreen = List.generate(_dailyWeatherData.length, (index) {
        final extendedWeather = _dailyWeatherData[index];
        return {
          'maxTemp': extendedWeather['maxTemp'],
          'minTemp': extendedWeather['minTemp'],
        };
      });

      setState(() {
        weatherHomeScreen = weather;
        extendedWeatherHomeScreen = _dailyWeatherData;
        dailyWeatherData = _dailyWeatherData;
      });
      _weatherBgProvider.updateWeather(isDay, weather.condition);
    } catch (e, stackTrace) {
      print('Error homescreen: $e');
      print('Stack trace: $stackTrace');
      throw Exception();
    }
  }

  Future<void> _handleRefresh() async => await _fetchWeather();

  String weatherAnimation (String? mainCond) {
    
    if (mainCond == null) return 'assets/Sunny.json';

    switch (mainCond.toLowerCase()) {
      case 'clouds':
        return 'assets/Clouds.json';
      case 'mist':
      case 'smoke':
      case 'dust':
      case 'haze':
      case 'fog':
        return 'assets/Fog.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'moderate rain':
      case '':
        return 'assets/Rainy.json';
      case 'thunderstorm':
        return 'assets/Thunderstorm';
      case 'clear':
        return 'assets/Sunny.json';
      case 'snow':
        return 'assets/Snow.json';
      default:
        return 'assets/Sunny.json';
    }

  }
  
  void onScroll() {
  if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
    setState(() {
      isScrollingUp = true;
      isExtendedWeatherVisible = false;
    });
  } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
    setState(() {
      isScrollingUp = false;
      isExtendedWeatherVisible = true;
    });
  } else if (scrollController.position.userScrollDirection == ScrollDirection.idle) {
    if (scrollController.offset <= 0) {
      setState(() {
        isExtendedWeatherVisible = false;
      });
    } else if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      setState(() {
        isExtendedWeatherVisible = true;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    
    _weatherBgProvider = Provider.of<WeatherBgProvider>(context);

    if (weatherHomeScreen == null) {
      return const CircularProgressIndicator(strokeWidth: 2);
    } else {  
      final time = Time();
      final hourNow = time.now.hour;
      const dayUntil = 20;
      const nightUntil = 5;
      late bool isDay = false;
      
      if (hourNow >= nightUntil && hourNow <= dayUntil) {
        isDay = true;
      } else if (hourNow > dayUntil && hourNow < nightUntil) {
        isDay = false;
      }
      return Scaffold (
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          displacement: 65,
          child: ListView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDay == true) 
                          const SizedBox(height: 135),
                          Text(weatherHomeScreen?.cityName ?? '', style: GoogleFonts.inter(
                            textStyle: textStyles.headlineMedium,
                            fontSize: 25
                          )),
                
                          const SizedBox(height: 8),
                
                          Text('${HumanFormat.number(weatherHomeScreen?.temp ?? 0, 1)}°', style: GoogleFonts.rubik(
                            textStyle: textStyles.headlineLarge, 
                            fontSize: 50,
                          )),
                
                          const SizedBox(height: 10),
                          
                          Lottie.asset(weatherAnimation(weatherHomeScreen?.condition)),
                
                          const SizedBox(height: 15),
          
                          Column(
                            children: [
                            
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                
                                  //? HUMIDITY
                                  Container(
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.water_drop_rounded, size: 18),
                                                SizedBox(width: 4),
                                                Text('HUMIDITY', style: TextStyle(fontSize: 14),)
                                              ],
                                            ),
                          
                                          Center(
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Text('${weatherHomeScreen?.humidity} %', style: const TextStyle(fontSize: 25),)
                                              ],
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          
                                  //? FEELS LIKE
                                  Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.people_alt_rounded, size: 18),
                                              SizedBox(width: 4),
                                              Text('FEELS LIKE', style: TextStyle(fontSize: 14),)
                                            ],
                                          ),
                                          Text('${HumanFormat.number(weatherHomeScreen?.feelsLike ?? 0, 1)}°C', style: const TextStyle(fontSize: 25),)
                                        ],
                                      ),
                                    ),
                                  ),
                          
                                ],
                              ),
                                    
                              const SizedBox(height: 20),
                          
                              //? MAX AND MIN TEMP
                              Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FaIcon(FontAwesomeIcons.temperatureArrowUp, size: 18),
                                          Text('MAX', style: TextStyle(fontSize: 14)),
                                          SizedBox(width: 65),  
                                          FaIcon(FontAwesomeIcons.temperatureArrowDown, size: 18),
                                          Text('MIN', style: TextStyle(fontSize: 14))
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 10),
                                          Text('${weatherHomeScreen?.maxTemp}°', style: const TextStyle(fontSize: 28)),
                                          const SizedBox(width: 68),
                                          Text('${weatherHomeScreen?.minTemp}°', style: const TextStyle(fontSize: 28))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          
                              // const SizedBox(height: 10),
                
                            ],
                          ),
                          needsScroll ? const Align(
                            widthFactor: 10,
                            alignment: Alignment.bottomCenter,
                            child: UserScrollAnimation(),
                          ) : Container( color: Colors.red),
                          
                        ]  
                      ), 
                    ),
                    
                      Visibility(
                        visible: isExtendedWeatherVisible,
                        maintainState: true,
                        maintainAnimation: true,
                        child: Align(
                          alignment: Alignment.center,
                          heightFactor: 10,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 205,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (int i = 0; i < dailyWeatherData!.length; i++)
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Card(
                                          elevation: 0,
                                          color: Colors.transparent,
                                          child: SizedBox(
                                            height: 230,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15, right: 15),
                                              child: Column(
                                                children: [
                                                  Text(_getDayName(DateTime.now().add(Duration(days: i+1)).weekday), style: const TextStyle(fontSize: 20),),
                                                  Lottie.asset(
                                                    weatherAnimation(dailyWeatherData![i]['condition']),
                                                    height: 88,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      FaIcon(FontAwesomeIcons.temperatureArrowUp, size: 14,),
                                                      Text('MAX', style: TextStyle(fontSize: 14)),
                                                      SizedBox(width: 30),
                                                      FaIcon(FontAwesomeIcons.temperatureArrowDown, size: 14),
                                                      Text('MIN', style: TextStyle(fontSize: 14))
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        '${HumanFormat.number(dailyWeatherData![i]['maxTemp'] ?? 0, 1)}°',
                                                        style: const TextStyle(fontSize: 20),
                                                      ),
                                                      const SizedBox(width: 30),
                                                      Text(
                                                        '${HumanFormat.number(dailyWeatherData![i]['minTemp'] ?? 0, 1)}°',
                                                        style: const TextStyle(fontSize: 20),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )

                              ],
                            )

                          ),
                        ),
                      )
                    
                  ],
                  
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: isScrollingUp && !isExtendedWeatherVisible ? const Align(
        //   widthFactor: 10,
        //   alignment: Alignment.bottomCenter,
        //   child: UserScrollAnimation()
        // ) : null,
      );
      
    }

  }
}

String _getDayName(int dayOfWeek) {
  switch (dayOfWeek) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}

class UserScrollAnimation extends StatelessWidget {
  const UserScrollAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Pulse(
      infinite: true,
      animate: true,
      curve: Curves.easeInOut,
      duration: const Duration(seconds: 4),
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: const Icon(Icons.arrow_upward_rounded)
      ),
    );
  }
}

class Time {
  late DateTime now = DateTime.now();
}

class DynamicCityTextColor extends StatelessWidget {
  
  final String cityName;
  final String temp;

  const DynamicCityTextColor({super.key, required this.cityName, required this.temp});

  @override
  Widget build(BuildContext context) {
    
    final weatherProvider = Provider.of<WeatherBgProvider>(context);
    final textStyles = Theme.of(context).textTheme;

    if (weatherProvider.isDay!) {
      return Column(
        children: [
          
          Text(cityName, style: GoogleFonts.inter(
            textStyle: textStyles.headlineMedium,
            fontSize: 25
          )),
        
          Text(temp, style: GoogleFonts.rubik(
            textStyle: textStyles.headlineLarge, 
            fontSize: 50,
          )),

        ],
      );
    } else if (weatherProvider.isDay == false) {
      return Column(
        children: [
          
          Text(cityName, style: GoogleFonts.inter(
            textStyle: textStyles.headlineMedium,
            fontSize: 25,
            color: Colors.white
          )),
        
          Text(temp, style: GoogleFonts.rubik(
            textStyle: textStyles.headlineLarge, 
            fontSize: 50,
            color: Colors.white
          )),

        ],
      );
    }
    return Column(
      children: [
        
        Text(cityName, style: GoogleFonts.inter(
          textStyle: textStyles.headlineMedium,
          fontSize: 25
        )),
      
        Text(temp, style: GoogleFonts.rubik(
          textStyle: textStyles.headlineLarge, 
          fontSize: 50,
        )),
      ],
    );

  }
}
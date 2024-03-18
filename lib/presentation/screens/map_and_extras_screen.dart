import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/infrastructure/services/map_service.dart';

class MapAndExtrasScreen extends StatefulWidget {
  const MapAndExtrasScreen({super.key});

  @override
  State<MapAndExtrasScreen> createState() => _MapAndExtrasScreenState();
}

class _MapAndExtrasScreenState extends State<MapAndExtrasScreen> {

  String? _selectedLayer;

  @override
  Widget build(BuildContext context) {
    final mapService = MapService();

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton( //? CLOUDS
                  onPressed: () => _showMap('clouds_new', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.cloud, size: 25)
                ),
                IconButton( //? RAIN
                  onPressed: () => _showMap('precipitation_new', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.cloudShowersHeavy, size: 25)
                ),
                IconButton( //? WIND
                  onPressed: () => _showMap('wind_new', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.wind, size: 25)
                ),
                IconButton( //? TEMP
                  onPressed: () => _showMap('temp_new', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.temperatureHigh, size: 25)
                ),

              ],
            ),
            
            const SizedBox(height: 35),

            if (_selectedLayer != null) ShowMapWidget(layer: _selectedLayer!)
          ],
        ),
      ),
    );
  }

  void _showMap(String layer, MapService mapService) {
    setState(() {
      _selectedLayer = layer;
    });
  }
}

Future<double> getLong() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position.longitude; 
}

 Future<double> getLat() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position.latitude; 
}


class ShowMapWidget extends StatelessWidget {
  
  final String layer;
  
  const ShowMapWidget({Key? key, required this.layer}): super(key: key);

  @override
  Widget build(BuildContext context) {

    final mapService = MapService();

    return FutureBuilder(
      future: Future.wait([getLong(), getLat()]), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(strokeWidth: 2);
        if (snapshot.hasError) return Text('error fetching coords: ${snapshot.error}');
        final double longitude = (snapshot.data![0]);
        final double latitude = (snapshot.data![1]);
        final Future<String> mapUrlFuture = mapService.getWeatherMap(8, longitude, latitude, layer);

        return FutureBuilder<String>(
          future: mapUrlFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(strokeWidth: 2);
            if (snapshot.hasError) return Text('Error fetching map: ${snapshot.error}');
            final String mapUrlToUse = snapshot.data!;
            return Image.network(mapUrlToUse);
          },
        );
      },
    );
  }
}
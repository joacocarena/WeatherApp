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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                IconButton( //? CLOUDS
                  onPressed: () => _showMap('clouds_new', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.cloud, size: 20)
                ),
                IconButton( //? RAIN
                  onPressed: () => _showMap('precipitation', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.cloudShowersHeavy, size: 20)
                ),
                IconButton( //? WIND
                  onPressed: () => _showMap('wind_level', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.wind, size: 20)
                ),
                IconButton( //? TEMP
                  onPressed: () => _showMap('temperature', mapService), 
                  icon: const FaIcon(FontAwesomeIcons.temperatureHigh, size: 20)
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
    const int z = 7; //? ZOOM LEVEL

    return FutureBuilder(
      future: Future.wait([getLong(), getLat()]), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(strokeWidth: 2);
        if (snapshot.hasError) return Text('error fetching coords: ${snapshot.error}');
        final int longitude = (snapshot.data![0]).abs().toInt();
        final int latitude = (snapshot.data![1]).abs().toInt();
        final Future<String> mapUrlFuture = mapService.getWeatherMap(z, longitude, latitude, layer);

        return FutureBuilder<String>(
          future: mapUrlFuture, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(strokeWidth: 2);
            if (snapshot.hasError) return Text('Error fetching map: ${snapshot.error}');
            return Image.network(snapshot.data!);
          },
        );
      },
    );
  }
}
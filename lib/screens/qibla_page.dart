import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  final _locationStreamController =
      StreamController<QiblahDirection>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Jika bukan Android atau iOS → hentikan
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint("Qibla compass hanya berfungsi di Android/iOS.");
      return;
    }

    var status = await Permission.locationWhenInUse.status;

    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      FlutterQiblah.androidDeviceSensorSupport().then((support) {
        // FIX NULL-SAFETY
        if (support == true) {
          FlutterQiblah.qiblahStream.listen(
            (event) => _locationStreamController.add(event),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _locationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arah Qiblat")),
      body: (Platform.isAndroid || Platform.isIOS)
          ? StreamBuilder<QiblahDirection>(
              stream: _locationStreamController.stream,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final qiblahDirection = snapshot.data!;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudut Qiblat: ${qiblahDirection.qiblah?.toStringAsFixed(2)}°",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),

                      Transform.rotate(
                        angle: qiblahDirection.direction * (3.14159 / 180),
                        child: SizedBox(
                          height: 250,
                          width: 250,
                          child: Image.asset("assets/compass.png"),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Arahkan panah ke arah Ka'bah",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                "Qibla compass hanya bisa digunakan di Android / iOS.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}

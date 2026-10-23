import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const CompassApp());
}

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'البوصلة',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: const CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوصلة الأندرويد'),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        centerTitle: true,
      ),
      body: _hasPermission ? _buildCompass() : _buildPermissionRequest(),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off, size: 80, color: Color(0xFF8B949E)),
            const SizedBox(height: 20),
            const Text(
              'يتطلب التطبيق إذن الموقع للوصول إلى حساسات الاتجاه.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF8B949E)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _checkPermission,
              child: const Text(
                'تفعيل الصلاحيات',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطأ في الحساسات: ${snapshot.error}',
              style: const TextStyle(color: Color(0xFFF85149)),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF58A6FF)),
          );
        }

        double? heading = snapshot.data?.heading;

        if (heading == null) {
          return const Center(
            child: Text(
              'جهازك لا يحتوي على حساس البوصلة (Magnetometer)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 16),
            ),
          );
        }

        int degrees = heading.round();
        if (degrees < 0) degrees += 360;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'الاتجاه الحالي',
              style: TextStyle(fontSize: 18, color: Color(0xFF8B949E)),
            ),
            const SizedBox(height: 8),
            Text(
              '$degrees°',
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: Color(0xFF58A6FF),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF161B22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // المؤشر العلوي الثابت
                    Positioned(
                      top: 12,
                      child: Container(
                        width: 0,
                        height: 0,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.transparent, width: 8),
                            right: BorderSide(color: Colors.transparent, width: 8),
                            bottom: BorderSide(color: Color(0xFFF85149), width: 16),
                          ),
                        ),
                      ),
                    ),
                    // قرص البوصلة الدوار
                    Transform.rotate(
                      angle: (heading * (math.pi / 180) * -1),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF30363D),
                                width: 2,
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 14,
                            child: Text(
                              'N',
                              style: TextStyle(
                                color: Color(0xFFF85149),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 14,
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Positioned(
                            right: 18,
                            child: Text(
                              'E',
                              style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 18,
                            child: Text(
                              'W',
                              style: TextStyle(
                                color: Color(0xFF8B949E),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // النقطة المركزية
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF58A6FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

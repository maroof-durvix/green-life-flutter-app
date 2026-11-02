import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/app_controller.dart';
import '../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  bool showLoader = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Widget properly build hone ke baad splash start karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startSplash();
    });
  }

  Future<void> startSplash() async {
    // Splash image 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Loader show
    setState(() {
      showLoader = true;
    });

    // Leaf fill animation
    await _animationController.forward();

    if (!mounted) return;

    _navigateToNext();
  }

  void _navigateToNext() {
    if (!mounted) return;

    final appController = context.read<AppController>();

    if (appController.isUserSetupComplete) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.userSetup);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: showLoader
            ? _buildLeafLoader()
            : Image.asset(
                'assets/images/splash.jpg',
                key: const ValueKey('splash'),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,

                // Image error check
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image not loading\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildLeafLoader() {
    return Container(
      key: const ValueKey('loader'),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final value = _animationController.value;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 130,
                      color: Colors.green.withOpacity(0.3),
                    ),

                    ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: value,
                        child: const Icon(
                          Icons.eco,
                          size: 130,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Growing a Greener Future...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
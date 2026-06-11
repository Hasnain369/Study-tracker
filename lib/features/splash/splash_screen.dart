import 'package:flutter/material.dart';
import 'package:study_tracker/app/navigation/bottomNav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _barController;
  late AnimationController _fadeController;
  late AnimationController _logoController;

  late Animation<double> _barAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    // Progress bar animation
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeInOut,
    );

    // Fade out animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _startSplash();
  }

  Future<void> _startSplash() async {
    // Step 1: show logo
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();

    // Step 2: start bar
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _barController.forward();

    // Step 3: wait for bar to finish
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Step 4: fade out
    await _fadeController.forward();

    if (!mounted) return;

    // Step 5: navigate safely
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNav()),
    );
  }

  @override
  void dispose() {
    _barController.dispose();
    _fadeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_fadeAnimation),
      child: Scaffold(
        backgroundColor: const Color(0xFF5C6BC0),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              ScaleTransition(
                scale: _logoAnimation,
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 58,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Study Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your personal study assistant',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    Container(
                      height: 5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedBuilder(
                        animation: _barAnimation,
                        builder: (_, __) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _barAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _barAnimation,
                      builder: (_, __) => Text(
                        _barAnimation.value < 0.4
                            ? 'Loading...'
                            : _barAnimation.value < 0.8
                                ? 'Preparing dashboard...'
                                : 'Almost ready!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

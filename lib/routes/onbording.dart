import 'package:flutter/material.dart';
import 'package:objectremove/config.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // Method to mark first time as completed and navigate to paywall
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/paywall');
    }
  }

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppImages.onboarding1,
      'title': 'Remove Unwanted\nObjects Instantly',
      'subtitle': 'Just draw around anything you don’t want in your photo—dobject will erase it cleanly and effortlessly using powerful AI.',
      'button': 'Continue',
    },
    {
      'image': AppImages.onboarding2,
      'title': 'Replace Objects\nwith Ease',
      'subtitle': 'Select any object and swap it with something new—dobject makes intelligent replacements that blend naturally into your photo.',
      'button': 'Continue',
    },
    {
      'image': AppImages.onboarding3,
      'title': 'Expand Your Image\nBeyond Borders',
      'subtitle': 'Need more space? dobject uses AI to intelligently fill and extend your image—perfect for social posts, banners, or clean crops.',
      'button': 'Get Started',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    onboardingData[index]['image']!,
                    fit: BoxFit.fill,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          // ...existing code...
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Empty space on the left to center the indicator
                const SizedBox(width: 50),
                // Centered page indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingData.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.redAccent,
                    dotColor: Colors.grey,
                    dotHeight: 6,
                    dotWidth: 16,
                    spacing: 10,
                  ),
                ),
                // Skip button on the right
                TextButton(
                  onPressed: () {
                    _completeOnboarding();
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
// ...existing code...
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(26)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      onboardingData[currentIndex]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      onboardingData[currentIndex]['subtitle']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          if (currentIndex < onboardingData.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              onboardingData[currentIndex]['button']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

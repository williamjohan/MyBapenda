import 'package:mybapenda/presentation/features/onboarding/widgets/onboarding_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isFirstLaunch', false);

    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.camera_alt_rounded,
      "title": "Check BillBoards",
      "subtitle":
          "Cek papan reklame yang terdaftar dengan mengambil foto dan menggunakan data GPS yang tepat.",
    },
    {
      "icon": Icons.map_outlined,
      "title": "Geo Location",
      "subtitle":
          "Temukan lokasi papan reklame terdekat dengan fitur geo location yang akurat.",
    },
    {
      "icon": Icons.info_outline,
      "title": "View Details",
      "subtitle":
          "Lihat detail lengkap tentang papan reklame, termasuk ukuran, lokasi, dan status pendaftaran.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigasi functions
  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _completeOnboarding(context);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Widget buildPage(Map<String, dynamic> data) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data["icon"], size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  data["title"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data["subtitle"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index ? Colors.blue : Colors.blue.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(data: pages[index]);
                },
              ),
            ),

            // Page Indicator
            buildIndicator(),
            const SizedBox(height: 16),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    nextPage();
                  },
                  child: Text(
                    currentPage == 2 ? "Get Started" : "Next",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

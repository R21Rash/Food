import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OnboardingScreen displays a series of introductory screens to first-time users
/// with app features and value propositions before directing them to login.
/// The screen includes page indicators, navigation buttons, and the option to skip.
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Track the currently displayed onboarding page index
  int _currentPage = 0; 
  
  // Controller for the PageView to programmatically change pages
  final PageController _pageController = PageController();

  /// Content data for each onboarding screen
  /// Each screen has a title, description, and associated image
  final List<Map<String, String>> onboardingData = [
    {
      "title": "All your favorites",
      "description":
          "Get all your loved foods in one place. You just place the order — we do the rest!",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Order from chosen chef",
      "description":
          "Choose your favorite chef and enjoy freshly prepared meals delivered to your door.",
      "image": "assets/images/onboarding2.png",
    },
    {
      "title": "Free delivery offers",
      "description":
          "Enjoy limited-time free delivery deals and exclusive promotions for loyal users.",
      "image": "assets/images/onboarding3.png",
    },
  ];

  /// Marks the onboarding process as completed in SharedPreferences
  /// and navigates the user to the login screen
  Future<void> completeOnboarding() async {
    // Store flag indicating user has seen onboarding
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hasSeenOnboarding", true);
    
    // Navigate to login screen, replacing this screen in the stack
    // so the user can't navigate back to onboarding
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // SafeArea to avoid notches and system UI overlaps
        child: Column(
          children: [
            // Top section containing PageView with onboarding content
            Expanded(
              flex: 3, // Takes 3/5 of the available space
              child: PageView.builder(
                controller: _pageController,
                // Update current page index when user swipes
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder:
                    (context, index) => OnboardingContent(
                      title: onboardingData[index]["title"]!,
                      description: onboardingData[index]["description"]!,
                      image: onboardingData[index]["image"]!,
                    ),
              ),
            ),

            // Bottom section containing pagination indicators and buttons
            Expanded(
              flex: 2, // Takes 2/5 of the available space
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pagination indicators (dots) to show current page position
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => buildDot(index: index),
                      ),
                    ),

                    // Primary action button - either Next or Get Started
                    SizedBox(
                      width: double.infinity, // Full width button
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // If on last page, complete onboarding
                          // Otherwise, move to next page with animation
                          if (_currentPage == onboardingData.length - 1) {
                            completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        // Button text changes on last page
                        child: Text(
                          _currentPage == onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Skip button to bypass the remaining onboarding screens
                    TextButton(
                      onPressed: completeOnboarding,
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual dot indicator for the pagination
  /// The current page's dot is wider and highlighted with orange color
  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Animation duration when changing state
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      // Width changes based on whether this dot represents the current page
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        // Color changes based on whether this dot represents the current page
        color: _currentPage == index ? Colors.orange : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Stateless widget representing a single onboarding page's content
/// Displays an image, title, and description
class OnboardingContent extends StatelessWidget {
  // Required parameters for the onboarding content
  final String title, description, image;

  const OnboardingContent({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30), // Top spacing
          // Image section - takes most of the space
          Expanded(flex: 3, child: Image.asset(image, fit: BoxFit.contain)),
          const SizedBox(height: 30),
          // Title section
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Description section
          Expanded(
            flex: 2,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5, // Line height for better readability
              ),
            ),
          ),
          const SizedBox(height: 30), // Bottom spacing
        ],
      ),
    );
  }
}

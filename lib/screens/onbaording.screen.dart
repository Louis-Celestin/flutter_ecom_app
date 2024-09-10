import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: <Widget>[
              OnboardingStep(
                title: "Bienvenue",
                description:
                    "Découvrez notre application de routing commercial.",
                imageAsset: "assets/images/onboarding1.png",
              ),
              OnboardingStep(
                title: "Planifiez vos visites",
                description:
                    "Organisez vos visites commerciales de manière efficace.",
                imageAsset: "assets/images/onboarding2.png",
              ),
              OnboardingStep(
                title: "Suivez vos performances",
                description:
                    "Suivez et analysez vos performances commerciales.",
                imageAsset: "assets/images/onboarding3.png",
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('onboardingCompleted', true);
                    Navigator.pushReplacementNamed(context,
                        '/login'); // Redirige vers la page de connexion
                  },
                  child: Text("Passer"),
                ),
                Row(
                  children: List.generate(
                    3,
                    (index) => _buildDot(index: index),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_currentPage == 2) {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('onboardingCompleted', true);
                      Navigator.pushReplacementNamed(context,
                          '/login'); // Redirige vers la page de connexion
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(_currentPage == 2 ? "Commencer" : "Suivant"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return Container(
      height: 10,
      width: 10,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingStep extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;

  const OnboardingStep({
    Key? key,
    required this.title,
    required this.description,
    required this.imageAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageAsset, height: 300),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

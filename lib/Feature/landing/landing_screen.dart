import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_social/Feature/feed/feed.dart';
import 'package:github_social/Feature/github%20frofile/github_profile_screeen.dart';
import 'package:github_social/service/provider_service.dart';

class LandingScreenView extends ConsumerStatefulWidget {
  final String accessToken;
  const LandingScreenView({super.key, required this.accessToken});

  @override
  ConsumerState<LandingScreenView> createState() => _LandingScreenViewState();
}

class _LandingScreenViewState extends ConsumerState<LandingScreenView> {
  final List<String> tabs = ["GitHub", "Feed"];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: tabs.length,
              onPageChanged: (index) {
                ref.read(selectedTabProvider.notifier).state = index;
              },
              itemBuilder: (context, index) {
                return index == 0
                    ? GithubProfileScreeen(
                        accessToken: widget.accessToken
                      )
                    : SocialFeedScreen();
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    tabs.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = index;
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: selectedIndex == index ? 20 : 18,
                                color: selectedIndex == index
                                    ? Colors.black
                                    : Colors.black38,
                                fontWeight: selectedIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            if (selectedIndex == index)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: tabs[index] == tabs[0] ? 50 : 30,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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

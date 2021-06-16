import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todolist/ui/HomeScreen.dart';
import 'package:todolist/ui/style.dart';
import 'package:todolist/utils/onboardingCheck.dart';
import 'package:todolist/utils/sizeConfig.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 6;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.widthMultiplier),
      height: SizeConfig.heightMultiplier,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(color: ColorScheme1.backgroundColor),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        _buildOnboardPage("assets/images/Tap.PNG"),
                        _buildOnboardPage("assets/images/mobile.PNG"),
                        _buildOnboardPage("assets/images/mobile2.PNG"),
                        _buildOnboardPage("assets/images/mi.PNG"),
                        _buildOnboardPage("assets/images/helo.PNG"),
                        _buildOnboardPage("assets/images/gid.PNG"),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async{
                            OnboardingCheck.updateOnboardingCheck();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                        },
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: SizeConfig.textMultiplier * 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _currentPage != 0
                    ? Positioned(
                        top: 0,
                        bottom: SizeConfig.heightMultiplier * 20,
                        right: 0,
                        left: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPageIndicator(),
                        ))
                    : Center()
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Hero(
            tag: "welcome",
            child: Container(
                height: SizeConfig.heightMultiplier * 8,
                width: double.infinity,
                color: ColorScheme1.backgroundColor,
                child: GestureDetector(
                  onTap: () async {
                    OnboardingCheck.updateOnboardingCheck();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Center(
                    child: Text(
                      'Tap to Get started',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.textMultiplier * 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          )
          : Text(''),
    );
  }

  Widget _buildOnboardPage(String url) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          '$url',
        ),
      )),
    ));
  }
}

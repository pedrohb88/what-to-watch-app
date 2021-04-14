import 'package:flutter/material.dart';

final _bodyPadding = EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0);

class AppBody extends StatelessWidget {

  Widget child;

  AppBody({@required this.child}) : assert(child != null);

  
  double _getSmartBannerHeight(BuildContext context) {
    MediaQueryData mediaScreen = MediaQuery.of(context);
    double dpHeight = mediaScreen.orientation == Orientation.portrait
        ? mediaScreen.size.height
        : mediaScreen.size.width;

    if (dpHeight <= 400.0) {
      return 32.0;
    }
    if (dpHeight > 720.0) {
      return 90.0;
    }
    return 50.0;
  }

  @override 
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/imgs/popcorn.jpg'),
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.05), BlendMode.dstATop),
        ),
      ),
      padding: _bodyPadding,
      constraints: BoxConstraints.expand(),
      child: Container(
        padding:
            EdgeInsets.only(bottom: _getSmartBannerHeight(context) + 5.0),
        child: child,
      ),
    );
  }
}
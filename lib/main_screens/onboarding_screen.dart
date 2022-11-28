// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ms_customer_app/galleries/shoes_gallery.dart';
import 'package:ms_customer_app/minor_screens/hot_deals.dart';
import 'package:ms_customer_app/minor_screens/subcateg_products.dart';
import 'package:ms_customer_app/providers/id_provider.dart';
import 'package:provider/provider.dart';

enum Offer {
  watches,
  shoes,
  sale,
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  Timer? countDownTimer;
  int seconds = 3;
  List<int> discountList = [];
  int? maxDiscount;
  late int selectedIndex;
  late String offerName;
  late String assetName;
  late Offer offer;
  late AnimationController _animationController;
  late Animation<Color?> _colorTweenAnimation;

  @override
  void initState() {
    selectRandomOffer();
    startTimer();
    getDiscount();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _colorTweenAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.red,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.repeat();
    context.read<IdProvider>().getDocId();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectRandomOffer() {
    // [1= watches, 2=shoes, 3=sale]
    for (var i = 0; i < Offer.values.length; i++) {
      var random = Random();
      setState(() {
        selectedIndex = random.nextInt(3);
        offerName = Offer.values[selectedIndex].toString();
        assetName = offerName.replaceAll("Offer.", "");
        offer = Offer.values[selectedIndex];
      });
    }
    print(selectedIndex);
    print(offerName);
    print(assetName);
  }

  void startTimer() {
    countDownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          seconds--;
        });
        if (seconds < 0) {
          stopTimer();
          Navigator.pushReplacementNamed(context, '/customer_home');
        }
        // print(timer.tick);
        // print(seconds);
      },
    );
  }

  void stopTimer() {
    countDownTimer!.cancel();
  }

  Widget buildAsset() {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        'images/onboard/$assetName.JPEG',
        fit: BoxFit.cover,
      ),
    );
  }

  void navigateToOffer() {
    switch (offer) {
      case Offer.watches:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SubCategProducts(
              subcategName: 't-shirt',
              maincategName: 'men',
              fromOnBoarding: true,
            ),
          ),
          (Route route) => false,
        );
        break;
      case Offer.shoes:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ShoesGalleryScreen(
              fromOnboarding: true,
            ),
          ),
          (Route route) => false,
        );
        break;
      case Offer.sale:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HotDealsScreen(
              fromOnBoarding: true,
              maxDiscount: maxDiscount.toString(),
            ),
          ),
          (Route route) => false,
        );
        break;
      // default:
    }
  }

  void getDiscount() {
    FirebaseFirestore.instance.collection('products').get().then(
      (QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          discountList.add(doc['discount']);
        }
      },
    ).whenComplete(() {
      setState(
        () {
          maxDiscount = discountList.reduce(max);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              stopTimer();
              navigateToOffer();
            },
            child: buildAsset(),
          ),
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              height: 35,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade600.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: () {
                  stopTimer();
                  Navigator.pushReplacementNamed(context, '/customer_home');
                },
                child: seconds < 1
                    ? const Text(
                        'Skip',
                      )
                    : Text(
                        'Skip | $seconds',
                      ),
              ),
            ),
          ),
          offer == Offer.sale
              ? Positioned(
                  top: 100,
                  right: 65,
                  child: AnimatedOpacity(
                    duration: const Duration(microseconds: 100),
                    opacity: _animationController.value,
                    child: Text(
                      maxDiscount.toString() + ('%'),
                      style: GoogleFonts.akayaTelivigala(
                        fontSize: 100,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          Positioned(
            bottom: 70,
            child: AnimatedBuilder(
              animation: _animationController.view,
              builder: (context, child) {
                return Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  color: _colorTweenAnimation.value,
                  child: child,
                );
              },
              child: const Center(
                child: Text(
                  'SHOP NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

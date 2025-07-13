import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fyp_project/screens/registration/login.dart';
import '../../backend/user/check_user.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  /// ImageList:
  List imageList = [
    {
      "id": 1,
      "imagePath": "assets/images/slider/slider1.png",
      "head": "Help the Needy",
      "body": "Your small act of kindness can\nchange someone's life."
    },
    {
      "id": 2,
      "imagePath": "assets/images/slider/slider2.png",
      "head": "Pick Up and Delivery Service",
      "body": "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed."
    },
    {
      "id": 3,
      "imagePath": "assets/images/slider/slider3.png",
      "head": "Request with Dignity",
      "body": "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed."
    }
  ];

  final CarouselSliderController carouselController = CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150.0),
        /// Appbar:
        child: AppBar(

          flexibleSpace: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/slider/design.PNG'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ]),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return ListView(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {},
                  /// Sliders Image:
                  child: CarouselSlider(
                    items: imageList
                        .map(
                          (item) => Column(
                        children: [
                          const SizedBox(height: 50),
                          Image.asset(
                            item["imagePath"],
                            height: 230,
                            width: 250,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item["head"],
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item["body"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                    options: CarouselOptions(
                      height: 400,
                      scrollPhysics: const BouncingScrollPhysics(),
                      autoPlay: true,
                      enableInfiniteScroll: true,
                      enlargeCenterPage: true,
                      aspectRatio: 2,
                      viewportFraction: 2,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                    carouselController: carouselController,
                  ),
                ),
                /// Slider Dot:
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageList.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => carouselController.animateToPage(entry.key),
                        child: Container(
                          width: currentIndex == entry.key ? 10 : 7,
                          height: currentIndex == entry.key ? 10 : 7,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == entry.key
                                ? const Color(0xFF9CCCF2)
                                : Colors.grey.shade400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),
            /// Button:
            Center(
              child: SizedBox(
                width: 250,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9CCCF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>LoginScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                        child: Text(
                          "   Get Started   ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

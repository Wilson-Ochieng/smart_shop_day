import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:smartshop/constants/app_constants.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/wigets/apptextname.dart';

class HomeScreen extends StatelessWidget {
  static const routName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: const Apptextname(fontSize: 20),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              SizedBox(
                height: size.height * 0.25,
                child: SizedBox(
                  height: size.height * 0.25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),

                    child: Swiper(
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.asset(
                          AppConstants.bannersImage[index],
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: AppConstants.bannersImage.length,
                      pagination: SwiperPagination(
                        // alignment: Alignment.center,
                        builder: DotSwiperPaginationBuilder(
                          activeColor: Colors.red,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.0),


             
            ],
          ),
        ),
      ),
    );
  }
}

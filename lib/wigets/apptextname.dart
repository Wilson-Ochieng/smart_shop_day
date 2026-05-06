import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smartshop/wigets/titletext.dart';

class Apptextname extends StatelessWidget {
  const Apptextname({super.key,required this.fontSize });
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return  Shimmer.fromColors(
    baseColor: Colors.purple,
    highlightColor: Colors.red,
    child: TitlesTextWidget(label: "Duka Letu")
  );
  }
}
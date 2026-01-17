import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.backgroundColor,
    this.textColor = AppColors.white,
    this.borderRadius = 25.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: !isOutlined ? (gradient ?? LinearGradient(
          colors: [backgroundColor ?? AppColors.primaryBlue, backgroundColor ?? AppColors.primaryBlue],
        )) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isOutlined ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: isOutlined ? AppColors.primaryBlue : textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

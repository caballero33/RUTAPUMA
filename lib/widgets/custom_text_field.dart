import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkGrey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, color: AppColors.primaryBlue)
                    : null,
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

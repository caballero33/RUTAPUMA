import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.white : AppColors.darkBlue;
    final surfaceColor = isDark ? AppColors.darkAccent : AppColors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color:
                  isDark
                      ? AppColors.white.withOpacity(0.8)
                      : AppColors.darkGrey,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color:
                  isDark
                      ? AppColors.white.withOpacity(0.3)
                      : AppColors.grey.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon:
                widget.prefixIcon != null
                    ? Icon(
                      widget.prefixIcon,
                      color:
                          isDark
                              ? AppColors.primaryYellow
                              : AppColors.primaryBlue,
                      size: 26,
                    )
                    : null,
            suffixIcon:
                widget.obscureText
                    ? IconButton(
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color:
                            isDark
                                ? AppColors.white.withOpacity(0.5)
                                : AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                    : null,
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide:
                  isDark
                      ? const BorderSide(color: AppColors.darkBorder, width: 1)
                      : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryYellow : AppColors.primaryBlue,
                width: 3,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: AppColors.red, width: 3),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }
}

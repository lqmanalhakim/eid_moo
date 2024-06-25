import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EMTextField extends StatefulWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final Icon? prefixIcon;

  final FocusNode? focusNode;

  const EMTextField({
    super.key,
    this.controller,
    this.obscureText = false,
    this.hintText,
    this.labelText,
    this.validator,
    this.focusNode,
    this.prefixIcon,
  });

  @override
  State<EMTextField> createState() => _EMTextFieldState();
}

class _EMTextFieldState extends State<EMTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: !showPassword && widget.obscureText,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon ?? const Icon(
          CupertinoIcons.lock,
          color: Colors.black,
          size: 26,
        ),
        suffixIcon: widget.obscureText ? IconButton(
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
          icon: Icon(
            showPassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            size: 18,
          ),
        ) : null,
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      validator: widget.validator,
    );
  }
}
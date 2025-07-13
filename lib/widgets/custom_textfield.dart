import 'package:flutter/material.dart';



/// CustomTextFields Class:
class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPassword;
  final bool isDropdown;
  final TextInputType? keyboardType;
  final Function(String) onChanged;
  final List<String>? dropdownItems;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int? maxLines;
  final String? initialValue; // Default value for dropdown

  /// Constructor:
  const CustomTextField({
    Key? key,
    required this.icon,
    required this.label,
    this.isPassword = false,
    this.isDropdown = false,
    this.keyboardType,
    this.validator,
    this.controller,
    required this.onChanged,
    this.dropdownItems,
    this.maxLines = 1,
    this.initialValue, // New parameter for default value
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;
  String? selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    selectedDropdownValue = widget.initialValue; // Set default value from constructor
  }

  /// CustomTextField:
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      /// For DropDown List:
      child: widget.isDropdown
          ? DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF989898),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF9CCDF2)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          isDense: true,
          errorStyle: const TextStyle(
            height: 0, // Removes error text height
            fontSize: 0, // Makes error text invisible
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 18,
            color: const Color(0xFF989898),
          ),
          label: Text(widget.label),
          labelStyle: const TextStyle(
            color: Color(0xFF989898),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: widget.validator,
        dropdownColor: Colors.white,
        value: selectedDropdownValue, // Default value set here
        items: widget.dropdownItems
            ?.map(
              (item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          ),
        )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedDropdownValue = value;
          });
          widget.onChanged(value!);
        },
      )

      /// For TextField:
          : TextFormField(
        maxLines: widget.maxLines,
        controller: widget.controller,
        obscureText: widget.isPassword && !isPasswordVisible,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          isDense: true,
          errorStyle: const TextStyle(
            height: 0, // Removes error text height
            fontSize: 8, // Makes error text invisible
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF989898),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF9CCDF2)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 18,
            color: const Color(0xFF989898),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF989898),
              size: 15,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          )
              : null,
          label: Text(widget.label),
          labelStyle: const TextStyle(
            color: Color(0xFF989898),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}

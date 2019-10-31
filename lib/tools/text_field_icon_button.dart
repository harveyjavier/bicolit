import 'package:flutter/material.dart';

class TextFieldIconButton extends StatelessWidget {
  final double size;
  final Function onPressed;
  final IconData icon;

  TextFieldIconButton({this.size = 30.0, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onPressed,
      child: SizedBox(
        width: size, height: size,
        child: Stack(
          alignment: Alignment(0.0, 0.0),
          children: <Widget>[
            Container( width: size, height: size, ),
            Icon( icon, size: size * 0.6, ),
          ],
        ),
      ),
    );
  }
}
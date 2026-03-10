import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LocationView extends StatelessWidget {
  final String? sourceLocation;
  final String? destinationLocation;

  const LocationView(
      {super.key, this.sourceLocation, this.destinationLocation});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              Icons.radio_button_unchecked,
              size: 20,
              color: themeChange.getThem() ? Colors.white : Colors.black,
            ),
            Dash(
                direction: Axis.vertical,
                length: Responsive.height(4, context),
                dashLength: 6,
                dashColor: AppColors.dottedDivider),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.moroccoGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sourceLocation.toString(),
                  maxLines: 2, style: GoogleFonts.poppins()),
              SizedBox(
                  height: calculateLineWraps(
                              text: sourceLocation.toString(),
                              textStyle: TextStyle(),
                              maxWidth: Responsive.width(80, context)) ==
                          2
                      ? Responsive.height(2.2, context)
                      : Responsive.height(4.4, context)),
              Text(
                destinationLocation.toString(),
                maxLines: 2,
                style: GoogleFonts.poppins(),
              )
            ],
          ),
        ),
      ],
    );
  }

  int calculateLineWraps({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null, // Allow unlimited lines
    )..layout(maxWidth: maxWidth);
    return textPainter.computeLineMetrics().length;
  }
}

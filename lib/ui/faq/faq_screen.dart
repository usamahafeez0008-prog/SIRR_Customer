import 'package:customer/constant/constant.dart';
import 'package:customer/model/faq_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.moroccoBackground,
      body: Column(
        children: [
          Container(
            height: Responsive.width(28, context),
            width: Responsive.width(100, context),
            decoration: const BoxDecoration(
              color: AppColors.moroccoRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "FAQs".tr,
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Read FAQs solution".tr,
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<FaqModel>?>(
                  future: FireStoreUtils.getFaq(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Constant.loader(isDarkTheme: themeChange.getThem());
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Center(child: Text(snapshot.error.toString()));
                        } else {
                          List<FaqModel> faqList = snapshot.data!;
                          return ListView.builder(
                            itemCount: faqList.length,
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            itemBuilder: (context, index) {
                              FaqModel faqModel = faqList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      iconColor: AppColors.moroccoRed,
                                      collapsedIconColor: Colors.grey,
                                      title: Text(
                                        Constant.localizationTitle(faqModel.title),
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF4A1520)),
                                      ),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                          child: Text(
                                            Constant.localizationDescription(faqModel.description),
                                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      default:
                        return Center(child: Text('Error'.tr));
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

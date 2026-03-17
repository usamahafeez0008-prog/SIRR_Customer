import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/rating_controller.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<RatingController>(
        init: RatingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoBackground,
            body: controller.isLoading.value == true
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.moroccoRed,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: () => Get.back(),
                                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                                          ),
                                          Text(
                                            "Rate Driver".tr,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 48),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -55,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: CachedNetworkImage(
                                    imageUrl: controller.driverModel.value.profilePic.toString(),
                                    height: 110,
                                    width: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColors.moroccoGreen,
                                      height: 110,
                                      width: 110,
                                      child: Center(
                                        child: Text(
                                          controller.driverModel.value.fullName![0].toUpperCase(),
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 70),
                        Text(
                          '${controller.driverModel.value.fullName}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: themeChange.getThem() ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              Constant.calculateReview(
                                reviewCount: controller.driverModel.value.reviewsCount.toString(),
                                reviewSum: controller.driverModel.value.reviewsSum.toString(),
                              ),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'How was your trip?'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: themeChange.getThem() ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                RatingBar.builder(
                                  initialRating: controller.rating.value,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 45,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber),
                                  onRatingUpdate: (rating) => controller.rating(rating),
                                ),
                                const SizedBox(height: 25),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10.0,
                                  runSpacing: 12.0,
                                  children: [
                                    "Polite".tr,
                                    "On time".tr,
                                    "Friendly".tr,
                                    "Easy location".tr,
                                    "Rude".tr,
                                    "Late".tr,
                                    "Attempt Fraud".tr,
                                  ].map((tag) {
                                    bool isSelected = controller.selectedTags.contains(tag);
                                    return InkWell(
                                      onTap: () {
                                        if (isSelected) {
                                          controller.selectedTags.remove(tag);
                                        } else {
                                          controller.selectedTags.add(tag);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(25),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                            ? (themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed)
                                            : (themeChange.getThem() ? AppColors.darkGray : Colors.grey[50]!),
                                          borderRadius: BorderRadius.circular(25),
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? Colors.white : (themeChange.getThem() ? Colors.white70 : Colors.black54),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 25),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.moroccoRed.withOpacity(0.5)),
                                  ),
                                  child: TextField(
                                    controller: controller.commentController.value,
                                    maxLines: 2,
                                    style: GoogleFonts.outfit(),
                                    decoration: InputDecoration(
                                      hintText: 'Share your feedback...'.tr,
                                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                                      contentPadding: const EdgeInsets.all(16),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.moroccoGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                if (controller.rating.value > 0 && (controller.commentController.value.text.isNotEmpty || controller.selectedTags.isNotEmpty)) {
                                  ShowToastDialog.showLoader("Please wait".tr);

                                  await FireStoreUtils.getDriver(
                                          controller.type.value == "orderModel" ? controller.orderModel.value.driverId.toString() : controller.intercityOrderModel.value.driverId.toString())
                                      .then((value) async {
                                    if (value != null) {
                                      DriverUserModel driverUserModel = value;
                                      if (controller.reviewModel.value.id != null) {
                                        driverUserModel.reviewsSum =
                                            (double.parse(driverUserModel.reviewsSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();
                                        driverUserModel.reviewsCount = (double.parse(driverUserModel.reviewsCount.toString()) - 1).toString();
                                      }
                                      driverUserModel.reviewsSum = (double.parse(driverUserModel.reviewsSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                                      driverUserModel.reviewsCount = (double.parse(driverUserModel.reviewsCount.toString()) + 1).toString();
                                      await FireStoreUtils.updateDriver(driverUserModel);
                                    }
                                  });

                                  controller.reviewModel.value.id = controller.type.value == "orderModel" ? controller.orderModel.value.id : controller.intercityOrderModel.value.id;
                                  controller.reviewModel.value.comment = controller.selectedTags.isNotEmpty
                                      ? "${controller.commentController.value.text} (${controller.selectedTags.join(', ')})"
                                      : controller.commentController.value.text;
                                  controller.reviewModel.value.rating = controller.rating.value.toString();
                                  controller.reviewModel.value.customerId = FireStoreUtils.getCurrentUid();
                                  controller.reviewModel.value.driverId =
                                      controller.type.value == "orderModel" ? controller.orderModel.value.driverId : controller.intercityOrderModel.value.driverId;
                                  controller.reviewModel.value.date = Timestamp.now();
                                  controller.reviewModel.value.type = controller.type.value == "orderModel" ? "city" : "intercity";

                                  await FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                                    if (value != null && value == true) {
                                      ShowToastDialog.closeLoader();
                                      ShowToastDialog.showToast("Review submit successfully".tr);
                                      Get.back();
                                    }
                                  });
                                } else {
                                  ShowToastDialog.closeLoader();
                                  ShowToastDialog.showToast("Please give rate in star and add feedback comment.".tr);
                                }
                              },
                              child: Text(
                                "SUBMIT REVIEW".tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          );
        });
  }
}

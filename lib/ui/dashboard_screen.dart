import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controller/dash_board_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DashBoardController>(
        init: DashBoardController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            drawerEnableOpenDragGesture: false,
            appBar: AppBar(
              backgroundColor: AppColors.moroccoBackground,
              elevation: 0,
              centerTitle: true,
              title: controller.selectedDrawerIndex.value != 0 &&
                      controller.selectedDrawerIndex.value != 6
                  ? ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.moroccoRed, AppColors.moroccoGreen],
                      ).createShader(bounds),
                      child: Text(
                        controller
                            .drawerItems[controller.selectedDrawerIndex.value]
                            .title
                            .tr,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/splash_image.png',
                        height: 90,
                      ),
                    ),
              leading: Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                         Scaffold.of(context).openDrawer();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/ic_humber.svg',
                        colorFilter: const ColorFilter.mode(
                            AppColors.moroccoRed, BlendMode.srcIn),
                      ),
                    ),
                  ),
                );
              }),
              actions: [
                controller.selectedDrawerIndex.value == 0
                    ? FutureBuilder<UserModel?>(
                        future: FireStoreUtils.getUserProfile(
                            FireStoreUtils.getCurrentUid()),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.moroccoRed),
                                ),
                              );
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                return const SizedBox();
                              } else {
                                UserModel? driverModel = snapshot.data;
                                if (driverModel == null)
                                  return const SizedBox();
                                return InkWell(
                                  onTap: () {
                                    controller.selectedDrawerIndex(8);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.moroccoGreen,
                                            width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                          )
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          height: 36,
                                          width: 36,
                                          imageUrl:
                                              driverModel.profilePic.toString(),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 1)),
                                          errorWidget: (context, url, error) =>
                                              Image.network(
                                            Constant.userPlaceHolder,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            default:
                              return const SizedBox();
                          }
                        })
                    : Container(),
              ],
            ),
            drawer: buildAppDrawer(context, controller),
            body: WillPopScope(
                onWillPop: controller.onWillPop,
                child: controller
                    .getDrawerItemWidget(controller.selectedDrawerIndex.value)),
          );
        });
  }

  Drawer buildAppDrawer(BuildContext context, DashBoardController controller) {
    RxList<DrawerItem> drawerItems = [
      DrawerItem('City'.tr, "assets/icons/ic_city.svg"),
      DrawerItem('OutStation'.tr, "assets/icons/ic_intercity.svg"),
      DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
      DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),
      DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),
      DrawerItem('Referral a friends'.tr, "assets/icons/ic_referral.svg"),
      DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),
      DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),
      DrawerItem('Contact us'.tr, "assets/icons/ic_contact_us.svg"),
      DrawerItem('Help & Support'.tr, "assets/icons/ic_help_support.svg"),
      DrawerItem('FAQs'.tr, "assets/icons/ic_faq.svg"),
      DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),
    ].obs;

    return Drawer(
      backgroundColor: AppColors.moroccoBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern in drawer
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: MoroccanPatternPainter(),
              ),
            ),
          ),
          Column(
            children: [
              // Drawer Header
              _buildDrawerHeader(context),

              // Drawer Items
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: drawerItems.length,
                  itemBuilder: (context, i) {
                    var d = drawerItems[i];
                    bool isSelected = i == controller.selectedDrawerIndex.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          controller.onSelectItem(i);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.moroccoRed.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                d.icon,
                                width: 22,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors.moroccoRed
                                      : Colors.grey.shade500,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                d.title,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? AppColors.moroccoRed
                                      : Colors.grey.shade700,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              if (isSelected) const Spacer(),
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.moroccoRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()),
      builder: (context, snapshot) {
        UserModel? driverModel = snapshot.data;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20,
            bottom: 24,
            left: 24,
            right: 24,
          ),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.moroccoGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.moroccoGreen.withOpacity(0.2),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: driverModel != null
                      ? CachedNetworkImage(
                          height: 70,
                          width: 70,
                          imageUrl: driverModel.profilePic.toString(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) =>
                              Image.network(Constant.userPlaceHolder),
                        )
                      : Container(
                          height: 70,
                          width: 70,
                          color: Colors.grey.shade200,
                          child:
                              Icon(Icons.person, color: Colors.grey.shade400),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                driverModel?.fullName.toString() ?? "Loading...",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.moroccoRed,
                ),
              ),
              Text(
                driverModel?.email.toString() ?? "",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MoroccanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.moroccoRed.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const double patternSize = 80.0;

    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        _drawEightPointStar(canvas, Offset(x, y), patternSize * 0.4, paint);
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      double nextAngle = (i + 0.5) * math.pi / 4;
      double nextX = center.dx + (radius * 0.7) * math.cos(nextAngle);
      double nextY = center.dy + (radius * 0.7) * math.sin(nextAngle);
      path.lineTo(nextX, nextY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

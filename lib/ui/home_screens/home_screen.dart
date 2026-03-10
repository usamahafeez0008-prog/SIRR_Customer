import 'dart:developer';

import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/home_controller.dart';
import 'package:customer/model/admin_commission.dart';
import 'package:customer/model/airport_model.dart';
import 'package:customer/model/contact_model.dart';
import 'package:customer/model/order/location_lat_lng.dart';
import 'package:customer/model/order/positions.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/service_model.dart';
import 'package:customer/services/helper.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Positioned.fill(
                                //   child: Opacity(
                                //     opacity: 0.05,
                                //     child: CustomPaint(
                                //       painter: MoroccanPatternPainter(),
                                //     ),
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${'Hello'.tr}, ${controller.userModel.value.fullName.toString()}",
                                        style: GoogleFonts.outfit(
                                          color: AppColors.moroccoRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/ic_location.svg',
                                            width: 16,
                                            colorFilter: const ColorFilter.mode(
                                                AppColors.moroccoGreen,
                                                BlendMode.srcIn),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              controller.currentLocation.value,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Visibility(
                                      //   visible:
                                      //       controller.bannerList.isNotEmpty,
                                      //   child: SizedBox(
                                      //       height: MediaQuery.of(context)
                                      //               .size
                                      //               .height *
                                      //           0.20,
                                      //       child: PageView.builder(
                                      //           padEnds: false,
                                      //           itemCount: controller
                                      //               .bannerList.length,
                                      //           scrollDirection:
                                      //               Axis.horizontal,
                                      //           controller:
                                      //               controller.pageController,
                                      //           itemBuilder: (context, index) {
                                      //             BannerModel bannerModel =
                                      //                 controller
                                      //                     .bannerList[index];
                                      //             return Padding(
                                      //               padding: const EdgeInsets
                                      //                   .symmetric(
                                      //                   horizontal: 10),
                                      //               child: CachedNetworkImage(
                                      //                 imageUrl: bannerModel
                                      //                     .image
                                      //                     .toString(),
                                      //                 imageBuilder: (context,
                                      //                         imageProvider) =>
                                      //                     Container(
                                      //                   decoration:
                                      //                       BoxDecoration(
                                      //                     borderRadius:
                                      //                         BorderRadius
                                      //                             .circular(20),
                                      //                     image: DecorationImage(
                                      //                         image:
                                      //                             imageProvider,
                                      //                         fit:
                                      //                             BoxFit.cover),
                                      //                   ),
                                      //                 ),
                                      //                 color: Colors.black
                                      //                     .withOpacity(0.5),
                                      //                 placeholder: (context,
                                      //                         url) =>
                                      //                     const Center(
                                      //                         child:
                                      //                             CircularProgressIndicator()),
                                      //                 fit: BoxFit.cover,
                                      //               ),
                                      //             );
                                      //           })),
                                      // ),
                                      const SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            )
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Where you want to go?".tr,
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            controller.sourceLocationLAtLng
                                                        .value.latitude ==
                                                    null
                                                ? InkWell(
                                                    onTap: () async {
                                                      print(
                                                          "::::::::::22::::::::::::");
                                                      if (Constant
                                                              .selectedMapType ==
                                                          'osm') {
                                                        final result =
                                                            await Get.to(() =>
                                                                MapPickerPage());
                                                        if (result != null) {
                                                          final firstPlace =
                                                              result;
                                                          final lat = firstPlace
                                                              .coordinates
                                                              .latitude;
                                                          final lng = firstPlace
                                                              .coordinates
                                                              .longitude;
                                                          final address =
                                                              firstPlace
                                                                  .address;
                                                          controller
                                                              .sourceLocationController
                                                              .value
                                                              .text = address;
                                                          controller
                                                                  .sourceLocationLAtLng
                                                                  .value =
                                                              LocationLatLng(
                                                                  latitude: lat,
                                                                  longitude:
                                                                      lng);
                                                          //Selected Zone
                                                          for (int i = 0;
                                                              i <
                                                                  controller
                                                                      .zoneList
                                                                      .length;
                                                              i++) {
                                                            if (Constant.isPointInPolygon(
                                                                LatLng(
                                                                    double.parse(controller
                                                                        .sourceLocationLAtLng
                                                                        .value
                                                                        .latitude
                                                                        .toString()),
                                                                    double.parse(controller
                                                                        .sourceLocationLAtLng
                                                                        .value
                                                                        .longitude
                                                                        .toString())),
                                                                controller
                                                                    .zoneList[i]
                                                                    .area!)) {
                                                              controller
                                                                      .selectedZone
                                                                      .value =
                                                                  controller
                                                                      .zoneList[i];
                                                            }
                                                          }
                                                          //Serviceid and Zoneid to set controller.selectedType.value.price
                                                          if (controller
                                                                  .selectedZone
                                                                  .value
                                                                  .id
                                                                  ?.isNotEmpty ==
                                                              true) {
                                                            Price?
                                                                selectedPrice =
                                                                controller
                                                                    .selectedType
                                                                    .value
                                                                    .prices
                                                                    ?.firstWhere(
                                                              (price) =>
                                                                  price
                                                                      .zoneId ==
                                                                  controller
                                                                      .selectedZone
                                                                      .value
                                                                      .id,
                                                              orElse: () =>
                                                                  Price(),
                                                            );
                                                            if (selectedPrice
                                                                    ?.zoneId !=
                                                                null) {
                                                              controller
                                                                  .selectedType
                                                                  .value
                                                                  .prices = [
                                                                selectedPrice!
                                                              ];
                                                              log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                                            }
                                                          }
                                                          await controller
                                                              .calculateDurationAndDistance();
                                                          controller
                                                              .calculateAmount();
                                                        }
                                                      } else {
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PlacePicker(
                                                              apiKey: Constant
                                                                  .mapAPIKey,
                                                              onPlacePicked:
                                                                  (result) async {
                                                                Get.back();
                                                                controller
                                                                        .sourceLocationController
                                                                        .value
                                                                        .text =
                                                                    result
                                                                        .formattedAddress
                                                                        .toString();
                                                                controller.sourceLocationLAtLng.value = LocationLatLng(
                                                                    latitude: result
                                                                        .geometry!
                                                                        .location
                                                                        .lat,
                                                                    longitude: result
                                                                        .geometry!
                                                                        .location
                                                                        .lng);
                                                                //Selected Zone
                                                                for (int i = 0;
                                                                    i <
                                                                        controller
                                                                            .zoneList
                                                                            .length;
                                                                    i++) {
                                                                  if (Constant.isPointInPolygon(
                                                                      LatLng(
                                                                          double.parse(controller
                                                                              .sourceLocationLAtLng
                                                                              .value
                                                                              .latitude
                                                                              .toString()),
                                                                          double.parse(controller
                                                                              .sourceLocationLAtLng
                                                                              .value
                                                                              .longitude
                                                                              .toString())),
                                                                      controller
                                                                          .zoneList[
                                                                              i]
                                                                          .area!)) {
                                                                    controller
                                                                        .selectedZone
                                                                        .value = controller
                                                                            .zoneList[
                                                                        i];
                                                                  }
                                                                }
                                                                //Serviceid and Zoneid to set controller.selectedType.value.price
                                                                if (controller
                                                                        .selectedZone
                                                                        .value
                                                                        .id
                                                                        ?.isNotEmpty ==
                                                                    true) {
                                                                  Price?
                                                                      selectedPrice =
                                                                      controller
                                                                          .selectedType
                                                                          .value
                                                                          .prices
                                                                          ?.firstWhere(
                                                                    (price) =>
                                                                        price
                                                                            .zoneId ==
                                                                        controller
                                                                            .selectedZone
                                                                            .value
                                                                            .id,
                                                                    orElse: () =>
                                                                        Price(),
                                                                  );
                                                                  if (selectedPrice
                                                                          ?.zoneId !=
                                                                      null) {
                                                                    controller
                                                                        .selectedType
                                                                        .value
                                                                        .prices = [
                                                                      selectedPrice!
                                                                    ];
                                                                    log("SelectedPrice :: ${controller.selectedType.value.prices?.length}");
                                                                  }
                                                                }
                                                                await controller
                                                                    .calculateDurationAndDistance();
                                                                controller
                                                                    .calculateAmount();
                                                              },
                                                              region: Constant.regionCode !=
                                                                          "all" &&
                                                                      Constant
                                                                          .regionCode
                                                                          .isNotEmpty
                                                                  ? Constant
                                                                      .regionCode
                                                                  : null,
                                                              initialPosition:
                                                                  const LatLng(
                                                                      -33.8567844,
                                                                      151.213108),
                                                              useCurrentLocation:
                                                                  true,
                                                              autocompleteComponents: Constant
                                                                              .regionCode !=
                                                                          "all" &&
                                                                      Constant
                                                                          .regionCode
                                                                          .isNotEmpty
                                                                  ? [
                                                                      Component(
                                                                          Component
                                                                              .country,
                                                                          Constant
                                                                              .regionCode)
                                                                    ]
                                                                  : [],
                                                              // Add this line
                                                              selectInitialPosition:
                                                                  true,
                                                              usePinPointingSearch:
                                                                  true,
                                                              usePlaceDetailSearch:
                                                                  true,
                                                              zoomGesturesEnabled:
                                                                  true,
                                                              zoomControlsEnabled:
                                                                  true,
                                                              resizeToAvoidBottomInset:
                                                                  false, // only works in page mode, less flickery, remove if wrong offsets
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: TextFieldThem.buildTextFiled(
                                                        context,
                                                        hintText:
                                                            'Enter Your Current Location'
                                                                .tr,
                                                        controller: controller
                                                            .sourceLocationController
                                                            .value,
                                                        enable: false))
                                                : Row(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          SvgPicture.asset(
                                                              themeChange
                                                                      .getThem()
                                                                  ? 'assets/icons/ic_source_dark.svg'
                                                                  : 'assets/icons/ic_source.svg',
                                                              width: 18),
                                                          Dash(
                                                              direction:
                                                                  Axis.vertical,
                                                              length: Responsive
                                                                  .height(6,
                                                                      context),
                                                              dashLength: 12,
                                                              dashColor: AppColors
                                                                  .dottedDivider),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppColors
                                                                      .darksecondprimary
                                                                  : AppColors
                                                                      .lightsecondprimary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/icons/ic_destination.svg',
                                                              width: 20,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppColors
                                                                      .containerBackground
                                                                  : AppColors
                                                                      .darkContainerBackground,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 18,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  print(
                                                                      "::::::::::33::::::::::::");
                                                                  if (Constant
                                                                          .selectedMapType ==
                                                                      'osm') {
                                                                    final result =
                                                                        await Get.to(() =>
                                                                            MapPickerPage());
                                                                    if (result !=
                                                                        null) {
                                                                      final firstPlace =
                                                                          result;
                                                                      final lat = firstPlace
                                                                          .coordinates
                                                                          .latitude;
                                                                      final lng = firstPlace
                                                                          .coordinates
                                                                          .longitude;
                                                                      final address =
                                                                          firstPlace
                                                                              .address;
                                                                      controller
                                                                          .sourceLocationController
                                                                          .value
                                                                          .text = address.toString();
                                                                      controller.sourceLocationLAtLng.value = LocationLatLng(
                                                                          latitude:
                                                                              lat,
                                                                          longitude:
                                                                              lng);
                                                                      await controller
                                                                          .calculateDurationAndDistance();
                                                                      controller
                                                                          .calculateAmount();
                                                                    }
                                                                  } else {
                                                                    await Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                PlacePicker(
                                                                          apiKey:
                                                                              Constant.mapAPIKey,
                                                                          onPlacePicked:
                                                                              (result) async {
                                                                            Get.back();
                                                                            controller.sourceLocationController.value.text =
                                                                                result.formattedAddress.toString();
                                                                            controller.sourceLocationLAtLng.value =
                                                                                LocationLatLng(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                                                            await controller.calculateDurationAndDistance();
                                                                            controller.calculateAmount();
                                                                          },
                                                                          region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                                              ? Constant.regionCode
                                                                              : null,
                                                                          initialPosition: const LatLng(
                                                                              -33.8567844,
                                                                              151.213108),
                                                                          useCurrentLocation:
                                                                              true,
                                                                          autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                                              ? [
                                                                                  Component(Component.country, Constant.regionCode)
                                                                                ]
                                                                              : [],
                                                                          selectInitialPosition:
                                                                              true,
                                                                          usePinPointingSearch:
                                                                              true,
                                                                          usePlaceDetailSearch:
                                                                              true,
                                                                          zoomGesturesEnabled:
                                                                              true,
                                                                          zoomControlsEnabled:
                                                                              true,
                                                                          resizeToAvoidBottomInset:
                                                                              false, // only works in page mode, less flickery, remove if wrong offsets
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: TextFieldThem.buildTextFiled(
                                                                          context,
                                                                          hintText: 'Enter Location'
                                                                              .tr,
                                                                          controller: controller
                                                                              .sourceLocationController
                                                                              .value,
                                                                          enable:
                                                                              false),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                        onTap:
                                                                            () {
                                                                          ariPortDialog(
                                                                              context,
                                                                              controller,
                                                                              true);
                                                                        },
                                                                        child: const Icon(
                                                                            Icons.flight_takeoff))
                                                                  ],
                                                                )),
                                                            SizedBox(
                                                                height: Responsive
                                                                    .height(1,
                                                                        context)),
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  print(
                                                                      "::::::::::11::::::::::::");
                                                                  if (Constant
                                                                          .selectedMapType ==
                                                                      'osm') {
                                                                    final result =
                                                                        await Get.to(() =>
                                                                            MapPickerPage());
                                                                    if (result !=
                                                                        null) {
                                                                      final firstPlace =
                                                                          result;
                                                                      final lat = firstPlace
                                                                          .coordinates
                                                                          .latitude;
                                                                      final lng = firstPlace
                                                                          .coordinates
                                                                          .longitude;
                                                                      final address =
                                                                          firstPlace
                                                                              .address;
                                                                      controller
                                                                          .destinationLocationController
                                                                          .value
                                                                          .text = address.toString();
                                                                      controller.destinationLocationLAtLng.value = LocationLatLng(
                                                                          latitude:
                                                                              lat,
                                                                          longitude:
                                                                              lng);
                                                                      await controller
                                                                          .calculateDurationAndDistance();
                                                                      controller
                                                                          .calculateAmount();
                                                                    }
                                                                  } else {
                                                                    await Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                PlacePicker(
                                                                          apiKey:
                                                                              Constant.mapAPIKey,
                                                                          onPlacePicked:
                                                                              (result) async {
                                                                            Get.back();
                                                                            controller.destinationLocationController.value.text =
                                                                                result.formattedAddress.toString();
                                                                            controller.destinationLocationLAtLng.value =
                                                                                LocationLatLng(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                                                            await controller.calculateDurationAndDistance();
                                                                            controller.calculateAmount();
                                                                          },
                                                                          region: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                                              ? Constant.regionCode
                                                                              : null,
                                                                          initialPosition: const LatLng(
                                                                              -33.8567844,
                                                                              151.213108),
                                                                          useCurrentLocation:
                                                                              true,
                                                                          autocompleteComponents: Constant.regionCode != "all" && Constant.regionCode.isNotEmpty
                                                                              ? [
                                                                                  Component(Component.country, Constant.regionCode)
                                                                                ]
                                                                              : [],
                                                                          selectInitialPosition:
                                                                              true,
                                                                          usePinPointingSearch:
                                                                              true,
                                                                          usePlaceDetailSearch:
                                                                              true,
                                                                          zoomGesturesEnabled:
                                                                              true,
                                                                          zoomControlsEnabled:
                                                                              true,
                                                                          resizeToAvoidBottomInset:
                                                                              false, // only works in page mode, less flickery, remove if wrong offsets
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: TextFieldThem.buildTextFiled(
                                                                          context,
                                                                          hintText: 'Enter destination Location'
                                                                              .tr,
                                                                          controller: controller
                                                                              .destinationLocationController
                                                                              .value,
                                                                          enable:
                                                                              false),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                        onTap:
                                                                            () {
                                                                          ariPortDialog(
                                                                              context,
                                                                              controller,
                                                                              false);
                                                                        },
                                                                        child: const Icon(
                                                                            Icons.flight_takeoff))
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        "Select Vehicle".tr,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: Responsive.height(24, context),
                                        child: ListView.builder(
                                          itemCount:
                                              controller.serviceList.length,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            ServiceModel serviceModel =
                                                controller.serviceList[index];
                                            return Obx(
                                              () => _buildServiceCard(
                                                context,
                                                controller,
                                                serviceModel,
                                                index,
                                                isDarkMode(context),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Obx(
                                        () => controller.sourceLocationLAtLng
                                                        .value.latitude !=
                                                    null &&
                                                controller
                                                        .destinationLocationLAtLng
                                                        .value
                                                        .latitude !=
                                                    null &&
                                                controller
                                                    .amount.value.isNotEmpty
                                            ? Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Container(
                                                      width: Responsive.width(
                                                          100, context),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .moroccoGreen
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    15)),
                                                        border: Border.all(
                                                            color: AppColors
                                                                .moroccoGreen
                                                                .withOpacity(
                                                                    0.3)),
                                                      ),
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 12),
                                                          child: Center(
                                                            child: controller
                                                                        .selectedType
                                                                        .value
                                                                        .offerRate ==
                                                                    true
                                                                ? RichText(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    text:
                                                                        TextSpan(
                                                                      text: 'Recommended Price is '
                                                                          .tr,
                                                                      style: GoogleFonts.outfit(
                                                                          color:
                                                                              Colors.black87),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              Constant.amountShow(amount: controller.amount.value),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: AppColors.moroccoRed),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ".\nApprox time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}".tr,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : RichText(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    text:
                                                                        TextSpan(
                                                                      text: 'Your Price is '
                                                                          .tr,
                                                                      style: GoogleFonts.outfit(
                                                                          color:
                                                                              Colors.black87),
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              Constant.amountShow(amount: controller.amount.value),
                                                                          style: const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: AppColors.moroccoRed),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ".\nApprox time ${controller.duration}. Approx distance ${double.parse(controller.distance.value).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}".tr,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      controller.selectedType.value.prices?[0]
                                                  .isAcNonAc ==
                                              true
                                          ? Obx(
                                              () => Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "Select A/C OR Non A/C"
                                                          .tr,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  SwitchListTile.adaptive(
                                                    activeColor: themeChange
                                                            .getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary,
                                                    title: Text(
                                                      'A/C'.tr.tr,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            isDarkMode(context)
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontFamily: "Poppins",
                                                      ),
                                                    ),
                                                    value: controller
                                                        .isAcSelected.value,
                                                    onChanged: (bool newValue) {
                                                      if (controller.sourceLocationLAtLng.value.latitude != null &&
                                                          controller
                                                                  .destinationLocationLAtLng
                                                                  .value
                                                                  .latitude !=
                                                              null &&
                                                          controller
                                                              .amount
                                                              .value
                                                              .isNotEmpty) {
                                                        controller.isAcSelected
                                                            .value = newValue;
                                                        controller
                                                            .calculateAmount();
                                                      } else {
                                                        ShowToastDialog.showToast(
                                                            "Please select source and destination location"
                                                                .tr);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      controller.selectedType.value.offerRate ==
                                              true
                                          ? const SizedBox(
                                              height: 10,
                                            )
                                          : SizedBox.shrink(),
                                      Visibility(
                                        visible: controller
                                                .selectedType.value.offerRate ==
                                            true,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          child: TextField(
                                            controller: controller
                                                .offerYourRateController.value,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9*]')),
                                            ],
                                            style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                color: Colors.black87),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  "Enter your offer rate".tr,
                                              hintStyle: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  color: Colors.grey),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              prefixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, right: 10),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      Constant
                                                          .currencyModel!.symbol
                                                          .toString(),
                                                      style: GoogleFonts.outfit(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .moroccoRed),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // someOneTakingDialog(
                                          //     context, controller);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.person_outline,
                                                  color: AppColors.moroccoRed),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  controller.selectedTakingRide
                                                              .value.fullName ==
                                                          "Myself"
                                                      ? "Myself".tr
                                                      : controller
                                                          .selectedTakingRide
                                                          .value
                                                          .fullName
                                                          .toString(),
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 15,
                                                      color: Colors.black87),
                                                ),
                                              ),
                                              const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () {
                                          paymentMethodDialog(
                                              context, controller);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/ic_payment.svg',
                                                width: 24,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                        AppColors.moroccoRed,
                                                        BlendMode.srcIn),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  controller
                                                          .selectedPaymentMethod
                                                          .value
                                                          .isNotEmpty
                                                      ? controller
                                                          .selectedPaymentMethod
                                                          .value
                                                      : "Select Payment type"
                                                          .tr,
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 15,
                                                      color: Colors.black87),
                                                ),
                                              ),
                                              const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ButtonThem.roundButton(
                                        context,
                                        title: "Book Ride".tr,
                                        btnColor: AppColors.moroccoRed,
                                        txtColor: Colors.white,
                                        btnWidthRatio: 1.0,

                                        onPress: () async {
                                          bool isPaymentNotCompleted =
                                              await FireStoreUtils
                                                  .paymentStatusCheck();
                                          if (controller.selectedPaymentMethod
                                              .value.isEmpty) {
                                            ShowToastDialog.showToast(
                                                "Please select Payment Method"
                                                    .tr);
                                          } else if (controller
                                              .sourceLocationController
                                              .value
                                              .text
                                              .isEmpty) {
                                            ShowToastDialog.showToast(
                                                "Please select source location"
                                                    .tr);
                                          } else if (controller
                                              .destinationLocationController
                                              .value
                                              .text
                                              .isEmpty) {
                                            ShowToastDialog.showToast(
                                                "Please select destination location"
                                                    .tr);
                                          } else if (double.parse(
                                                  controller.distance.value) <=
                                              2) {
                                            ShowToastDialog.showToast(
                                                "Please select more than two ${Constant.distanceType} location"
                                                    .tr);
                                          } else if (controller.selectedType
                                                      .value.offerRate ==
                                                  true &&
                                              controller.offerYourRateController
                                                  .value.text.isEmpty) {
                                            ShowToastDialog.showToast(
                                                "Please Enter offer rate".tr);
                                          } else if (isPaymentNotCompleted) {
                                            showAlertDialog(context);
                                            // showDialog(context: context, builder: (BuildContext context) => warningDailog());
                                          } else {
                                            ShowToastDialog.showLoader(
                                                "Please wait");
                                            OrderModel orderModel =
                                                OrderModel();
                                            orderModel.id = Constant.getUuid();
                                            orderModel.userId =
                                                FireStoreUtils.getCurrentUid();
                                            orderModel.sourceLocationName =
                                                controller
                                                    .sourceLocationController
                                                    .value
                                                    .text;
                                            orderModel.destinationLocationName =
                                                controller
                                                    .destinationLocationController
                                                    .value
                                                    .text;
                                            orderModel.sourceLocationLAtLng =
                                                controller
                                                    .sourceLocationLAtLng.value;
                                            orderModel
                                                    .destinationLocationLAtLng =
                                                controller
                                                    .destinationLocationLAtLng
                                                    .value;
                                            orderModel.distance =
                                                controller.distance.value;
                                            orderModel.acNonAcCharges = '';
                                            orderModel.duration =
                                                controller.duration.value;
                                            orderModel.distanceType =
                                                Constant.distanceType;
                                            orderModel.offerRate = controller
                                                        .selectedType
                                                        .value
                                                        .offerRate ==
                                                    true
                                                ? controller
                                                    .offerYourRateController
                                                    .value
                                                    .text
                                                : controller.amount.value;
                                            orderModel.serviceId = controller
                                                .selectedType.value.id;
                                            GeoFirePoint position =
                                                Geoflutterfire().point(
                                                    latitude: controller
                                                        .sourceLocationLAtLng
                                                        .value
                                                        .latitude!,
                                                    longitude: controller
                                                        .sourceLocationLAtLng
                                                        .value
                                                        .longitude!);

                                            orderModel.position = Positions(
                                                geoPoint: position.geoPoint,
                                                geohash: position.hash);
                                            orderModel.createdDate =
                                                Timestamp.now();
                                            orderModel.status =
                                                Constant.ridePlaced;
                                            orderModel.paymentType = controller
                                                .selectedPaymentMethod.value;
                                            orderModel.paymentStatus = false;
                                            orderModel.service =
                                                controller.selectedType.value;
                                            AdminCommission?
                                                adminCommissionGlobal;
                                            if (Constant.adminCommission
                                                    ?.isEnabled !=
                                                true) {
                                              adminCommissionGlobal =
                                                  Constant.adminCommission ??
                                                      AdminCommission();
                                              adminCommissionGlobal.amount =
                                                  '0';
                                            }
                                            log("controller.selectedType.value.adminCommission?.isEnabled :: ${controller.selectedType.value.adminCommission?.isEnabled} :: ${Constant.adminCommission?.isEnabled}");
                                            orderModel
                                                .adminCommission = controller
                                                        .selectedType
                                                        .value
                                                        .adminCommission
                                                        ?.isEnabled ==
                                                    false
                                                ? controller.selectedType.value
                                                    .adminCommission!
                                                : Constant.adminCommission
                                                            ?.isEnabled ==
                                                        false
                                                    ? adminCommissionGlobal
                                                    : Constant.adminCommission;
                                            orderModel.otp =
                                                Constant.getReferralCode();
                                            orderModel.isAcSelected = controller
                                                        .selectedType
                                                        .value
                                                        .prices?[0]
                                                        .isAcNonAc ==
                                                    true
                                                ? controller.isAcSelected.value
                                                : false;
                                            orderModel.taxList =
                                                Constant.taxList;
                                            if (controller.selectedTakingRide
                                                    .value.fullName !=
                                                "Myself") {
                                              orderModel.someOneElse =
                                                  controller
                                                      .selectedTakingRide.value;
                                            }

                                            for (int i = 0;
                                                i < controller.zoneList.length;
                                                i++) {
                                              if (Constant.isPointInPolygon(
                                                      LatLng(
                                                          double.parse(controller
                                                              .sourceLocationLAtLng
                                                              .value
                                                              .latitude
                                                              .toString()),
                                                          double.parse(controller
                                                              .sourceLocationLAtLng
                                                              .value
                                                              .longitude
                                                              .toString())),
                                                      controller
                                                          .zoneList[i].area!) ==
                                                  true) {
                                                controller.selectedZone.value =
                                                    controller.zoneList[i];
                                                break;
                                              }
                                            }
                                            if (controller
                                                    .selectedZone.value.id !=
                                                null) {
                                              orderModel.zoneId = controller
                                                  .selectedZone.value.id;
                                              orderModel.zone =
                                                  controller.selectedZone.value;
                                              await FireStoreUtils()
                                                  .sendOrderDataFuture(
                                                      orderModel)
                                                  .then((eventData) async {
                                                for (var driver in eventData) {
                                                  if (driver.fcmToken != null) {
                                                    Map<String, dynamic>
                                                        playLoad =
                                                        <String, dynamic>{
                                                      "type": "city_order",
                                                      "orderId": orderModel.id
                                                    };
                                                    await SendNotification
                                                        .sendOneNotification(
                                                            token:
                                                                driver
                                                                    .fcmToken
                                                                    .toString(),
                                                            title:
                                                                'New Ride Available'
                                                                    .tr,
                                                            body:
                                                                'A customer has placed a ride near your location.'
                                                                    .tr,
                                                            payload: playLoad);
                                                  }
                                                }
                                              });
                                              await FireStoreUtils.setOrder(
                                                      orderModel)
                                                  .then((value) {
                                                ShowToastDialog.showToast(
                                                    "Ride Placed successfully"
                                                        .tr);
                                                controller.dashboardController
                                                    .selectedDrawerIndex(2);
                                                ShowToastDialog.closeLoader();
                                              });
                                            } else {
                                              ShowToastDialog.closeLoader();
                                              ShowToastDialog.showToast(
                                                "Services are currently unavailable on the selected location. Please reach out to the administrator for assistance.",
                                              );
                                              return;
                                            }
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }

  Widget _buildServiceCard(
    BuildContext context,
    HomeController controller,
    ServiceModel serviceModel,
    int index,
    bool isDark,
  ) {
    final bool isSelected = controller.selectedType.value.id == serviceModel.id;

    // Unique "Moroccan Spotlight" card
    // – Selected   → full color, scale up slightly, glowing halo + flared top arch
    // – Unselected → grayscale wash, smaller, no glow
    final double cardW = Responsive.width(38, context);

    return GestureDetector(
      onTap: () async {
        controller.selectedType.value = serviceModel;
        Price? selectedPrice = controller.selectedType.value.prices?.firstWhere(
          (price) => price.zoneId == controller.selectedZone.value.id,
          orElse: () => Price(),
        );
        if (selectedPrice?.zoneId != null) {
          controller.selectedType.value.prices = [selectedPrice!];
        }
        controller.calculateAmount();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 0.94,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: Container(
          // Gradient border wrapper — only renders when selected.
          // 2.5px outer gradient shell that wraps the card WITHOUT covering content.
          width: cardW,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.moroccoRed,
                      AppColors.moroccoGreen,
                      AppColors.moroccoRed,
                    ],
                  )
                : null,
            // Subtle border for unselected state
            border: !isSelected
                ? Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.15),
                    width: 1,
                  )
                : null,
          ),
          // Inner padding creates the visible 2.5px gradient border ring
          padding: isSelected ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSelected ? 23.5 : 26),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Card body ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: ColorFiltered(
                    // Keep full color when selected, greyscale when not
                    colorFilter: isSelected
                        ? const ColorFilter.matrix(<double>[
                            // Identity matrix – no colour change
                            1, 0, 0, 0, 0,
                            0, 1, 0, 0, 0,
                            0, 0, 1, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.matrix(<double>[
                            // Greyscale matrix
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1C)
                            : const Color(0xFFF8F7F5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Top arch image tray ──
                          Expanded(
                            flex: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.moroccoRed.withOpacity(0.85),
                                    AppColors.moroccoGreen.withOpacity(0.75),
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Moroccan geometric background dots
                                  CustomPaint(
                                    painter: _ServiceCardPatternPainter(),
                                    child: const SizedBox.expand(),
                                  ),
                                  // Vehicle image
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: CachedNetworkImage(
                                      imageUrl: serviceModel.image.toString(),
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child:
                                            Constant.loader(isDarkTheme: true),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.network(
                                        Constant.userPlaceHolder,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Bottom info strip ──
                          Expanded(
                            flex: 40,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                              color: isDark
                                  ? const Color(0xFF1C1C1C)
                                  : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Constant.localizationTitle(
                                        serviceModel.title),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Status row
                                  // Row(
                                  //   children: [
                                  //     Container(
                                  //       width: 7,
                                  //       height: 7,
                                  //       decoration: BoxDecoration(
                                  //         shape: BoxShape.circle,
                                  //         color: isSelected
                                  //             ? AppColors.moroccoGreen
                                  //             : Colors.grey.shade400,
                                  //       ),
                                  //     ),
                                  //     const SizedBox(width: 5),
                                  //     Text(
                                  //       isSelected
                                  //           ? 'Active'.tr
                                  //           : 'Available'.tr,
                                  //       style: GoogleFonts.outfit(
                                  //         fontSize: 11,
                                  //         fontWeight: FontWeight.w600,
                                  //         color: isSelected
                                  //             ? AppColors.moroccoGreen
                                  //             : Colors.grey.shade400,
                                  //       ),
                                  //     ),
                                  //     const Spacer(),
                                  //     // Tap hint arrow
                                  //     if (!isSelected)
                                  //       Icon(
                                  //         Icons.touch_app_rounded,
                                  //         size: 15,
                                  //         color: isDark
                                  //             ? Colors.white24
                                  //             : Colors.black26,
                                  //       ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── "Selected" crown badge (top-right) ──
                if (isSelected)
                  Positioned(
                    top: -6,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.moroccoGreen,
                            Color(0xFF2A9D5C),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.moroccoGreen.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MY RIDE'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ), // closes Stack
          ), // closes AnimatedContainer (inner card)
        ), // closes Container (gradient border wrapper)
      ), // closes AnimatedScale
    ); // closes GestureDetector + return
  }

  paymentMethodDialog(BuildContext context, HomeController controller) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.grey),
                                onPressed: () => Get.back(),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Select Payment Method".tr,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.moroccoRed,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.cash!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller
                                                  .paymentModel.value.cash!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.cash!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .moroccoGreen
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                      Icons.payments_outlined,
                                                      color: AppColors
                                                          .moroccoGreen,
                                                      size: 28),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.cash!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.cash!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.cash!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.wallet!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .wallet!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.wallet!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.moroccoRed
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                      Icons
                                                          .account_balance_wallet_outlined,
                                                      color:
                                                          AppColors.moroccoRed,
                                                      size: 28),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.wallet!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.wallet!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.wallet!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.strip!.enable ==
                                      true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod
                                                    .value =
                                                controller.paymentModel.value
                                                    .strip!.name
                                                    .toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller.paymentModel
                                                            .value.strip!.name
                                                            .toString()
                                                    ? AppColors.moroccoRed
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade200),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Image.asset(
                                                          'assets/images/stripe.png',
                                                          fit: BoxFit.contain),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel
                                                          .value.strip!.name
                                                          .toString(),
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller
                                                        .paymentModel
                                                        .value
                                                        .strip!
                                                        .name
                                                        .toString(),
                                                    groupValue: controller
                                                        .selectedPaymentMethod
                                                        .value,
                                                    activeColor:
                                                        AppColors.moroccoRed,
                                                    onChanged: (value) {
                                                      controller
                                                              .selectedPaymentMethod
                                                              .value =
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .strip!
                                                              .name
                                                              .toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.paypal!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .paypal!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.paypal!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/paypal.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.paypal!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.paypal!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.paypal!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .payStack!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .payStack!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.payStack!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/paystack.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.payStack!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.payStack!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .payStack!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .mercadoPago!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .mercadoPago!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller
                                                          .paymentModel
                                                          .value
                                                          .mercadoPago!
                                                          .name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/mercadopago.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.mercadoPago!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.mercadoPago!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .mercadoPago!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .flutterWave!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .flutterWave!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller
                                                          .paymentModel
                                                          .value
                                                          .flutterWave!
                                                          .name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/flutterwave.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.flutterWave!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.flutterWave!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .flutterWave!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.payfast!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .payfast!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.payfast!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/payfast.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.payfast!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.payfast!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.payfast!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.paytm!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .paytm!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.paytm!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/paytm.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.paytm!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.paytm!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.paytm!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .razorpay!.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .razorpay!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.razorpay!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/razorpay.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.razorpay!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.razorpay!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .razorpay!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .midtrans?.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .midtrans!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.midtrans!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/midtrans.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.midtrans!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.midtrans!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .midtrans!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.xendit?.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .xendit!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.xendit!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/xendit.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.xendit!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.xendit!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.xendit!.name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value
                                          .orangePay?.enable ==
                                      true,
                                  child: Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .orangePay!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: controller
                                                          .selectedPaymentMethod
                                                          .value ==
                                                      controller.paymentModel
                                                          .value.orangePay!.name
                                                          .toString()
                                                  ? AppColors.moroccoRed
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.asset(
                                                        'assets/images/orange_money.png',
                                                        fit: BoxFit.contain),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.orangePay!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.orangePay!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor:
                                                      AppColors.moroccoRed,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .orangePay!
                                                            .name
                                                            .toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Pay",
                          onPress: () async {
                            Get.back();
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  someOneTakingDialog(BuildContext context, HomeController controller) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          return StatefulBuilder(builder: (context1, setState) {
            return Obx(
              () => Container(
                constraints:
                    BoxConstraints(maxHeight: Responsive.height(90, context)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Someone else taking this ride?",
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Choose a contact and share a code to confirm that ride.",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              controller.selectedTakingRide.value =
                                  ContactModel(
                                      fullName: "Myself", contactNumber: "");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: controller.selectedTakingRide.value
                                                .fullName ==
                                            "Myself"
                                        ? AppColors.moroccoRed
                                        : Colors.transparent,
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.moroccoRed
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person,
                                          color: AppColors.moroccoRed,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "Myself",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Radio(
                                      value: "Myself",
                                      groupValue: controller
                                          .selectedTakingRide.value.fullName,
                                      activeColor: AppColors.moroccoRed,
                                      onChanged: (value) {
                                        controller.selectedTakingRide.value =
                                            ContactModel(
                                                fullName: "Myself",
                                                contactNumber: "");
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            itemCount: controller.contactList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              ContactModel contactModel =
                                  controller.contactList[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                  onTap: () {
                                    controller.selectedTakingRide.value =
                                        contactModel;
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: controller.selectedTakingRide
                                                      .value.fullName ==
                                                  contactModel.fullName
                                              ? AppColors.moroccoRed
                                              : Colors.transparent,
                                          width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person,
                                                color: Colors.grey, size: 20),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              contactModel.fullName.toString(),
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Radio(
                                            value: contactModel.fullName
                                                .toString(),
                                            groupValue: controller
                                                .selectedTakingRide
                                                .value
                                                .fullName,
                                            activeColor: AppColors.moroccoRed,
                                            onChanged: (value) {
                                              controller.selectedTakingRide
                                                  .value = contactModel;
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              try {
                                final FlutterNativeContactPicker contactPicker =
                                    FlutterNativeContactPicker();
                                Contact? contact =
                                    await contactPicker.selectContact();
                                ContactModel contactModel = ContactModel();
                                contactModel.fullName = contact!.fullName ?? "";
                                contactModel.contactNumber =
                                    contact.selectedPhoneNumber;

                                if (!controller.contactList
                                    .contains(contactModel)) {
                                  controller.contactList.add(contactModel);
                                  controller.setContact();
                                }
                              } catch (e) {
                                rethrow;
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.contacts_rounded,
                                          color: Colors.black87, size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "Choose another contact",
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 14, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ButtonThem.buildButton(
                            context,
                            title:
                                "Book for ${controller.selectedTakingRide.value.fullName}",
                            onPress: () async {
                              Get.back();
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  ariPortDialog(
      BuildContext context, HomeController controller, bool isSource) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (context1) {
          return StatefulBuilder(builder: (context1, setState) {
            return Container(
              constraints:
                  BoxConstraints(maxHeight: Responsive.height(90, context)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Do you want to travel for AirPort?",
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Choose a single AirPort",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        itemCount: Constant.airaPortList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          AriPortModel airPortModel =
                              Constant.airaPortList![index];
                          return Obx(
                            () => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  controller.selectedAirPort.value =
                                      airPortModel;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: controller
                                                    .selectedAirPort.value.id ==
                                                airPortModel.id
                                            ? AppColors.moroccoRed
                                            : Colors.transparent,
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.moroccoRed
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.airplanemode_active,
                                              color: AppColors.moroccoRed,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            airPortModel.airportName.toString(),
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Radio(
                                          value: airPortModel.id.toString(),
                                          groupValue: controller
                                              .selectedAirPort.value.id,
                                          activeColor: AppColors.moroccoRed,
                                          onChanged: (value) {
                                            controller.selectedAirPort.value =
                                                airPortModel;
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(
                        context,
                        title: "Book",
                        onPress: () async {
                          if (controller.selectedAirPort.value.id != null) {
                            if (isSource) {
                              controller.sourceLocationController.value.text =
                                  controller.selectedAirPort.value.airportName
                                      .toString();
                              controller.sourceLocationLAtLng.value =
                                  LocationLatLng(
                                      latitude: double.parse(controller
                                          .selectedAirPort.value.airportLat
                                          .toString()),
                                      longitude: double.parse(controller
                                          .selectedAirPort.value.airportLng
                                          .toString()));
                              controller.calculateAmount();
                            } else {
                              controller.destinationLocationController.value
                                      .text =
                                  controller.selectedAirPort.value.airportName
                                      .toString();
                              controller.destinationLocationLAtLng.value =
                                  LocationLatLng(
                                      latitude: double.parse(controller
                                          .selectedAirPort.value.airportLat
                                          .toString()),
                                      longitude: double.parse(controller
                                          .selectedAirPort.value.airportLng
                                          .toString()));
                              controller.calculateAmount();
                            }
                            Get.back();
                          } else {
                            ShowToastDialog.showToast(
                                "Please select one airport");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Warning"),
      content: const Text(
          "You are not able book new ride please complete previous ride payment"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

// warningDailog() {
//   return Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
//     child: SizedBox(
//       height: 300.0,
//       ),
//     ),
//   );
// }
}

class MoroccanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.moroccoRed.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double patternSize = 100.0;

    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        _drawEightPointStar(canvas, Offset(x, y), patternSize * 0.45, paint);
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final Path path = Path();
    for (int i = 0; i < 16; i++) {
      final double angle = i * math.pi / 8;
      final double r = i.isEven ? radius : radius * 0.7;
      final double dx = center.dx + r * math.cos(angle);
      final double dy = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(center, radius * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ServiceCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x + y) % (spacing * 2) == 0) {
          canvas.drawCircle(Offset(x, y), 1.2, paint);
        }
      }
    }

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

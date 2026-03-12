import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/sos_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/ui/chat_screen/chat_screen.dart';
import 'package:customer/ui/hold_timer/hold_timer_screen.dart';
import 'package:customer/ui/orders/complete_order_screen.dart';
import 'package:customer/ui/orders/live_tracking_screen.dart';
import 'package:customer/ui/orders/order_details_screen.dart';
import 'package:customer/ui/orders/payment_order_screen.dart';
import 'package:customer/ui/review/review_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/utils.dart';

import 'package:customer/widget/location_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() =>
      _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Active Rides',
    'Completed',
    'Cancelled'
  ];
  final List<IconData> _tabIcons = [
    Icons.directions_car_outlined,
    Icons.check_circle_outline,
    Icons.cancel_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final themeChange =
        Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return Scaffold(
      backgroundColor:
          AppColors.moroccoBackground,
      body: Column(
        children: [
          // // ── Top spacing (matches original)
          // Container(
          //   height: Responsive.width(10, context),
          //   width: Responsive.width(100, context),
          //   color: AppColors.lightprimary,
          // ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .background,
                borderRadius:
                    const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // ── Custom Pill Selector (commented out)
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: isDark ? AppColors.darkGray : AppColors.gray,
                  //       borderRadius: BorderRadius.circular(14),
                  //     ),
                  //     padding: const EdgeInsets.all(4),
                  //     child: Row(
                  //       children: List.generate(_tabs.length, (i) {
                  //         final isSelected = _selectedIndex == i;
                  //         return Expanded(
                  //           child: GestureDetector(
                  //             onTap: () => setState(() => _selectedIndex = i),
                  //             child: AnimatedContainer(
                  //               duration: const Duration(milliseconds: 220),
                  //               curve: Curves.easeInOut,
                  //               padding: const EdgeInsets.symmetric(vertical: 10),
                  //               decoration: BoxDecoration(
                  //                 color: isSelected ? AppColors.moroccoRed : Colors.transparent,
                  //                 borderRadius: BorderRadius.circular(11),
                  //                 boxShadow: isSelected ? [BoxShadow(color: AppColors.moroccoRed.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))] : null,
                  //               ),
                  //               child: Column(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   Icon(_tabIcons[i], size: 18, color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black45)),
                  //                   const SizedBox(height: 3),
                  //                   Text(_tabs[i].tr, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54))),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       }),
                  //     ),
                  //   ),
                  // ),

                  // ── Dropdown Selector
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                            16, 20, 16, 12),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   color: isDark
                      //       ? AppColors.darkContainerBackground
                      //       : Colors.white,
                      //   borderRadius: BorderRadius.circular(14),
                      //   border: Border.all(
                      //     color: AppColors.moroccoRed.withOpacity(0.4),
                      //     width: 1.5,
                      //   ),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: AppColors.moroccoRed.withOpacity(0.08),
                      //       blurRadius: 10,
                      //       offset: const Offset(0, 4),
                      //     ),
                      //   ],
                      // ),
                      padding: const EdgeInsets
                          .symmetric(
                          horizontal: 16,
                          vertical: 4),
                      child:
                          DropdownButtonHideUnderline(
                        child:
                            DropdownButton<int>(
                          value: _selectedIndex,
                          isExpanded: true,
                          icon: Container(
                            padding:
                                const EdgeInsets
                                    .all(4),
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .moroccoRed
                                  .withOpacity(
                                      0.10),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              color: AppColors
                                  .moroccoRed,
                              size: 20,
                            ),
                          ),
                          dropdownColor: isDark
                              ? AppColors
                                  .darkContainerBackground
                              : Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(14),
                          onChanged:
                              (int? value) {
                            if (value != null) {
                              setState(() =>
                                  _selectedIndex =
                                      value);
                            }
                          },
                          items: List.generate(
                              _tabs.length, (i) {
                            return DropdownMenuItem<
                                int>(
                              value: i,
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .all(
                                            7),
                                    decoration:
                                        BoxDecoration(
                                      color: _selectedIndex ==
                                              i
                                          ? AppColors
                                              .moroccoRed
                                              .withOpacity(
                                                  0.12)
                                          : (isDark
                                              ? AppColors.darkGray
                                              : AppColors.gray),
                                      shape: BoxShape
                                          .circle,
                                    ),
                                    // child: Icon(
                                    //   _tabIcons[
                                    //       i],
                                    //   size: 16,
                                    //   color: _selectedIndex ==
                                    //           i
                                    //       ? AppColors
                                    //           .moroccoRed
                                    //       : (isDark
                                    //           ? Colors.white54
                                    //           : Colors.black45),
                                    // ),
                                  ),
                                  const SizedBox(
                                      width: 12),
                                  Text(
                                    _tabs[i].tr,
                                    style:
                                        GoogleFonts
                                            .outfit(
                                      fontSize:
                                          16,
                                      fontWeight: _selectedIndex ==
                                              i
                                          ? FontWeight
                                              .w600
                                          : FontWeight
                                              .w400,
                                      color: _selectedIndex ==
                                              i
                                          ? AppColors
                                              .moroccoRed
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          selectedItemBuilder:
                              (context) {
                            return List.generate(
                                _tabs.length,
                                (i) {
                              return Row(
                                children: [
                                  Icon(
                                    _tabIcons[i],
                                    size: 18,
                                    color: AppColors
                                        .moroccoRed,
                                  ),
                                  const SizedBox(
                                      width: 10),
                                  Text(
                                    _tabs[i].tr,
                                    style:
                                        GoogleFonts
                                            .outfit(
                                      fontSize:
                                          14,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      color: AppColors
                                          .moroccoRed,
                                    ),
                                  ),
                                ],
                              );
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Content
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        // ── Active Rides
                        StreamBuilder<
                            QuerySnapshot>(
                          stream: FirebaseFirestore
                              .instance
                              .collection(
                                  CollectionName
                                      .orders)
                              .where("userId",
                                  isEqualTo:
                                      FireStoreUtils
                                          .getCurrentUid())
                              .where("status",
                                  whereIn: [
                                    Constant
                                        .ridePlaced,
                                    Constant
                                        .rideInProgress,
                                    Constant
                                        .rideComplete,
                                    Constant
                                        .rideActive,
                                    Constant
                                        .rideHoldAccepted,
                                    Constant
                                        .rideHold,
                                  ])
                              .where(
                                  "paymentStatus",
                                  isEqualTo:
                                      false)
                              .orderBy(
                                  "createdDate",
                                  descending:
                                      true)
                              .snapshots(),
                          builder: (BuildContext
                                  context,
                              AsyncSnapshot<
                                      QuerySnapshot>
                                  snapshot) {
                            if (snapshot
                                .hasError) {
                              return Center(
                                  child: Text(
                                      'Something went wrong'
                                          .tr));
                            }
                            if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting) {
                              return Constant.loader(
                                  isDarkTheme:
                                      themeChange
                                          .getThem());
                            }
                            return snapshot.data!
                                    .docs.isEmpty
                                ? Center(
                                    child: Text(
                                        "No active rides found"
                                            .tr),
                                  )
                                : ListView
                                    .builder(
                                        itemCount: snapshot
                                            .data!
                                            .docs
                                            .length,
                                        scrollDirection:
                                            Axis
                                                .vertical,
                                        shrinkWrap:
                                            true,
                                        itemBuilder:
                                            (context,
                                                index) {
                                          OrderModel orderModel = OrderModel.fromJson(snapshot
                                              .data!
                                              .docs[index]
                                              .data() as Map<String, dynamic>);

                                          return InkWell(
                                            onTap:
                                                () {
                                              /*Get.to(const CompleteOrderScreen(),
                                              arguments: {
                                                "orderModel": orderModel,
                                              });*/
                                            },
                                            child:
                                                Padding(
                                              padding:
                                                  const EdgeInsets.all(10),
                                              child:
                                                  Container(
                                                decoration: BoxDecoration(
                                                  color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                                                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                                                  border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : Colors.grey.withOpacity(0.2), width: 1.0),
                                                  boxShadow: themeChange.getThem()
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.04),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      FutureBuilder<DriverUserModel?>(
                                                        future: FireStoreUtils.getDriver(orderModel.driverId.toString()),
                                                        builder: (context, driverSnapshot) {
                                                          DriverUserModel? driver = driverSnapshot.data;
                                                          return Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Wrap(
                                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                          decoration: BoxDecoration(
                                                                            color: AppColors.moroccoGreen.withOpacity(0.12),
                                                                            borderRadius: BorderRadius.circular(20),
                                                                          ),
                                                                          child: Text(
                                                                            orderModel.status.toString().tr,
                                                                            style: GoogleFonts.outfit(
                                                                              color: AppColors.moroccoGreen,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 8),
                                                                        Text(
                                                                          Constant().formatTimestamp(orderModel.createdDate),
                                                                          style: GoogleFonts.outfit(
                                                                            color: themeChange.getThem() ? Colors.white54 : Colors.grey[600],
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    /*const SizedBox(
                                                                    height: 12),
                                                                if (orderModel
                                                                        .status !=
                                                                    Constant
                                                                        .ridePlaced)
                                                                  Text(
                                                                    driver !=
                                                                            null
                                                                        ? driver
                                                                            .fullName
                                                                            .toString()
                                                                        : "Waiting for driver..."
                                                                            .tr,
                                                                    style: GoogleFonts
                                                                        .outfit(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: themeChange.getThem()
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black87,
                                                                    ),
                                                                  )
                                                                else
                                                                  Text(
                                                                    "Looking for drivers..."
                                                                        .tr,
                                                                    style: GoogleFonts
                                                                        .outfit(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: themeChange.getThem()
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black87,
                                                                    ),
                                                                  ),*/
                                                                  ],
                                                                ),
                                                              ),
                                                              if (orderModel.status != Constant.ridePlaced)
                                                                ClipRRect(
                                                                  borderRadius: BorderRadius.circular(10),
                                                                  child: CachedNetworkImage(
                                                                    height: 55,
                                                                    width: 55,
                                                                    imageUrl: driver != null ? driver.profilePic.toString() : Constant.userPlaceHolder,
                                                                    fit: BoxFit.cover,
                                                                    placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                                    errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                                  ),
                                                                ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      LocationView(
                                                        sourceLocation: orderModel.sourceLocationName.toString(),
                                                        destinationLocation: orderModel.destinationLocationName.toString(),
                                                      ),
                                                      const SizedBox(height: 14),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.moroccoGreen.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons.money, size: 16, color: AppColors.moroccoGreen),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  orderModel.status == Constant.ridePlaced ? Constant.amountShow(amount: double.parse(orderModel.offerRate.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)) : Constant.amountShow(amount: double.parse(orderModel.finalRate.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)),
                                                                  style: GoogleFonts.outfit(
                                                                    color: AppColors.moroccoGreen,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 14),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  "${orderModel.distance} ${Constant.distanceType}",
                                                                  style: GoogleFonts.outfit(
                                                                    color: Colors.grey[600],
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      orderModel.someOneElse != null
                                                          ? Container(
                                                              decoration: BoxDecoration(color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                              child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Row(
                                                                          children: [
                                                                            Text(orderModel.someOneElse!.fullName.toString().tr, style: GoogleFonts.poppins()),
                                                                            Text(orderModel.someOneElse!.contactNumber.toString().tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                          onTap: () async {
                                                                            await Share.share(
                                                                              subject: 'Ride Booked'.tr,
                                                                              'Your ride is booked. and you enjoy this ride and here is a otp to conform this ride ${orderModel.otp}'.tr,
                                                                            );
                                                                          },
                                                                          child: const Icon(Icons.share))
                                                                    ],
                                                                  )),
                                                            )
                                                          : const SizedBox(),
                                                      if (orderModel.acceptHoldTime != null && orderModel.status == Constant.rideHoldAccepted)
                                                        HoldTimerWidget(
                                                          acceptHoldTime: orderModel.acceptHoldTime!,
                                                          holdingMinuteCharge: orderModel.service?.prices?.first.holdingMinuteCharge ?? '0.0',
                                                          holdingMinute: orderModel.service?.prices?.first.holdingMinute ?? '0.0',
                                                          orderId: orderModel.id!,
                                                          orderModel: orderModel,
                                                        ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                          child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                    child: orderModel.status == Constant.rideInProgress || orderModel.status == Constant.ridePlaced || orderModel.status == Constant.rideComplete
                                                                        ? Text(orderModel.status.toString())
                                                                        : Row(
                                                                            children: [
                                                                              Text("OTP".tr, style: GoogleFonts.poppins()),
                                                                              Text(" : ${orderModel.otp}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                                                                            ],
                                                                          ),
                                                                  ),
                                                                  Text(Constant().formatTimestamp(orderModel.createdDate), style: GoogleFonts.poppins(fontSize: 12)),
                                                                ],
                                                              )),
                                                        ),
                                                      ),
                                                      Visibility(
                                                          visible: orderModel.status == Constant.ridePlaced,
                                                          child: ButtonThem.buildButton(
                                                            context,
                                                            title: "View Drivers (${orderModel.acceptedDriverId != null ? orderModel.acceptedDriverId!.length.toString() : "0"})".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              Get.to(const OrderDetailsScreen(), arguments: {
                                                                "orderModel": orderModel,
                                                              });
                                                            },
                                                          )),
                                                      Visibility(
                                                          visible: orderModel.status != Constant.ridePlaced,
                                                          child: Theme(
                                                            data: Theme.of(context).copyWith(
                                                              hoverColor: Colors.transparent,
                                                              splashColor: Colors.transparent,
                                                              highlightColor: Colors.transparent,
                                                            ),
                                                            child: PopupMenuButton<int>(
                                                              offset: const Offset(0, 50),
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                              color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                                                              elevation: 4,
                                                              onSelected: (value) async {
                                                                if (value == 1) {
                                                                  // ── Chat Logic
                                                                  UserModel? customer = await FireStoreUtils.getUserProfile(orderModel.userId.toString());
                                                                  DriverUserModel? driver = await FireStoreUtils.getDriver(orderModel.driverId.toString());
                                                                  if (driver != null && customer != null) {
                                                                    Get.to(ChatScreens(
                                                                      driverId: driver.id,
                                                                      customerId: customer.id,
                                                                      customerName: customer.fullName,
                                                                      customerProfileImage: customer.profilePic,
                                                                      driverName: driver.fullName,
                                                                      driverProfileImage: driver.profilePic,
                                                                      orderId: orderModel.id,
                                                                      token: driver.fcmToken,
                                                                    ));
                                                                  }
                                                                } else if (value == 2) {
                                                                  // ── Call Logic
                                                                  DriverUserModel? driver = await FireStoreUtils.getDriver(orderModel.driverId.toString());
                                                                  if (driver != null) {
                                                                    Constant.makePhoneCall("${driver.countryCode}${driver.phoneNumber}");
                                                                  }
                                                                } else if (value == 3) {
                                                                  // ── Map Logic
                                                                  if (Constant.mapType == "inappmap") {
                                                                    if (orderModel.status == Constant.rideActive || orderModel.status == Constant.rideInProgress) {
                                                                      Get.to(const LiveTrackingScreen(), arguments: {
                                                                        "orderModel": orderModel,
                                                                        "type": "orderModel",
                                                                      });
                                                                    }
                                                                  } else {
                                                                    Utils.redirectMap(latitude: orderModel.destinationLocationLAtLng!.latitude!, longLatitude: orderModel.destinationLocationLAtLng!.longitude!, name: orderModel.destinationLocationName.toString());
                                                                  }
                                                                }
                                                              },
                                                              itemBuilder: (context) => [
                                                                PopupMenuItem(
                                                                  value: 1,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(Icons.chat_bubble_outline, color: AppColors.moroccoGreen, size: 20),
                                                                      const SizedBox(width: 12),
                                                                      Text("Chat with Driver".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const PopupMenuDivider(height: 1),
                                                                PopupMenuItem(
                                                                  value: 2,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(Icons.call_outlined, color: AppColors.moroccoGreen, size: 20),
                                                                      const SizedBox(width: 12),
                                                                      Text("Call Driver".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const PopupMenuDivider(height: 1),
                                                                PopupMenuItem(
                                                                  value: 3,
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(Icons.map_outlined, color: AppColors.moroccoGreen, size: 20),
                                                                      const SizedBox(width: 12),
                                                                      Text("Live Map Tracking".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                              child: Container(
                                                                height: 44,
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: AppColors.moroccoGreen,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    const Icon(Icons.phone_in_talk_outlined, color: Colors.white, size: 18),
                                                                    const SizedBox(width: 10),
                                                                    Text(
                                                                      "Contact Driver".tr.toUpperCase(),
                                                                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                                                                    ),
                                                                    const SizedBox(width: 4),
                                                                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                      const SizedBox(height: 10),
                                                      /* Row(
                                                    children: [
                                                      if (orderModel.status ==
                                                              Constant
                                                                  .rideInProgress ||
                                                          orderModel.status ==
                                                              Constant
                                                                  .rideHold ||
                                                          orderModel.status ==
                                                              Constant
                                                                  .rideHoldAccepted)
                                                        Expanded(
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title: "SOS".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              await FireStoreUtils.getSOS(
                                                                      orderModel
                                                                          .id
                                                                          .toString())
                                                                  .then(
                                                                      (value) {
                                                                if (value !=
                                                                    null) {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Your request is ${value.status}");
                                                                } else {
                                                                  SosModel
                                                                      sosModel =
                                                                      SosModel();
                                                                  sosModel.id =
                                                                      Constant
                                                                          .getUuid();
                                                                  sosModel.orderId =
                                                                      orderModel
                                                                          .id;
                                                                  sosModel.status =
                                                                      "Initiated";
                                                                  sosModel.orderType =
                                                                      "city";
                                                                  FireStoreUtils
                                                                      .setSOS(
                                                                          sosModel);
                                                                }
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      if ((orderModel.status ==
                                                                  Constant
                                                                      .rideInProgress ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideHold ||
                                                              orderModel
                                                                      .status ==
                                                                  Constant
                                                                      .rideHoldAccepted) &&
                                                          (orderModel.status ==
                                                                  Constant
                                                                      .rideInProgress &&
                                                              (orderModel.totalHoldingCharges ==
                                                                      null ||
                                                                  orderModel
                                                                          .totalHoldingCharges ==
                                                                      "0.0")))
                                                        const SizedBox(
                                                            width: 10),
                                                      if (orderModel.status ==
                                                              Constant
                                                                  .rideInProgress &&
                                                          (orderModel.totalHoldingCharges ==
                                                                  null ||
                                                              orderModel
                                                                      .totalHoldingCharges ==
                                                                  "0.0"))
                                                        Expanded(
                                                          child: ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title: "HOLD".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Are you sure you want to hold the ride?'
                                                                            .tr),
                                                                    actions: [
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            width: 70,
                                                                            color: Colors.black,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 12.0),
                                                                              child: Text(
                                                                                'No',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(color: Colors.white),
                                                                              ),
                                                                            )),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          ShowToastDialog.showLoader(
                                                                              "Please wait...".tr);
                                                                          orderModel.status =
                                                                              Constant.rideHold;
                                                                          await FireStoreUtils.setOrder(orderModel)
                                                                              .then((value) {
                                                                            if (value ==
                                                                                true) {
                                                                              ShowToastDialog.closeLoader();
                                                                              ShowToastDialog.showToast("Ride on Hold".tr);
                                                                            }
                                                                          });
                                                                          Get.back();
                                                                        },
                                                                        child: Container(
                                                                            height: 40,
                                                                            width: 70,
                                                                            color: Colors.black,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 12.0),
                                                                              child: Text('Yes'.tr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                    ],
                                                  ),*/
                                                      const SizedBox(height: 10),
                                                      Visibility(
                                                          visible: orderModel.status == Constant.rideComplete && (orderModel.paymentStatus == null || orderModel.paymentStatus == false),
                                                          child: ButtonThem.buildButton(
                                                            context,
                                                            title: "Pay".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              Get.to(const PaymentOrderScreen(), arguments: {
                                                                "orderModel": orderModel,
                                                              });
                                                            },
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                          },
                        ),

                        // ── Completed Rides
                        StreamBuilder<
                            QuerySnapshot>(
                          stream: FirebaseFirestore
                              .instance
                              .collection(
                                  CollectionName
                                      .orders)
                              .where("userId",
                                  isEqualTo:
                                      FireStoreUtils
                                          .getCurrentUid())
                              .where("status",
                                  isEqualTo: Constant
                                      .rideComplete)
                              .where(
                                  "paymentStatus",
                                  isEqualTo: true)
                              .orderBy(
                                  "createdDate",
                                  descending:
                                      true)
                              .snapshots(),
                          builder: (BuildContext
                                  context,
                              AsyncSnapshot<
                                      QuerySnapshot>
                                  snapshot) {
                            if (snapshot
                                .hasError) {
                              return Center(
                                  child: Text(
                                      'Something went wrong'
                                          .tr));
                            }
                            if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting) {
                              return Constant.loader(
                                  isDarkTheme:
                                      themeChange
                                          .getThem());
                            }
                            return snapshot.data!
                                    .docs.isEmpty
                                ? Center(
                                    child: Text(
                                        "No completed rides found"
                                            .tr),
                                  )
                                : ListView
                                    .builder(
                                        itemCount: snapshot
                                            .data!
                                            .docs
                                            .length,
                                        scrollDirection:
                                            Axis
                                                .vertical,
                                        shrinkWrap:
                                            true,
                                        itemBuilder:
                                            (context,
                                                index) {
                                          OrderModel orderModel = OrderModel.fromJson(snapshot
                                              .data!
                                              .docs[index]
                                              .data() as Map<String, dynamic>);
                                          return InkWell(
                                            onTap:
                                                () {
                                              /*Get.to(const CompleteOrderScreen(),
                                              arguments: {
                                                "orderModel": orderModel,
                                              });*/
                                            },
                                            child:
                                                Padding(
                                              padding:
                                                  const EdgeInsets.all(10),
                                              child:
                                                  Container(
                                                decoration: BoxDecoration(
                                                  color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                                                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                                                  border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : Colors.grey.withOpacity(0.2), width: 1.0),
                                                  boxShadow: themeChange.getThem()
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.04),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      FutureBuilder<DriverUserModel?>(
                                                        future: FireStoreUtils.getDriver(orderModel.driverId.toString()),
                                                        builder: (context, driverSnapshot) {
                                                          DriverUserModel? driver = driverSnapshot.data;
                                                          return Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Wrap(
                                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                                      children: [
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                          decoration: BoxDecoration(
                                                                            color: AppColors.moroccoGreen.withOpacity(0.12),
                                                                            borderRadius: BorderRadius.circular(20),
                                                                          ),
                                                                          child: Text(
                                                                            orderModel.status.toString().tr,
                                                                            style: GoogleFonts.outfit(
                                                                              color: AppColors.moroccoGreen,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 8),
                                                                        Text(
                                                                          Constant().formatTimestamp(orderModel.createdDate),
                                                                          style: GoogleFonts.outfit(
                                                                            color: themeChange.getThem() ? Colors.white54 : Colors.grey[600],
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(10),
                                                                child: CachedNetworkImage(
                                                                  height: 55,
                                                                  width: 55,
                                                                  imageUrl: driver != null ? driver.profilePic.toString() : Constant.userPlaceHolder,
                                                                  fit: BoxFit.cover,
                                                                  placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                                  errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      LocationView(
                                                        sourceLocation: orderModel.sourceLocationName.toString(),
                                                        destinationLocation: orderModel.destinationLocationName.toString(),
                                                      ),
                                                      const SizedBox(height: 14),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.moroccoGreen.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons.money, size: 16, color: AppColors.moroccoGreen),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  Constant.amountShow(amount: double.parse(orderModel.finalRate.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)),
                                                                  style: GoogleFonts.outfit(
                                                                    color: AppColors.moroccoGreen,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 14),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  "${orderModel.distance} ${Constant.distanceType}",
                                                                  style: GoogleFonts.outfit(
                                                                    color: Colors.grey[600],
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: ButtonThem.buildButton(
                                                            context,
                                                            title: "Review".tr,
                                                            btnHeight: 44,
                                                            onPress: () async {
                                                              /* Get.to(
                                                              const ReviewScreen(),
                                                              arguments: {
                                                                "type":
                                                                    "orderModel",
                                                                "orderModel":
                                                                    orderModel,
                                                              });*/
                                                            },
                                                          )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                          },
                        ),

                        // ── Cancelled Rides
                        StreamBuilder<
                            QuerySnapshot>(
                          stream: FirebaseFirestore
                              .instance
                              .collection(
                                  CollectionName
                                      .orders)
                              .where("userId",
                                  isEqualTo:
                                      FireStoreUtils
                                          .getCurrentUid())
                              .where("status",
                                  isEqualTo: Constant
                                      .rideCanceled)
                              .orderBy(
                                  "createdDate",
                                  descending:
                                      true)
                              .snapshots(),
                          builder: (BuildContext
                                  context,
                              AsyncSnapshot<
                                      QuerySnapshot>
                                  snapshot) {
                            if (snapshot
                                .hasError) {
                              return Center(
                                  child: Text(
                                      'Something went wrong'
                                          .tr));
                            }
                            if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting) {
                              return Constant.loader(
                                  isDarkTheme:
                                      themeChange
                                          .getThem());
                            }
                            return snapshot.data!
                                    .docs.isEmpty
                                ? Center(
                                    child: Text(
                                        "No cancelled rides found"
                                            .tr),
                                  )
                                : ListView
                                    .builder(
                                        itemCount: snapshot
                                            .data!
                                            .docs
                                            .length,
                                        scrollDirection:
                                            Axis
                                                .vertical,
                                        shrinkWrap:
                                            true,
                                        itemBuilder:
                                            (context,
                                                index) {
                                          OrderModel orderModel = OrderModel.fromJson(snapshot
                                              .data!
                                              .docs[index]
                                              .data() as Map<String, dynamic>);
                                          return Padding(
                                            padding: const EdgeInsets
                                                .all(
                                                10),
                                            child:
                                                Container(
                                              decoration:
                                                  BoxDecoration(
                                                color: themeChange.getThem() ? AppColors.darkContainerBackground : Colors.white,
                                                borderRadius: const BorderRadius.all(Radius.circular(14)),
                                                border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : Colors.grey.withOpacity(0.2), width: 1.0),
                                                boxShadow: themeChange.getThem()
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.04),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 4),
                                                        ),
                                                      ],
                                              ),
                                              child:
                                                  Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Wrap(
                                                            crossAxisAlignment: WrapCrossAlignment.center,
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: AppColors.moroccoRed.withOpacity(0.12),
                                                                  borderRadius: BorderRadius.circular(20),
                                                                ),
                                                                child: Text(
                                                                  orderModel.status.toString().tr,
                                                                  style: GoogleFonts.outfit(
                                                                    color: AppColors.moroccoRed,
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Text(
                                                                Constant().formatTimestamp(orderModel.createdDate),
                                                                style: GoogleFonts.outfit(
                                                                  color: themeChange.getThem() ? Colors.white54 : Colors.grey[600],
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    LocationView(
                                                      sourceLocation: orderModel.sourceLocationName.toString(),
                                                      destinationLocation: orderModel.destinationLocationName.toString(),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.moroccoGreen.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const Icon(Icons.money, size: 16, color: AppColors.moroccoGreen),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                Constant.amountShow(amount: double.parse(orderModel.offerRate.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)),
                                                                style: GoogleFonts.outfit(
                                                                  color: AppColors.moroccoGreen,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(width: 14),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                "${orderModel.distance} ${Constant.distanceType}",
                                                                style: GoogleFonts.outfit(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

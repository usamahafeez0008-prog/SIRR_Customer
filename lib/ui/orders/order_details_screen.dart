import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/controller/order_details_controller.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order/driverId_accept_reject.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/location_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<OrderDetailsController>(
        init: OrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            appBar: AppBar(
              backgroundColor: AppColors.moroccoRed,
              title: Text("Ride Details".tr),
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  )),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.width(6, context),
                  width: Responsive.width(100, context),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection(CollectionName.orders)
                            .doc(controller.orderModel.value.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Something went wrong'.tr));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Constant.loader(
                                isDarkTheme: themeChange.getThem());
                          }

                          OrderModel orderModel =
                              OrderModel.fromJson(snapshot.data!.data()!);
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.moroccoGreen
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                            Constant().formatTimestamp(
                                                orderModel.createdDate),
                                            style: GoogleFonts.outfit(
                                              color: themeChange.getThem()
                                                  ? Colors.white54
                                                  : Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      LocationView(
                                        sourceLocation: orderModel
                                            .sourceLocationName
                                            .toString(),
                                        destinationLocation: orderModel
                                            .destinationLocationName
                                            .toString(),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.moroccoGreen
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.money,
                                                    size: 16,
                                                    color:
                                                        AppColors.moroccoGreen),
                                                const SizedBox(width: 4),
                                                Text(
                                                  orderModel.status ==
                                                          Constant.ridePlaced
                                                      ? Constant.amountShow(
                                                          amount: double.parse(orderModel.offerRate.toString())
                                                              .toStringAsFixed(Constant
                                                                  .currencyModel!
                                                                  .decimalDigits!))
                                                      : Constant.amountShow(
                                                          amount: double.parse(
                                                                  orderModel
                                                                      .finalRate
                                                                      .toString())
                                                              .toStringAsFixed(Constant
                                                                  .currencyModel!
                                                                  .decimalDigits!)),
                                                  style: GoogleFonts.outfit(
                                                    color:
                                                        AppColors.moroccoGreen,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.straighten,
                                                    size: 16,
                                                    color: Colors.grey[600]),
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      /*Container(
                                        decoration:
                                            BoxDecoration(color: themeChange.getThem() ? AppColors.darkContainerBorder : Colors.white, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text("OTP".tr, style: GoogleFonts.outfit()),
                                                      Text(" : ${orderModel.otp}", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                ),
                                                Text(Constant().formatTimestamp(orderModel.createdDate), style: GoogleFonts.outfit()),
                                              ],
                                            )),
                                      ),*/
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      ButtonThem.buildButton(
                                        context,
                                        title: "Cancel".tr,
                                        btnHeight: 44,
                                        onPress: () async {
                                          List<dynamic> acceptDriverId = [];

                                          orderModel.status =
                                              Constant.rideCanceled;
                                          orderModel.acceptedDriverId =
                                              acceptDriverId;
                                          await FireStoreUtils.setOrder(
                                                  orderModel)
                                              .then((value) {
                                            Get.back();
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                orderModel.acceptedDriverId == null ||
                                        orderModel.acceptedDriverId!.isEmpty
                                    ? Center(
                                        child: Text("No driver Found".tr),
                                      )
                                    : Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        padding: const EdgeInsets.only(top: 10),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: orderModel
                                              .acceptedDriverId!.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return FutureBuilder<
                                                    DriverUserModel?>(
                                                future: FireStoreUtils
                                                    .getDriver(orderModel
                                                            .acceptedDriverId![
                                                        index]),
                                                builder: (context, snapshot) {
                                                  switch (snapshot
                                                      .connectionState) {
                                                    case ConnectionState
                                                          .waiting:
                                                      return Constant.loader(
                                                          isDarkTheme:
                                                              themeChange
                                                                  .getThem());
                                                    case ConnectionState.done:
                                                      if (snapshot.hasError) {
                                                        return Text(snapshot
                                                            .error
                                                            .toString());
                                                      } else {
                                                        DriverUserModel
                                                            driverModel =
                                                            snapshot.data!;
                                                        return FutureBuilder<
                                                                DriverIdAcceptReject?>(
                                                            future: FireStoreUtils
                                                                .getAcceptedOrders(
                                                                    orderModel
                                                                        .id
                                                                        .toString(),
                                                                    driverModel
                                                                        .id
                                                                        .toString()),
                                                            builder: (context,
                                                                snapshot) {
                                                              switch (snapshot
                                                                  .connectionState) {
                                                                case ConnectionState
                                                                      .waiting:
                                                                  return Constant.loader(
                                                                      isDarkTheme:
                                                                          themeChange
                                                                              .getThem());
                                                                case ConnectionState
                                                                      .done:
                                                                  if (snapshot
                                                                      .hasError) {
                                                                    return Text(
                                                                        snapshot
                                                                            .error
                                                                            .toString());
                                                                  } else {
                                                                    DriverIdAcceptReject
                                                                        driverIdAcceptReject =
                                                                        snapshot
                                                                            .data!;
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              14,
                                                                          vertical:
                                                                              10),
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: Colors.black,
                                                                              width: 1.5),
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .background,
                                                                          borderRadius: const BorderRadius
                                                                              .all(
                                                                              Radius.circular(20)),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.05),
                                                                              blurRadius: 10,
                                                                              offset: const Offset(0, 4),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(16.0),
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Container(
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                      border: Border.all(color: AppColors.moroccoGreen.withOpacity(0.2), width: 1),
                                                                                    ),
                                                                                    child: CircleAvatar(
                                                                                      radius: 28,
                                                                                      backgroundColor: Colors.grey[200],
                                                                                      backgroundImage: NetworkImage(driverModel.profilePic!.isNotEmpty ? driverModel.profilePic! : Constant.userPlaceHolder),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 12),
                                                                                  Expanded(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Text(
                                                                                              driverModel.fullName.toString(),
                                                                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                                                                            ),
                                                                                            if (driverModel.documentVerification == true) ...[
                                                                                              const SizedBox(width: 4),
                                                                                              const Icon(Icons.verified, color: Colors.blue, size: 16),
                                                                                            ],
                                                                                          ],
                                                                                        ),
                                                                                        /* Text(
                                                                                          Constant.localizationTitle(driverModel.serviceName),
                                                                                          style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 13),
                                                                                        ),*/
                                                                                        const SizedBox(height: 4),
                                                                                        Row(
                                                                                          children: [
                                                                                            const Icon(Icons.star, color: AppColors.ratingColour, size: 14),
                                                                                            const SizedBox(width: 4),
                                                                                            Text(
                                                                                              Constant.calculateReview(reviewCount: driverModel.reviewsCount.toString(), reviewSum: driverModel.reviewsSum.toString()),
                                                                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                                                                                            ),
                                                                                            const SizedBox(width: 8),
                                                                                            Text(
                                                                                              "Top Driver".tr,
                                                                                              style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    children: [
                                                                                      Text(
                                                                                        Constant.amountShow(amount: driverIdAcceptReject.offerAmount),
                                                                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                                                                                      ),
                                                                                      if (driverIdAcceptReject.suggestedTime != null) ...[
                                                                                        const SizedBox(height: 6),
                                                                                        Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.blue.withOpacity(0.1),
                                                                                            borderRadius: BorderRadius.circular(20),
                                                                                          ),
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              const Icon(Icons.access_time_outlined, size: 12, color: AppColors.moroccoGreen),
                                                                                              const SizedBox(width: 4),
                                                                                              Text(
                                                                                                "${driverIdAcceptReject.suggestedTime} min",
                                                                                                style: GoogleFonts.outfit(color: AppColors.moroccoGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 10),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  if (orderModel.service?.image != null)

                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        _vehicleInfoItem(Icons.directions_car_outlined, Constant.localizationTitle(driverModel.serviceName)),
                                                                                        const SizedBox(height: 4),
                                                                                        _vehicleInfoItem(Icons.color_lens_outlined, driverModel.vehicleInformation!.vehicleColor.toString()),
                                                                                        const SizedBox(height: 4),
                                                                                        _vehicleInfoItem(Icons.badge_outlined, driverModel.vehicleInformation!.vehicleNumber.toString()),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: CachedNetworkImage(
                                                                                      imageUrl: orderModel.service!.image.toString(),
                                                                                      height: 80,
                                                                                      fit: BoxFit.contain,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const Padding(
                                                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                                                              child: Divider(height: 24),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Icon(Icons.near_me_outlined, size: 14, color: Colors.black),
                                                                                      const SizedBox(width: 4),
                                                                                      Text(
                                                                                        "${orderModel.distance} ${Constant.distanceType} away",
                                                                                        style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  // Text(
                                                                                  //   "RECOMMANDE".tr.toUpperCase(),
                                                                                  //   style: GoogleFonts.outfit(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10),
                                                                                  // ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(16.0),
                                                                              child: Column(
                                                                                children: [
                                                                                  ButtonThem.buildButton(
                                                                                    context,
                                                                                    title: "Confirm ${driverModel.fullName} ->",
                                                                                    btnHeight: 50,

                                                                                    onPress: () async {
                                                                                      controller.orderModel.value.acceptedDriverId = [];
                                                                                      controller.orderModel.value.driverId = driverIdAcceptReject.driverId.toString();
                                                                                      controller.orderModel.value.status = Constant.rideActive;
                                                                                      controller.orderModel.value.finalRate = driverIdAcceptReject.offerAmount;
                                                                                      controller.orderModel.value.vehicleInformation = driverModel.vehicleInformation;
                                                                                      if (driverModel.ownerId != null) {
                                                                                        controller.orderModel.value.ownerId = driverModel.ownerId;
                                                                                      }
                                                                                      await FireStoreUtils.setOrder(controller.orderModel.value);
                                                                                      await SendNotification.sendOneNotification(token: driverModel.fcmToken.toString(), title: 'Ride Confirmed'.tr, body: 'Your ride request has been accepted by the passenger. Please proceed to the pickup location.'.tr, payload: {});
                                                                                      Get.back();
                                                                                    },
                                                                                  ),
                                                                                  const SizedBox(height: 8),
                                                                                  TextButton(
                                                                                    onPressed: () async {
                                                                                      List<dynamic> rejectDriverId = controller.orderModel.value.rejectedDriverId ?? [];
                                                                                      rejectDriverId.add(driverModel.id);
                                                                                      List<dynamic> acceptDriverId = controller.orderModel.value.acceptedDriverId ?? [];
                                                                                      acceptDriverId.remove(driverModel.id);
                                                                                      controller.orderModel.value.rejectedDriverId = rejectDriverId;
                                                                                      controller.orderModel.value.acceptedDriverId = acceptDriverId;
                                                                                      await SendNotification.sendOneNotification(token: driverModel.fcmToken.toString(), title: 'Ride Canceled'.tr, body: 'The passenger has canceled the ride.'.tr, payload: {});
                                                                                      await FireStoreUtils.setOrder(controller.orderModel.value);
                                                                                    },
                                                                                    child: Text(
                                                                                      "Reject Bid".tr,
                                                                                      style: GoogleFonts.outfit(color: Colors.red[400], fontWeight: FontWeight.w600),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                default:
                                                                  return Text(
                                                                      'Error'
                                                                          .tr);
                                                              }
                                                            });
                                                      }
                                                    default:
                                                      return Text('Error'.tr);
                                                  }
                                                });
                                          },
                                        ),
                                      )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _vehicleInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.moroccoGreen),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.outfit(
              color: AppColors.moroccoRed,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

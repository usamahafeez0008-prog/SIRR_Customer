import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/payment_order_controller.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/model/wallet_transaction_model.dart';
import 'package:customer/payment/createRazorPayOrderModel.dart';
import 'package:customer/payment/rozorpayConroller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/coupon_screen/coupon_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/widget/driver_view.dart';
import 'package:customer/widget/location_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../themes/button_them.dart';

class PaymentOrderScreen extends StatelessWidget {
  const PaymentOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return GetX<PaymentOrderController>(
        init: PaymentOrderController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Ride Details".tr,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : Colors.black, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            body: controller.isLoading.value
                ? Center(child: Constant.loader(isDarkTheme: isDark))
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                          ),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection(CollectionName.orders)
                                  .doc(controller.orderModel.value.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError)
                                  return Center(
                                      child: Text('Something went wrong'.tr));
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return Constant.loader(isDarkTheme: isDark);

                                OrderModel orderModel =
                                    OrderModel.fromJson(snapshot.data!.data()!);

                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── Driver Info Section
                                        DriverView(
                                            driverId: controller
                                                .orderModel.value.driverId
                                                .toString()),
                                        const SizedBox(height: 20),

                                        // ── Vehicle Details Section
                                        FutureBuilder<DriverUserModel?>(
                                            future: FireStoreUtils.getDriver(
                                                controller
                                                    .orderModel.value.driverId
                                                    .toString()),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData)
                                                return const SizedBox.shrink();
                                              DriverUserModel driverModel =
                                                  snapshot.data!;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("Vehicle Details".tr,
                                                      style: GoogleFonts.outfit(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16)),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? AppColors
                                                              .darkContainerBackground
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: isDark
                                                              ? AppColors
                                                                  .darkContainerBorder
                                                              : AppColors
                                                                  .containerBorder,
                                                          width: 0.8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                    0, 4)),
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        _buildVehicleInfo(
                                                            context,
                                                            'assets/icons/ic_car.svg',
                                                            Constant.localizationTitle(
                                                                driverModel
                                                                    .serviceName),
                                                            isDark),
                                                        _buildVehicleInfo(
                                                            context,
                                                            'assets/icons/ic_color.svg',
                                                            driverModel
                                                                .vehicleInformation!
                                                                .vehicleColor
                                                                .toString(),
                                                            isDark),
                                                        _buildVehicleInfoImage(
                                                            context,
                                                            'assets/icons/ic_number.png',
                                                            driverModel
                                                                .vehicleInformation!
                                                                .vehicleNumber
                                                                .toString(),
                                                            isDark),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),

                                        const SizedBox(height: 24),

                                        // ── Locations Section
                                        Text("Trip Route".tr,
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16)),
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors
                                                    .darkContainerBackground
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: isDark
                                                    ? AppColors
                                                        .darkContainerBorder
                                                    : AppColors.containerBorder,
                                                width: 0.8),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4)),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: LocationView(
                                            sourceLocation: controller
                                                .orderModel
                                                .value
                                                .sourceLocationName
                                                .toString(),
                                            destinationLocation: controller
                                                .orderModel
                                                .value
                                                .destinationLocationName
                                                .toString(),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // ── Booking Summary Card
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors
                                                    .darkContainerBackground
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: isDark
                                                    ? AppColors
                                                        .darkContainerBorder
                                                    : AppColors.containerBorder,
                                                width: 0.8),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4)),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text("Booking summary".tr,
                                                      style: GoogleFonts.outfit(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16)),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .moroccoGreen
                                                            .withOpacity(0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    child: Text(
                                                      controller.orderModel
                                                          .value.paymentType
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: GoogleFonts.outfit(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .moroccoGreen),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 12),
                                                  child: Divider(height: 1)),
                                              _buildSummaryRow(
                                                  "Ride Amount".tr,
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .amount.value
                                                          .toString())),
                                              _buildSummaryRow(
                                                  "Minute charge".tr,
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .totalChargeOfMinute
                                                          .value
                                                          .toString())),
                                              _buildSummaryRow(
                                                  "Base Fare".tr,
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .basicFareCharge.value
                                                          .toString())),
                                              _buildSummaryRow(
                                                  "Holding Charge".tr,
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .holdingCharge.value
                                                          .toString())),
                                              if (controller.orderModel.value
                                                      .taxList !=
                                                  null)
                                                ...controller
                                                    .orderModel.value.taxList!
                                                    .map((tax) => _buildSummaryRow(
                                                        "${tax.title} (${tax.type == "fix" ? Constant.amountShow(amount: tax.tax) : "${tax.tax}%"})",
                                                        Constant.amountShow(
                                                            amount: Constant()
                                                                .calculateTax(
                                                                    amount: (controller.subTotal.value -
                                                                            double.parse(controller
                                                                                .couponAmount.value))
                                                                        .toString(),
                                                                    taxModel:
                                                                        tax)
                                                                .toString()))),
                                              _buildSummaryRow("Discount".tr,
                                                  "-${Constant.amountShow(amount: controller.couponAmount.value)}",
                                                  isDiscount: true),
                                              const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8),
                                                  child: Divider(
                                                      height: 1, thickness: 1)),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Total Payable".tr,
                                                        style:
                                                            GoogleFonts.outfit(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17)),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: controller
                                                              .total
                                                              .toString()),
                                                      style: GoogleFonts.outfit(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: AppColors
                                                              .moroccoRed),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // ── Pay Button
                                        ButtonThem.buildButton(
                                          context,
                                          title: "Confirm Payment".tr,
                                          onPress: () => paymentMethodDialog(
                                              context, controller, orderModel),
                                        ),
                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }

  Widget _buildVehicleInfo(
      BuildContext context, String iconPath, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(iconPath,
            width: 22, color: isDark ? Colors.white70 : Colors.black87),
        const SizedBox(height: 6),
        Text(label,
            style:
                GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildVehicleInfoImage(
      BuildContext context, String iconPath, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(iconPath,
            width: 22, color: isDark ? Colors.white70 : Colors.black87),
        const SizedBox(height: 6),
        Text(label,
            style:
                GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSummaryRow(String title, String value,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  color: AppColors.subTitleColor, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  paymentMethodDialog(BuildContext context, PaymentOrderController controller,
      OrderModel orderModel) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.arrow_back_ios)),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Select Payment Method".tr,
                              style: GoogleFonts.poppins(),
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.cash!.enable ==
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
                                                    .cash!.name
                                                    .toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller
                                                              .selectedPaymentMethod
                                                              .value ==
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .cash!
                                                              .name
                                                              .toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors
                                                              .moroccoGreen
                                                          : AppColors
                                                              .moroccoGreen
                                                      : AppColors
                                                          .textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    //decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Icon(Icons.money,
                                                          color: AppColors
                                                              .moroccoRed),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel
                                                          .value.cash!.name
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller
                                                        .paymentModel
                                                        .value
                                                        .cash!
                                                        .name
                                                        .toString(),
                                                    groupValue: controller
                                                        .selectedPaymentMethod
                                                        .value,
                                                    activeColor: themeChange
                                                            .getThem()
                                                        ? AppColors.moroccoRed
                                                        : AppColors.moroccoRed,
                                                    onChanged: (value) {
                                                      controller
                                                              .selectedPaymentMethod
                                                              .value =
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .cash!
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
                                /*Visibility(
                                  visible: controller.paymentModel.value.wallet!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.wallet!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SvgPicture.asset('assets/icons/ic_wallet.svg', color: AppColors.lightprimary),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.wallet!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Text("(${Constant.amountShow(amount: controller.userModel.value.walletAmount.toString())})",
                                                      style: GoogleFonts.poppins(color: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary)),
                                                  Radio(
                                                    value: controller.paymentModel.value.wallet!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
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
                                  visible: controller.paymentModel.value.strip!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/images/stripe.png'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.strip!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.strip!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
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
                                  visible: controller.paymentModel.value.paypal!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paypal.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paypal!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paypal!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.payStack!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paystack.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payStack!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payStack!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.mercadoPago!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/mercadopago.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.mercadoPago!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.mercadoPago!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.flutterWave!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/flutterwave.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.flutterWave!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.flutterWave!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.payfast!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payfast!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payfast!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.paytm!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paytam.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paytm!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paytm!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
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
                                Visibility(
                                  visible: controller.paymentModel.value.razorpay!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/razorpay.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.razorpay!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.razorpay!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
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
                                controller.paymentModel.value.midtrans != null && controller.paymentModel.value.midtrans!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/midtrans.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.midtrans!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.midtrans!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.xendit != null && controller.paymentModel.value.xendit!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/xendit.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.xendit!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.xendit!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.orangePay != null && controller.paymentModel.value.orangePay!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/orange_money.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.orangePay!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.orangePay!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),*/
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
                        title: "Pay".tr,
                        onPress: () async {
                          Get.back();
                          if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.strip!.name) {
                            controller.stripeMakePayment(
                                amount: controller.total.value.toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paypal!.name) {
                            controller.paypalPaymentSheet(
                                controller.total.value.toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!),
                                context1);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payStack!.name) {
                            controller.payStackPayment(controller.total.value
                                .toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.mercadoPago!.name) {
                            controller.mercadoPagoMakePayment(
                                context: context,
                                amount: controller.total.value.toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.flutterWave!.name) {
                            controller.flutterWaveInitiatePayment(
                                context: context,
                                amount: controller.total.value.toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payfast!.name) {
                            controller.payFastPayment(
                                context: context,
                                amount: controller.total.value.toStringAsFixed(
                                    Constant.currencyModel!.decimalDigits!));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paytm!.name) {
                            controller.getPaytmCheckSum(context,
                                amount: controller.total.value);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.razorpay!.name) {
                            RazorPayController()
                                .createOrderRazorPay(
                                    amount: controller.total.value.toInt(),
                                    razorpayModel:
                                        controller.paymentModel.value.razorpay)
                                .then((value) {
                              if (value == null) {
                                Get.back();
                                ShowToastDialog.showToast(
                                    "Something went wrong, please contact admin."
                                        .tr);
                              } else {
                                CreateRazorPayOrderModel result = value;
                                controller.openCheckout(
                                    amount: controller.total.value.toInt(),
                                    orderId: result.id);
                              }
                            });
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.wallet!.name) {
                            if (double.parse(controller
                                    .userModel.value.walletAmount
                                    .toString()) >=
                                controller.total.value) {
                              WalletTransactionModel transactionModel =
                                  WalletTransactionModel(
                                      id: Constant.getUuid(),
                                      amount:
                                          "-${controller.total.value.toString()}",
                                      createdDate: Timestamp.now(),
                                      paymentType: controller
                                          .selectedPaymentMethod.value,
                                      transactionId: orderModel.id,
                                      note: "Ride amount debit".tr,
                                      orderType: "city",
                                      userType: "customer",
                                      userId: FireStoreUtils.getCurrentUid());

                              await FireStoreUtils.setWalletTransaction(
                                      transactionModel)
                                  .then((value) async {
                                if (value == true) {
                                  await FireStoreUtils.updateUserWallet(
                                          amount:
                                              "-${controller.total.value.toString()}")
                                      .then((value) {
                                    Get.back();
                                    controller.completeOrder();
                                  });
                                }
                              });
                            } else {
                              ShowToastDialog.showToast(
                                  "Wallet Amount Insufficient".tr);
                            }
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.midtrans!.name) {
                            controller.midtransMakePayment(
                                context: context,
                                amount: controller.total.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.orangePay!.name) {
                            controller.orangeMakePayment(
                                context: context,
                                amount: controller.total.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.xendit!.name) {
                            controller.xenditPayment(
                                context, controller.total.value);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.cash!.name) {
                            controller.completeCashOrder();
                          }
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}

import 'package:customer/constant/constant.dart';
import 'package:customer/controller/live_tracking_controller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LiveTrackingController>(
      init: LiveTrackingController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: AppColors.lightprimary,
            title: Text(controller.title.value.tr),
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back,
                )),
          ),
          body: controller.isLoading.value == true
              ? Constant.loader(isDarkTheme: themeChange.getThem())
              : Stack(
                  children: [
                    Obx(
                      () => GoogleMap(
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        polylines: Set<Polyline>.of(controller.polyLines.values),
                        padding: const EdgeInsets.only(
                          top: 22.0,
                          bottom: 110,
                        ),
                        markers: Set<Marker>.of(controller.markers.values),
                        onMapCreated: (GoogleMapController mapController) {
                          controller.mapController = mapController;
                        },
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: LatLng(
                              Constant.currentLocation != null ? Constant.currentLocation!.latitude : 45.521563,
                              Constant.currentLocation != null ? Constant.currentLocation!.longitude : -122.677433),
                        ),
                      ),
                    ),
                    Obx(() {
                      bool isRideActive = controller.orderModel.value.status == Constant.rideActive || controller.intercityOrderModel.value.status == Constant.rideActive;
                      bool isRideInProgress = controller.orderModel.value.status == Constant.rideInProgress || controller.intercityOrderModel.value.status == Constant.rideInProgress;

                      if (isRideActive || isRideInProgress) {
                        return Positioned(
                          bottom: 30,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.moroccoRed.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(isRideActive ? Icons.directions_car : Icons.location_on, color: AppColors.moroccoRed),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isRideActive ? "Driver is arriving".tr : "Heading to destination".tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        isRideActive ? "${controller.distance.value.isEmpty ? '...' : controller.distance.value} KM away".tr : "${controller.distance.value.isEmpty ? '...' : controller.distance.value} KM left".tr,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${controller.distance.value.isEmpty ? '...' : controller.distance.value} KM",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.moroccoRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
        );
      },
    );
  }
}

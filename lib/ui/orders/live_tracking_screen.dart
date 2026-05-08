import 'package:customer/constant/constant.dart';
import 'package:customer/controller/live_tracking_controller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  Future<void> _openGoogleMapsDirections({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

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

                          // Force refresh once map is ready
                          controller.refreshTrackingNow();

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
                          bottom: 45,
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

                    // Small floating button: open Google Maps directions.
                    Positioned(
                      right: 16,
                      bottom: 130,
                      child: Obx(() {
                        final driverLoc = controller.driverUserModel.value.location;
                        final double? fromLat = driverLoc?.latitude;
                        final double? fromLng = driverLoc?.longitude;

                        final bool isInProgress = controller.orderModel.value.status == Constant.rideInProgress ||
                            controller.intercityOrderModel.value.status == Constant.rideInProgress;

                        final target = isInProgress
                            ? (controller.type.value == "orderModel"
                                ? controller.orderModel.value.destinationLocationLAtLng
                                : controller.intercityOrderModel.value.destinationLocationLAtLng)
                            : (controller.type.value == "orderModel"
                                ? controller.orderModel.value.sourceLocationLAtLng
                                : controller.intercityOrderModel.value.sourceLocationLAtLng);

                        final double? toLat = target?.latitude;
                        final double? toLng = target?.longitude;

                        final bool canOpen = fromLat != null && fromLng != null && toLat != null && toLng != null;

                        return FloatingActionButton.small(
                          heroTag: 'openGoogleMapsFab',
                          backgroundColor: Colors.white,
                          elevation: 3,
                          onPressed: canOpen
                              ? () => _openGoogleMapsDirections(
                                    fromLat: fromLat,
                                    fromLng: fromLng,
                                    toLat: toLat,
                                    toLng: toLng,
                                  )
                              : null,
                          child: Opacity(
                            opacity: canOpen ? 1 : 0.4,
                            child: Image.asset(
                              'assets/icons/google_map_icon.png',
                              width: 22,
                              height: 22,
                            ),
                          ),
                          // Old icons (kept for reference)
                          // child: SvgPicture.asset(
                          //   'assets/icons/ic_google_maps_pin.svg',
                          //   width: 22,
                          //   height: 22,
                          // ),
                          // child: Image.asset(
                          //   'assets/icons/ic_google.png',
                          //   width: 20,
                          //   height: 20,
                          //   color: canOpen ? null : Colors.grey,
                          // ),
                        );
                      }),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

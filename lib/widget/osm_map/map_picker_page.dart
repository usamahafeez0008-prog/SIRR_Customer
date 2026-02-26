import 'dart:io';

import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/widget/osm_map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.pickedPlace.value?.coordinates ??
                    LatLng(20.5937, 78.9629), // Default India center
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  controller.addLatLngOnly(latlng);
                  controller.mapController
                      .move(latlng, controller.mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: Platform.isAndroid
                      ? 'com.codesteem.customer'
                      : 'com.codesteem.customer',
                ),
                MarkerLayer(
                  markers: controller.pickedPlace.value != null
                      ? [
                          Marker(
                              point: controller.pickedPlace.value!.coordinates,
                              width: 60,
                              height: 60,
                              child: SvgPicture.asset(
                                'assets/icons/ic_destination.svg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.moroccoRed, BlendMode.srcIn),
                              )),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.moroccoRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          cursorColor: AppColors.moroccoRed,
                          style: GoogleFonts.outfit(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Search location...'.tr,
                            hintStyle: GoogleFonts.outfit(color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.moroccoRed),
                          ),
                          onChanged: controller.searchPlace,
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.searchResults.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final place = controller.searchResults[index];
                        return ListTile(
                          title: Text(
                            place['display_name'],
                            style: GoogleFonts.outfit(fontSize: 14),
                          ),
                          leading: const Icon(Icons.location_on_outlined,
                              color: AppColors.moroccoRed),
                          onTap: () {
                            controller.selectSearchResult(place);
                            final lat = double.parse(place['lat']);
                            final lon = double.parse(place['lon']);
                            final pos = LatLng(lat, lon);
                            controller.mapController.move(pos, 15);
                            searchController.text = place['display_name'];
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.moroccoRed, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    controller.pickedPlace.value != null
                        ? "Picked Location:".tr
                        : "No Location Picked".tr,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (controller.pickedPlace.value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    controller.pickedPlace.value!.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ButtonThem.roundButton(
                      context,
                      title: "Confirm Location".tr,
                      btnColor: AppColors.moroccoRed,
                      txtColor: Colors.white,
                      btnWidthRatio: 1.0,
                      onPress: () async {
                        final selected = controller.pickedPlace.value;
                        if (selected != null) {
                          Get.back(result: selected);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: controller.clearAll,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

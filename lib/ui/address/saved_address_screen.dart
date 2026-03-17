import 'package:customer/controller/saved_address_controller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedAddressScreen extends StatelessWidget {
  const SavedAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SavedAddressController>(
      init: SavedAddressController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.moroccoBackground,
      /*    appBar: AppBar(
            backgroundColor: AppColors.moroccoBackground,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.moroccoRed),
            ),
            title: Text(
              "Saved Addresses".tr,
              style: GoogleFonts.outfit(
                color: AppColors.moroccoRed,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),*/
          body: controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.moroccoRed,
                  ),
                )
              : controller.addressList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "No saved addresses found".tr,
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.addressList.length,
                      itemBuilder: (context, index) {
                        final address = controller.addressList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.moroccoRed.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on, color: AppColors.moroccoRed),
                            ),
                            title: Text(
                              address.city ?? "Location",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.moroccoText,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                address.address ?? "",
                                style: GoogleFonts.outfit(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                _showDeleteDialog(context, controller, address.id!);
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, SavedAddressController controller, String addressId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Delete Address".tr,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.moroccoRed),
          ),
          content: Text(
            "Are you sure you want to delete this address?".tr,
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel".tr,
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.deleteAddress(addressId);
              },
              child: Text(
                "Delete".tr,
                style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

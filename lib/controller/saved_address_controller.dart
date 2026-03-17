import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/address_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class SavedAddressController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<AddressModel> addressList = <AddressModel>[].obs;

  @override
  void onInit() {
    getSavedAddresses();
    super.onInit();
  }

  Future<void> getSavedAddresses() async {
    try {
      isLoading.value = true;
      String userId = FireStoreUtils.getCurrentUid();
      
      await FirebaseFirestore.instance
          .collection(CollectionName.savedAddresses)
          .doc(userId)
          .collection('addresses')
          .orderBy('timestamp', descending: true)
          .get()
          .then((snapshot) {
        addressList.value = snapshot.docs
            .map((doc) => AddressModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      ShowToastDialog.showToast("Error fetching addresses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      ShowToastDialog.showLoader("Deleting Address...");
      String userId = FireStoreUtils.getCurrentUid();
      
      await FirebaseFirestore.instance
          .collection(CollectionName.savedAddresses)
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete()
          .then((value) {
        addressList.removeWhere((element) => element.id == addressId);
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Address deleted successfully");
        
        // If address list becomes empty, we should ideally mark addressSave as false in parent doc
        if (addressList.isEmpty) {
          FirebaseFirestore.instance
              .collection(CollectionName.savedAddresses)
              .doc(userId)
              .update({'addressSave': false});
        }
      });
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Failed to delete address: $e");
    }
  }
}

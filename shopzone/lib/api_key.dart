
class API {
  //! web server
  static const hostConnect =
      "https://nithish.atozasindia.in/shop_zone_combination_api/";
  //!------------------------------USER API CONNECTIONS --------------------------------

  static const userFolder = "$hostConnect/user"; //! to select the user folder
  //
  static const hostConnectUser =
      "$userFolder/normalUser"; //! to select the normalUser folder inside user folder
  static const validateEmail = "$hostConnectUser/validation_email.php";
  static const register = "$hostConnectUser/register.php";
  static const profileImage = "$userFolder/uploadImage.php";
  static const login = "$hostConnectUser/login.php";
  static const userImage = "$userFolder/";

  static const sellerNameBrand =
      "$hostConnectUser/fetchSeller.php"; // fetch the seller name
  static const sellerBrandView =
      "$hostConnectUser/sellerBrandView.php"; //get seller Brand
  static const userSellerBrandItemView =
      "$hostConnectUser/userItemView.php"; //get seller Brand items
  static const addToCart = "$hostConnectUser/addToCart.php"; // add To Cart
  static const cartView = "$hostConnectUser/cartView.php"; // add To Cart
  static const deleteItemFromCart =
      "$hostConnectUser/deleteItemFromCart.php"; // delete Item From Cart
  static const fetchAddress = "$hostConnectUser/address.php"; // address
  static const addNewAddress =
      "$hostConnectUser/addNewAddress.php"; // add New Address
  static const deleteAddress =
      "$hostConnectUser/delete_address.php"; //delete address
  static const saveOrder = "$hostConnectUser/saveOrder.php"; // save Order
  static const getUserOrders =
      "$hostConnectUser/getUserOrders.php"; // get User Orders
  static const getOrderItems =
      "$hostConnectUser/getOrderItems.php"; // get Order Items
  static const ordersView = "$hostConnectUser/ordersView.php"; // ordersView
  static const notYetReceivedParcelsScreen =
      "$hostConnectUser/notYetReceivedParcelsScreen.php"; // notYetReceivedParcelsScreen
  static const updateNotReceivedStatus =
      "$hostConnectUser/updateNotReceivedStatus.php"; // update Not Received Status to ended
  static const parcelsHistory =
      "$hostConnectUser/ParcelsHistory.php"; // parcels History
  static const getSellerRating =
      "$hostConnectUser/getSellerRating.php"; //get Seller Rating
  static const updateSellerRating =
      "$hostConnectUser/updateSellerRating.php"; // update Seller Rating
  static const searchStores =
      "$hostConnectUser/searchStores.php"; // update Seller Rating
  static const saveFcmTokenUser =
      "$hostConnectUser/saveFcmToken.php"; // save Fcm Token User
  static const getSellerDeviceTokenInUserApp =
      "$hostConnectUser/getSellerDeviceTokenInUserApp.php"; // save Fcm Token User

  //! food user api ------------------------------------------------------
  static const hostConnectFoodUser = "$userFolder/foodUser";
  //!-

  static const saveLocationFoodUser =
      "$hostConnectFoodUser/saveLocationFoodUser.php"; // save Location Food user
  static const fetchSellerByFoodUser =
      "$hostConnectFoodUser/fetchSellerByFoodUser.php"; //fetch Seller By Food User
  static const foodSellerImageInFoodUser = "$hostConnectFoodSeller/";
  static const foodSellerMenusInFoodUser = "$hostConnectFoodSeller/";
  static const foodSellerMenuItemsInFoodUser = "$hostConnectFoodSeller/";

  static const foodUserMenuView =
      "$hostConnectFoodUser/sellerMenuView.php"; //get seller Brand
  static const foodUserSellerMenuItemView =
      "$hostConnectFoodUser/userItemView.php"; //get seller Brand items
  static const foodUserAddToCart =
      "$hostConnectFoodUser/addToCart.php"; // add To Cart
  static const foodUserCartView =
      "$hostConnectFoodUser/cartView.php"; // add To Cart
  static const foodUserDeleteItemFromCart =
      "$hostConnectFoodUser/deleteItemFromCart.php"; // delete Item From Cart
  static const foodUserFetchAddress =
      "$hostConnectFoodUser/address.php"; // address
  static const foodUserAddNewAddress =
      "$hostConnectFoodUser/addNewAddress.php"; // add New Address
  static const foodUserDeleteAddress =
      "$hostConnectFoodUser/delete_address.php"; //delete address
  static const foodUserSaveOrder =
      "$hostConnectFoodUser/saveOrder.php"; // save Order
  static const foodUserGetUserOrders =
      "$hostConnectFoodUser/getUserOrders.php"; // get User Orders
  static const foodUserGetOrderItems =
      "$hostConnectFoodUser/getOrderItems.php"; // get Order Items
  static const foodUserOrdersView =
      "$hostConnectFoodUser/ordersView.php"; // ordersView
  static const foodUserNotYetReceivedParcelsScreen =
      "$hostConnectFoodUser/notYetReceivedParcelsScreen.php"; // notYetReceivedParcelsScreen
  static const foodUserUpdateNotReceivedStatus =
      "$hostConnectFoodUser/updateNotReceivedStatus.php"; // update Not Received Status to ended
  static const foodUserParcelsHistory =
      "$hostConnectFoodUser/ParcelsHistory.php"; // parcels History
  static const foodUserGetSellerRating =
      "$hostConnectFoodUser/getSellerRating.php"; //get Seller Rating
  static const foodUserUpdateSellerRating =
      "$hostConnectFoodUser/updateSellerRating.php"; // update Seller Rating
  static const foodUserSearchStores =
      "$hostConnectFoodUser/searchStores.php"; // update Seller Rating
  static const foodUserSaveFcmTokenUser =
      "$hostConnectFoodUser/saveFcmToken.php"; // save Fcm Token User
  static const foodUserGetSellerDeviceTokenInUserApp =
      "$hostConnectFoodUser/getSellerDeviceTokenInUserApp.php"; // save Fcm Token User

  //!------------------------------SELLERS API CONNECTIONS --------------------------------

  static const hostConnectSeller = "$hostConnect/seller";

  static const validateSellerEmail =
      "$hostConnectSeller/validation_email.php"; //validateSellerEmail
  static const registerSeller =
      "$hostConnectSeller/register.php"; //registerSeller
  static const profileImageSeller = "$hostConnectSeller/uploadImage.php";
  static const loginSeller = "$hostConnectSeller/login.php";
  static const sellerImage = "$hostConnectSeller/";
  static const saveBrandInfo = "$hostConnectSeller/saveBrandInfo.php";
  static const saveBrandImage = "$hostConnectSeller/saveBrandImage.php";
  static const saveBrandData = "$hostConnectSeller/saveBrandData.php";
  static const currentSellerBrandView =
      "$hostConnectSeller/Brands.php"; //seller home page Brand view information
  static const brandImage = "$hostConnectSeller/"; //Brand image
  static const deleteBrand =
      "$hostConnectSeller/deleteBrand.php"; //delete Brand
  static const uploadItem = "$hostConnectSeller/uploadItem.php"; //upload items
  static const getItems = "$hostConnectSeller/getItems.php"; //get items
  static const getItemsImage = "$hostConnectSeller/"; //get items
  static const deleteItems = "$hostConnectSeller/deleteItem.php"; //get items
  static const sellerOrdersView =
      "$hostConnectSeller/ordersView.php"; // ordersView
  static const updateEarningStatus =
      "$hostConnectSeller/updateEarningStatus.php"; // update Earning & Status
  static const earnings = "$hostConnectSeller/earnings.php"; // earnings
  static const shiftedOrdersView =
      "$hostConnectSeller/shiftedOrdersView.php"; // shifted Orders View
  static const endedOrdersView =
      "$hostConnectSeller/endedOrdersView.php"; // ended Orders View
  static const saveFcmToken =
      "$hostConnectSeller/saveFcmToken.php"; // save Fcm Token
  static const getOrderStatus =
      "$hostConnectSeller/getOrderStatus.php"; // get Order Status
  static const getUserDeviceTokenInSellerApp =
      "$hostConnectSeller/getUserDeviceTokenInSellerApp.php"; // get User Device Token In Seller App

  //!------------------------------ FOOD SELLERS API CONNECTIONS --------------------------------

  static const hostConnectFoodSeller = "$hostConnect/foodSeller";

  static const foodSellerValidateSellerEmail =
      "$hostConnectFoodSeller/validation_email.php"; //validateSellerEmail
  static const foodSellerRegisterSeller =
      "$hostConnectFoodSeller/register.php"; //registerSeller
  static const foodSellerProfileImageSeller =
      "$hostConnectFoodSeller/uploadImage.php";
  static const foodSellerLoginSeller = "$hostConnectFoodSeller/login.php";
  static const foodSellerSellerImage = "$hostConnectFoodSeller/";
  static const foodSellerSaveBrandInfo =
      "$hostConnectFoodSeller/saveBrandInfo.php";
  static const foodSellerSaveBrandImage =
      "$hostConnectFoodSeller/saveBrandImage.php";
  static const foodSellerSaveBrandData =
      "$hostConnectFoodSeller/saveBrandData.php";
  static const foodSellerCurrentSellerBrandView =
      "$hostConnectFoodSeller/Brands.php"; //seller home page Brand view information
  static const foodSellerBrandImage = "$hostConnectFoodSeller/"; //Brand image
  static const foodSellerDeleteBrand =
      "$hostConnectFoodSeller/deleteBrand.php"; //delete Brand
  static const foodSellerUploadItem =
      "$hostConnectFoodSeller/uploadItem.php"; //upload items
  static const foodSellerGetItems =
      "$hostConnectFoodSeller/getItems.php"; //get items
  static const foodSellerGetItemsImage = "$hostConnectFoodSeller/"; //get items
  static const foodSellerDeleteItems =
      "$hostConnectFoodSeller/deleteItem.php"; //get items
  static const foodSellerSellerOrdersView =
      "$hostConnectFoodSeller/ordersView.php"; // ordersView
  static const foodSellerUpdateEarningStatus =
      "$hostConnectFoodSeller/updateEarningStatus.php"; // update Earning & Status
  static const foodSellerEarnings =
      "$hostConnectFoodSeller/earnings.php"; // earnings
  static const foodSellerShiftedOrdersView =
      "$hostConnectFoodSeller/shiftedOrdersView.php"; // shifted Orders View
  static const foodSellerEndedOrdersView =
      "$hostConnectFoodSeller/endedOrdersView.php"; // ended Orders View
  static const foodSellerSaveFcmToken =
      "$hostConnectFoodSeller/saveFcmToken.php"; // save Fcm Token
  static const foodSellerGetOrderStatus =
      "$hostConnectFoodSeller/getOrderStatus.php"; // get Order Status
  static const foodSellerGetUserDeviceTokenInSellerApp =
      "$hostConnectFoodSeller/getUserDeviceTokenInSellerApp.php"; // get User Device Token In Seller App
  static const updateSellerLocation =
      "$hostConnectFoodSeller/updateSellerLocation.php"; //update Seller Location
  static const fetchSellerLocation =
      "$hostConnectFoodSeller/fetchSellerLocation.php"; // fetch  Seller Location

  //!--------------------Rider API------------------------------------------
  static const hostRider = "$hostConnect/riders";

  static const validate = "$hostRider/validate_email.php";
  static const riderSignUp = "$hostRider/sign_up.php";
  static const riderLogin = "$hostRider/log_In.php";
  static const upProfileImage = "$hostRider/uploadProfileImage.php";
  static const riderEarnings = "$hostRider/rider_earnings.php"; //rider Earnings
  static const deliveryAmount ="$hostRider/get_per_parcel_delivery_amount.php"; //get_per_parcel_delivery_amount
  static const normalOrdersRDR = "$hostRider/riderOrderScreen.php";
  static const updateOrderStatusRDR = "$hostRider/updateOrderStatus.php";
  static const getLatLngOfSellerInRDR = "$hostRider/getLatLngOfSellerInRDR.php";
  static const updateOrderPicking = "$hostRider/updateOrderPicking.php";
  static const parcelInProgressScreenRDR =
      "$hostRider/parcelInProgressScreenRDR.php";
  static const parcelNotYetDeliverScreenRDR =
      "$hostRider/parcelNotYetDeliverScreenRDR.php";
  static const parcelHistoryScreenRDR = "$hostRider/parcelHistoryScreenRDR.php";
  static const getOrderDetailsRDR = "$hostRider/getOrderDetails.php";
  static const getSellerDataRDR = "$hostRider/getSellerData.php";
  static const updateStatusToEnded = "$hostRider/updateStatusToEnded.php";
  
  static const updateStatusToEndedRDR = "$hostRider/updateStatusToEnded.php";
  
  static const updateEarningsRDR = "$hostRider/updateEarningsRDR.php";

   static const updateSellerEarningsRDR = "$hostRider/updateSellerEarningsRDR.php";
   
   static const updateOrderStatusEndingRDR = "$hostRider/updateOrderStatusRDR.php";
      static const getSellerAddressRDR = "$hostRider/get_seller_address.php";
}

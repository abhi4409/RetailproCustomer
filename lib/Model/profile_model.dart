import 'dart:typed_data';

class ProfileModels {
  String docId;
  bool loading;
  bool edit;
  bool passwordLoading;
  bool imageUploading;

  Uint8List? profileImage;
  String profileImageUrl;

  ProfileModels({
    this.docId = "",
    this.loading = true,
    this.edit = false,
    this.passwordLoading = false,
    this.imageUploading = false,
    this.profileImage,
    this.profileImageUrl = "",
  });
}
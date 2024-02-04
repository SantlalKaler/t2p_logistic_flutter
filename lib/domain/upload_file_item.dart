class UploadFileItem {
  final String title;
  final UploadFileItemId id;

  const UploadFileItem(
    this.title,
    this.id,
  );
}

enum UploadFileItemId { profileImage, voterCard, panCard, aadharCard }

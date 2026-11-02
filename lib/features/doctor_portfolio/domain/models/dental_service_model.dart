class DentalServiceModel {
  final String id;
  final String title;
  final String bnTitle;
  final String description;
  final String category;
  final String startingPrice; // e.g., '৳2,500'
  final String duration; // e.g., '30 - 45 mins'
  final String iconName; // e.g. 'medical_services', 'cleaning_services'
  final List<String> highlights;

  const DentalServiceModel({
    required this.id,
    required this.title,
    required this.bnTitle,
    required this.description,
    required this.category,
    required this.startingPrice,
    required this.duration,
    required this.iconName,
    required this.highlights,
  });
}

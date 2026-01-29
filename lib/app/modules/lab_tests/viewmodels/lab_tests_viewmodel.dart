import 'package:get/get.dart';

class LabTestsViewModel extends GetxController {
  final isLoading = false.obs;

  final List<Map<String, dynamic>> labPartners = [
    {
      'name': 'Chughtai Lab',
      'tests': '1200+ Tests',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz-M8vE62Hj-C9b-_mK3_0m_L9-9H5v6P0WQ&s',
    },
    {
      'name': 'IDC Lab',
      'tests': '1000+ Tests',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7w4Vp-2z6L-I6m5v7z-0_l_L9-9H5v6P0WQ&s',
    },
  ].obs;

  final List<Map<String, dynamic>> packages = [
    {
      'name': 'Basic Health Package',
      'tests': '7 Tests',
      'color': 0xFFFFE4E1, // Light Pink
    },
    {
      'name': 'Diabetes Plan',
      'tests': '3 Tests',
      'color': 0xFFE0FFFF, // Light Cyan
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }
}

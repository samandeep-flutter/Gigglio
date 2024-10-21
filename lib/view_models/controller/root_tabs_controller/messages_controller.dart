import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gigglio/model/utils/app_constants.dart';

class MessagesController extends GetxController {
  final searchController = TextEditingController();
  final searchFoucs = FocusNode();

  @override
  void onInit() {
    searchController.addListener(onSearch);
    super.onInit();
  }

  Future<void> onSearch() async {
    const duration = Duration(milliseconds: 800);
    EasyDebounce.debounce(AppConstants.searchKey, duration, () {
      // searchFoucs.unfocus();
    });
  }

  void onClear() async {
    searchController.clear();
    searchFoucs.unfocus();
  }
}

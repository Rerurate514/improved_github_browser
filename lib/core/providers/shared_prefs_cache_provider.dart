import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsCacheProvider = StateProvider<SharedPreferences?>((ref) => null);

final initSharedPrefsCacheProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  ref.read(sharedPrefsCacheProvider.notifier).state = prefs;
});

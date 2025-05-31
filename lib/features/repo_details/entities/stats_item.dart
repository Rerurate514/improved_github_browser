import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_item.freezed.dart';

@freezed
abstract class StatsItem with _$StatsItem {
  factory StatsItem({
    required IconData icon,
    required String value,
    required String label
  }) = _StatsItem;
}

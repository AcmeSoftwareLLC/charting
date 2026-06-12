import 'dart:math';

import 'package:acme_chart/acme_chart.dart';

/// Extension on Repository.
extension AddOnsRepositoryConfigExtension on Repository<AddOnConfig> {
  // TODO(Ramin): Later will do this will be internally handled inside the
  // repository. When Web can update.
  /// Gets the next number for a new indicator or drawing tool.
  int getNumberForNewAddOn(AddOnConfig addOn) {
    final Iterable<AddOnConfig> addOnOfSameType = items.where(
      (AddOnConfig item) => item.runtimeType == addOn.runtimeType,
    );

    if (addOnOfSameType.isNotEmpty) {
      final int postFixNumber =
          addOnOfSameType
              .map<int>((AddOnConfig item) => item.number)
              .reduce(max) +
          1;

      return postFixNumber;
    }

    return 0;
  }
}

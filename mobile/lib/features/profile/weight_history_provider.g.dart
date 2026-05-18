// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weightHistoryHash() => r'afd7c265017ea5c378fca2eeaa661d821989c703';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [weightHistory].
@ProviderFor(weightHistory)
const weightHistoryProvider = WeightHistoryFamily();

/// See also [weightHistory].
class WeightHistoryFamily extends Family<AsyncValue<List<WeightRecord>>> {
  /// See also [weightHistory].
  const WeightHistoryFamily();

  /// See also [weightHistory].
  WeightHistoryProvider call([WeightPeriod period = WeightPeriod.month]) {
    return WeightHistoryProvider(period);
  }

  @override
  WeightHistoryProvider getProviderOverride(
    covariant WeightHistoryProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weightHistoryProvider';
}

/// See also [weightHistory].
class WeightHistoryProvider
    extends AutoDisposeFutureProvider<List<WeightRecord>> {
  /// See also [weightHistory].
  WeightHistoryProvider([WeightPeriod period = WeightPeriod.month])
    : this._internal(
        (ref) => weightHistory(ref as WeightHistoryRef, period),
        from: weightHistoryProvider,
        name: r'weightHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weightHistoryHash,
        dependencies: WeightHistoryFamily._dependencies,
        allTransitiveDependencies:
            WeightHistoryFamily._allTransitiveDependencies,
        period: period,
      );

  WeightHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final WeightPeriod period;

  @override
  Override overrideWith(
    FutureOr<List<WeightRecord>> Function(WeightHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeightHistoryProvider._internal(
        (ref) => create(ref as WeightHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WeightRecord>> createElement() {
    return _WeightHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightHistoryProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeightHistoryRef on AutoDisposeFutureProviderRef<List<WeightRecord>> {
  /// The parameter `period` of this provider.
  WeightPeriod get period;
}

class _WeightHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<WeightRecord>>
    with WeightHistoryRef {
  _WeightHistoryProviderElement(super.provider);

  @override
  WeightPeriod get period => (origin as WeightHistoryProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

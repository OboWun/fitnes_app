// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allEquipmentHash() => r'f15d4c983b753225470b4375bd2223ec4f6d90b9';

/// See also [allEquipment].
@ProviderFor(allEquipment)
final allEquipmentProvider =
    AutoDisposeFutureProvider<List<EquipmentItem>>.internal(
      allEquipment,
      name: r'allEquipmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allEquipmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllEquipmentRef = AutoDisposeFutureProviderRef<List<EquipmentItem>>;
String _$allPresetsHash() => r'ec360f9e66a32ef833b9288cf9941e3ad096925d';

/// See also [allPresets].
@ProviderFor(allPresets)
final allPresetsProvider =
    AutoDisposeFutureProvider<List<EquipmentPreset>>.internal(
      allPresets,
      name: r'allPresetsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allPresetsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllPresetsRef = AutoDisposeFutureProviderRef<List<EquipmentPreset>>;
String _$equipmentExercisesHash() =>
    r'9095f3baa37da42caf3af2cdc602a776a3802600';

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

/// See also [equipmentExercises].
@ProviderFor(equipmentExercises)
const equipmentExercisesProvider = EquipmentExercisesFamily();

/// See also [equipmentExercises].
class EquipmentExercisesFamily extends Family<AsyncValue<List<ExerciseBrief>>> {
  /// See also [equipmentExercises].
  const EquipmentExercisesFamily();

  /// See also [equipmentExercises].
  EquipmentExercisesProvider call(String slug) {
    return EquipmentExercisesProvider(slug);
  }

  @override
  EquipmentExercisesProvider getProviderOverride(
    covariant EquipmentExercisesProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'equipmentExercisesProvider';
}

/// See also [equipmentExercises].
class EquipmentExercisesProvider
    extends AutoDisposeFutureProvider<List<ExerciseBrief>> {
  /// See also [equipmentExercises].
  EquipmentExercisesProvider(String slug)
    : this._internal(
        (ref) => equipmentExercises(ref as EquipmentExercisesRef, slug),
        from: equipmentExercisesProvider,
        name: r'equipmentExercisesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$equipmentExercisesHash,
        dependencies: EquipmentExercisesFamily._dependencies,
        allTransitiveDependencies:
            EquipmentExercisesFamily._allTransitiveDependencies,
        slug: slug,
      );

  EquipmentExercisesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<List<ExerciseBrief>> Function(EquipmentExercisesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EquipmentExercisesProvider._internal(
        (ref) => create(ref as EquipmentExercisesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExerciseBrief>> createElement() {
    return _EquipmentExercisesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EquipmentExercisesProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EquipmentExercisesRef
    on AutoDisposeFutureProviderRef<List<ExerciseBrief>> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _EquipmentExercisesProviderElement
    extends AutoDisposeFutureProviderElement<List<ExerciseBrief>>
    with EquipmentExercisesRef {
  _EquipmentExercisesProviderElement(super.provider);

  @override
  String get slug => (origin as EquipmentExercisesProvider).slug;
}

String _$equipmentPresetServiceHash() =>
    r'c2e353c0fa91eaf998da8277fe0ff427abbaa4be';

/// See also [equipmentPresetService].
@ProviderFor(equipmentPresetService)
final equipmentPresetServiceProvider =
    AutoDisposeProvider<EquipmentPresetService>.internal(
      equipmentPresetService,
      name: r'equipmentPresetServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$equipmentPresetServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EquipmentPresetServiceRef =
    AutoDisposeProviderRef<EquipmentPresetService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

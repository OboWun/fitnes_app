// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exercisesPageHash() => r'87f45691ae40fc30df384c0868df69e24feccdf9';

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

/// See also [exercisesPage].
@ProviderFor(exercisesPage)
const exercisesPageProvider = ExercisesPageFamily();

/// See also [exercisesPage].
class ExercisesPageFamily
    extends Family<AsyncValue<PaginatedResult<ExerciseShort>>> {
  /// See also [exercisesPage].
  const ExercisesPageFamily();

  /// See also [exercisesPage].
  ExercisesPageProvider call(int page, ExerciseFilter filter) {
    return ExercisesPageProvider(page, filter);
  }

  @override
  ExercisesPageProvider getProviderOverride(
    covariant ExercisesPageProvider provider,
  ) {
    return call(provider.page, provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'exercisesPageProvider';
}

/// See also [exercisesPage].
class ExercisesPageProvider
    extends AutoDisposeFutureProvider<PaginatedResult<ExerciseShort>> {
  /// See also [exercisesPage].
  ExercisesPageProvider(int page, ExerciseFilter filter)
    : this._internal(
        (ref) => exercisesPage(ref as ExercisesPageRef, page, filter),
        from: exercisesPageProvider,
        name: r'exercisesPageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$exercisesPageHash,
        dependencies: ExercisesPageFamily._dependencies,
        allTransitiveDependencies:
            ExercisesPageFamily._allTransitiveDependencies,
        page: page,
        filter: filter,
      );

  ExercisesPageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.filter,
  }) : super.internal();

  final int page;
  final ExerciseFilter filter;

  @override
  Override overrideWith(
    FutureOr<PaginatedResult<ExerciseShort>> Function(ExercisesPageRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExercisesPageProvider._internal(
        (ref) => create(ref as ExercisesPageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaginatedResult<ExerciseShort>>
  createElement() {
    return _ExercisesPageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExercisesPageProvider &&
        other.page == page &&
        other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExercisesPageRef
    on AutoDisposeFutureProviderRef<PaginatedResult<ExerciseShort>> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `filter` of this provider.
  ExerciseFilter get filter;
}

class _ExercisesPageProviderElement
    extends AutoDisposeFutureProviderElement<PaginatedResult<ExerciseShort>>
    with ExercisesPageRef {
  _ExercisesPageProviderElement(super.provider);

  @override
  int get page => (origin as ExercisesPageProvider).page;
  @override
  ExerciseFilter get filter => (origin as ExercisesPageProvider).filter;
}

String _$exerciseDetailHash() => r'0ccf37cad24ff73f0d7d2c5a375f577e865cf4dd';

/// See also [exerciseDetail].
@ProviderFor(exerciseDetail)
const exerciseDetailProvider = ExerciseDetailFamily();

/// See also [exerciseDetail].
class ExerciseDetailFamily extends Family<AsyncValue<ExerciseDetail>> {
  /// See also [exerciseDetail].
  const ExerciseDetailFamily();

  /// See also [exerciseDetail].
  ExerciseDetailProvider call(String slug) {
    return ExerciseDetailProvider(slug);
  }

  @override
  ExerciseDetailProvider getProviderOverride(
    covariant ExerciseDetailProvider provider,
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
  String? get name => r'exerciseDetailProvider';
}

/// See also [exerciseDetail].
class ExerciseDetailProvider extends AutoDisposeFutureProvider<ExerciseDetail> {
  /// See also [exerciseDetail].
  ExerciseDetailProvider(String slug)
    : this._internal(
        (ref) => exerciseDetail(ref as ExerciseDetailRef, slug),
        from: exerciseDetailProvider,
        name: r'exerciseDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$exerciseDetailHash,
        dependencies: ExerciseDetailFamily._dependencies,
        allTransitiveDependencies:
            ExerciseDetailFamily._allTransitiveDependencies,
        slug: slug,
      );

  ExerciseDetailProvider._internal(
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
    FutureOr<ExerciseDetail> Function(ExerciseDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExerciseDetailProvider._internal(
        (ref) => create(ref as ExerciseDetailRef),
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
  AutoDisposeFutureProviderElement<ExerciseDetail> createElement() {
    return _ExerciseDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseDetailProvider && other.slug == slug;
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
mixin ExerciseDetailRef on AutoDisposeFutureProviderRef<ExerciseDetail> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _ExerciseDetailProviderElement
    extends AutoDisposeFutureProviderElement<ExerciseDetail>
    with ExerciseDetailRef {
  _ExerciseDetailProviderElement(super.provider);

  @override
  String get slug => (origin as ExerciseDetailProvider).slug;
}

String _$allMusclesHash() => r'bade1e0079a3cc8069df770444a5ea514643940d';

/// See also [allMuscles].
@ProviderFor(allMuscles)
final allMusclesProvider = AutoDisposeFutureProvider<List<MuscleItem>>.internal(
  allMuscles,
  name: r'allMusclesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allMusclesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMusclesRef = AutoDisposeFutureProviderRef<List<MuscleItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

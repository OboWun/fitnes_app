// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contraindicationsHash() => r'bc2e5badabf2ba10c7ca587f10055f7ed35a8fd9';

/// See also [contraindications].
@ProviderFor(contraindications)
final contraindicationsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      contraindications,
      name: r'contraindicationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contraindicationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContraindicationsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$authHash() => r'5d02c0a963fb921cedfd8d41cfa6861356bf31b2';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider = NotifierProvider<Auth, AuthState>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = Notifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

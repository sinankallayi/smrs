// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rolesHash() => r'59af6f18767c51681fbda43a8dd5646038b97cf9';

/// See also [roles].
@ProviderFor(roles)
final rolesProvider = AutoDisposeStreamProvider<List<String>>.internal(
  roles,
  name: r'rolesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rolesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RolesRef = AutoDisposeStreamProviderRef<List<String>>;
String _$sectionsHash() => r'fab0e40a4a689d8e3fd7053fa085e5dad8c781c6';

/// See also [sections].
@ProviderFor(sections)
final sectionsProvider = AutoDisposeStreamProvider<List<String>>.internal(
  sections,
  name: r'sectionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sectionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SectionsRef = AutoDisposeStreamProviderRef<List<String>>;
String _$configServiceHash() => r'464cb40e3b7a3694f245e0160da4e50bc7905a71';

/// See also [ConfigService].
@ProviderFor(ConfigService)
final configServiceProvider =
    AutoDisposeNotifierProvider<ConfigService, void>.internal(
      ConfigService.new,
      name: r'configServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$configServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConfigService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

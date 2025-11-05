// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wordListHash() => r'1d480b55e657521cd2e0a4dbaa3c2f70f32d87d8';

/// A provider for the wordlist to use when generating the crossword.
///
/// Copied from [wordList].
@ProviderFor(wordList)
final wordListProvider = FutureProvider<BuiltSet<String>>.internal(
  wordList,
  name: r'wordListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wordListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WordListRef = FutureProviderRef<BuiltSet<String>>;
String _$databaseWordsHash() => r'a391487361c0d507af44b76fa0c4da0e4becaae6';

/// A provider that tracks which words come from the database
///
/// Copied from [databaseWords].
@ProviderFor(databaseWords)
final databaseWordsProvider = FutureProvider<BuiltSet<String>>.internal(
  databaseWords,
  name: r'databaseWordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseWordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseWordsRef = FutureProviderRef<BuiltSet<String>>;
String _$workQueueHash() => r'd64b52aeccabc44e3455c02e05183b8028571d72';

/// See also [workQueue].
@ProviderFor(workQueue)
final workQueueProvider = AutoDisposeStreamProvider<model.WorkQueue>.internal(
  workQueue,
  name: r'workQueueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workQueueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkQueueRef = AutoDisposeStreamProviderRef<model.WorkQueue>;
String _$startTimeHash() => r'578312d6a83de8d2a78b460fe109e17fd7d1d44e';

/// Un proveedor de la hora de inicio del crucigrama.
///
/// Copied from [startTime].
@ProviderFor(startTime)
final startTimeProvider = AutoDisposeProvider<DateTime>.internal(
  startTime,
  name: r'startTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$startTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StartTimeRef = AutoDisposeProviderRef<DateTime>;
String _$endTimeHash() => r'db3036ad4525bc95d5c8736b56047d1f206b8ab2';

/// Un proveedor de la hora de finalización del crucigrama.
///
/// Copied from [endTime].
@ProviderFor(endTime)
final endTimeProvider = AutoDisposeProvider<DateTime?>.internal(
  endTime,
  name: r'endTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$endTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EndTimeRef = AutoDisposeProviderRef<DateTime?>;
String _$expectedRemainingTimeHash() =>
    r'cfe9cc1d29e030388a76cba2c11b56aaa685584f';

/// Un proveedor del tiempo esperado restante para completar el crucigrama.
///
/// Copied from [expectedRemainingTime].
@ProviderFor(expectedRemainingTime)
final expectedRemainingTimeProvider = AutoDisposeProvider<Duration>.internal(
  expectedRemainingTime,
  name: r'expectedRemainingTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expectedRemainingTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpectedRemainingTimeRef = AutoDisposeProviderRef<Duration>;
String _$displayInfoHash() => r'36247dfc90c6e1354ed4293199ef4817972e01e5';

/// Un proveedor de la información a mostrar sobre el crucigrama.
///
/// Copied from [displayInfo].
@ProviderFor(displayInfo)
final displayInfoProvider = AutoDisposeProvider<model.DisplayInfo>.internal(
  displayInfo,
  name: r'displayInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$displayInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisplayInfoRef = AutoDisposeProviderRef<model.DisplayInfo>;
String _$targetWordsHash() => r'd954af0a52ff0b6ed0aee340baff4ddc8151e6dd';

/// Provider que genera palabras objetivo aleatorias del crucigrama
///
/// Copied from [targetWords].
@ProviderFor(targetWords)
final targetWordsProvider = AutoDisposeProvider<BuiltSet<String>>.internal(
  targetWords,
  name: r'targetWordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$targetWordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TargetWordsRef = AutoDisposeProviderRef<BuiltSet<String>>;
String _$sizeHash() => r'e551985965bf4119e8d90c0e8aa4f4d68a555b73';

/// A provider that holds the current size of the crossword to generate.
///
/// Copied from [Size].
@ProviderFor(Size)
final sizeProvider = NotifierProvider<Size, CrosswordSize>.internal(
  Size.new,
  name: r'sizeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sizeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Size = Notifier<CrosswordSize>;
String _$workerCountHash() => r'1764b62ee4e611996ec24f68605da910aa7fbdec';

/// A provider that holds the current number of background workers to use.
///
/// Copied from [WorkerCount].
@ProviderFor(WorkerCount)
final workerCountProvider =
    NotifierProvider<WorkerCount, BackgroundWorkers>.internal(
      WorkerCount.new,
      name: r'workerCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workerCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkerCount = Notifier<BackgroundWorkers>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

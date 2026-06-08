/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:path/path.dart' as path;

import 'artifacts_provider.dart';
import 'builder.dart';
import 'environment.dart';
import 'options.dart';
import 'target.dart';

class BuildCMake {
  final CargokitUserOptions userOptions;

  BuildCMake({required this.userOptions});

  Future<void> build() async {
    final targetPlatform = Environment.targetPlatform;
    var target = Target.forFlutterName(targetPlatform);
    if (target == null) {
      // Fallback: try to match by Rust triple pattern for Windows ARM64
      if (targetPlatform == 'windows-arm64') {
        target = Target(rust: 'aarch64-pc-windows-msvc', flutter: 'windows-arm64');
      }
    }
    if (target == null) {
      throw Exception("Unknown target platform: $targetPlatform. Available targets: ${Target.all.map((t) => t.flutter).toList()}");
    }

    final environment = BuildEnvironment.fromEnvironment(isAndroid: false);
    final provider =
        ArtifactProvider(environment: environment, userOptions: userOptions);
    final artifacts = await provider.getArtifacts([target]);

    final libs = artifacts[target]!;

    for (final lib in libs) {
      if (lib.type == AritifactType.dylib) {
        File(lib.path)
            .copySync(path.join(Environment.outputDir, lib.finalFileName));
      }
    }
  }
}

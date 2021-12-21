import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:equatable/equatable.dart';
// import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:meta/meta.dart';
import 'package:midigen/src/extensions/extensions.dart';
import 'package:midigen/src/logger.dart';
// import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

/// {@template generate_command}
/// Generates a set of random MIDI files.
///
/// Usage: `midigen generate `
/// {@endtemplate}
class GenerateCommand extends Command<int> {
  GenerateCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addVerboseFlag()
      ..addOption(
        'amount',
        abbr: 'a',
        help: 'Specifies the amount of MIDI files to generate.',
        defaultsTo: '5',
        callback: (value) {
          if (value == null || int.tryParse(value) == null) {
            throw const FormatException('Amount must be an integer.');
          }
        },
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Generates a set of random MIDI files based on a predetermined set '
      'of base chord MIDI files.';

  @override
  String get summary => '$invocation\n$description';

  @override
  String get name => 'generate';

  @override
  String get invocation => 'midigen generate [options]';

  /// [ArgResults] which can be overridden for testing.
  @visibleForTesting
  ArgResults? argResultOverrides;

  ArgResults get _argResults => argResultOverrides ?? argResults!;

  @override
  Future<int> run() async {
    Logger.verboseEnabled = isVerboseFlagSet;

    _logger.debug('Running in verbose mode.');

    final amount = int.parse(_argResults['amount'] as String);

    final workingDirectory = _argResults.rest.isEmpty
        ? Directory.current
        : Directory(_argResults.rest.first);

    Directory.current = workingDirectory;

    if (!workingDirectory.existsSync()) {
      throw Exception('Given path "${workingDirectory.path}" does not exist.');
    }

    final args = GenerateArgs(
      amount: amount,
      workingDirectory: workingDirectory,
    );

    try {
      final result = await Generate(
        args: args,
        logger: _logger,
      ).run();

      if (!result.didGenerateFiles) {
        _logger.info('No files were generated.');
        return 1;
      }

      return ExitCode.success.code;
    } catch (_) {
      return ExitCode.software.code;
    }
  }
}

/// {@template generate_args}
/// The arguments for the `midigen generate` command.
/// {@endtemplate}
class GenerateArgs extends Equatable {
  const GenerateArgs({
    required this.amount,
    required this.workingDirectory,
  });

  final int amount;
  final Directory workingDirectory;

  @override
  List<Object> get props => [
        amount,
        workingDirectory,
      ];
}

/// {@template generate_result}
/// The result of running the `midigen generate` command.
/// {@endtemplate}
class GenerateResult extends Equatable {
  /// {@macro generate_result}
  const GenerateResult({
    required this.didGenerateFiles,
    required this.filePaths,
  });

  final bool didGenerateFiles;
  final List<String> filePaths;

  @override
  List<Object?> get props => [didGenerateFiles, filePaths];
}

/// {@template generate}
/// The runner for the `midigen generate` command.
/// {@endtemplate}
@visibleForTesting
class Generate {
  Generate({
    required GenerateArgs args,
    Logger? logger,
  })  : _args = args,
        _logger = logger ?? Logger();

  final GenerateArgs _args;
  final Logger _logger;

  Future<GenerateResult> run() async {
    _logger.debug('Running generate command with args: $_args');

    void Function() stopProgress;

    stopProgress = _logger.progress('Doing something...');
    // final directLockPackages = await _getDirectLockPackages();
    stopProgress();

    // TODO(jeroen-meijer): Implement this.

    return const GenerateResult(
      didGenerateFiles: false,
      filePaths: [],
    );
  }
}

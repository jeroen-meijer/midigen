// ignore_for_file: prefer_const_constructors
import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:midigen/src/command_runner.dart';
import 'package:midigen/src/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

const expectedUsage = '''
A CLI for generating random midi chord sequences, made to inspire creativity. 🎹

Usage: midigen <command> [arguments]

Global options:
-h, --help       Print this usage information.
    --version    Print the current version of midigen.
-v, --verbose    Print debug information. Can be used with any command.

Available commands:
  generate ...

...''';

void main() {
  group('Midigen', () {
    late Logger logger;

    // String? runningProgress;
    // final stoppedProgresses = <String>[];

    setUp(() {
      logger = MockLogger();
      when(() => logger.progress(any())).thenReturn(([_]) {});
      // when(() => logger.progress(captureAny())).thenAnswer((_) {
      //   final progress = _.positionalArguments.single as String;
      //   runningProgress = progress;
      //   return ([_]) {
      //     runningProgress = null;
      //     stoppedProgresses.add(progress);
      //   };
      // });
    });

    MidigenCommandRunner buildSubject() {
      return MidigenCommandRunner(
        logger: logger,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(buildSubject, returnsNormally);
      });

      test('can be instantiated without an explicit logger instance', () {
        expect(() => MidigenCommandRunner(), returnsNormally);
      });
    });

    group('run', () {
      test('handles FormatException', () async {
        final subject = buildSubject();

        const exception = FormatException('oops');
        var isFirstInvocation = true;
        when(() => logger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });

        final result = await subject.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(subject.usage)).called(1);
      });

      test('handles UsageException', () async {
        final subject = buildSubject();

        final exception = UsageException('oops!', subject.usage);
        var isFirstInvocation = true;
        when(() => logger.info(any())).thenAnswer((_) {
          if (isFirstInvocation) {
            isFirstInvocation = false;
            throw exception;
          }
        });

        final result = await subject.run(['--version']);
        expect(result, equals(ExitCode.usage.code));
        verify(() => logger.err(exception.message)).called(1);
        verify(() => logger.info(subject.usage)).called(1);
      });

      test('handles no command', () async {
        final result = await buildSubject().run([]);

        expect(result, equals(ExitCode.usage.code));
        verifyInOrder([
          () => logger.err('No command specified.'),
          () => logger.info(''),
          () => logger.info(expectedUsage),
        ]);
      });

      test('handles unexpected errors', () async {
        final subject = buildSubject();

        final exception = Exception('oops');
        when(() => logger.info(any())).thenThrow(exception);

        final result = await subject.run(['--version']);
        expect(result, ExitCode.software.code);
        verifyInOrder([
          () => logger.err(styleBold.wrap('Unexpected error occurred')),
          () => logger.err(exception.toString()),
          () => logger.err(any(
                that: startsWith('#0      When.thenThrow.<anonymous closure>'),
              )),
        ]);
      });

      // TODO(@jeroen-meijer): Add more tests from https://github.com/felangel/mason/blob/master/test/command_runner_test.dart
    });
  });
}

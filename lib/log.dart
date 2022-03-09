import 'package:logger/logger.dart';

class Log {
  static PrettyPrinter prettyPrinter = PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 255,
    colors: true,
    printEmojis: true,
    printTime: true,
  );

  static SimplePrinter simplePrinter = SimplePrinter(
    printTime: true,
  );

  static LogFilter devFilter = DevelopmentFilter();
  static LogOutput consoleOutput = ConsoleOutput();

  static Logger clogger() {
    Logger logr = Logger(
      filter: devFilter,
      printer: simplePrinter,
      output: consoleOutput,
    );

    return logr;
  }

  static Logger logger() {
    Logger logr = Logger();
    return logr;
  }
}

import 'package:square_web/command/command.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    init();
  }

  CommandExecutor _commandExecutor = CommandExecutor();

  void init() {

  }

  Future<bool> request(Command command) {
    return _commandExecutor.executeCommand(command);
  }
}

part of nyxx.commands;

/// Absctract class to factory new command
abstract class Command {
  /// Name of command. Text which will trigger execution
  String name;

  /// Help message
  String help;

  /// Example usage of command
  String usage;

  /// Indicates if commands is restricted to admins
  bool isAdmin = false;

  /// List of roles required to execute command
  List<String> requiredRoles = null;

  /// Cooldown for command in seconds
  int cooldown = 0;

  /// Indicated if command is hidden from help
  bool isHidden = false;

  /// List of aliases for command
  List<String> aliases = null;

  /// Function which will be invoked when command triggers
  Future run();

  /// Execution context of command. [MessageEvent] class contains [Message] instance.
  MessageEvent context;

  /// Reply to messsage which fires command.
  Future<Message> reply(
      {String content,
      EmbedBuilder embed,
      bool tts: false,
      String nonce,
      bool disableEveryone}) async {
    return await context.message.channel.send(
        content: content,
        embed: embed,
        tts: tts,
        nonce: nonce,
        disableEveryone: disableEveryone);
  }

  /// Delays execution of command and waits for nex matching command based on [prefix]. Has static timemout of 30 seconds
  Future<MessageEvent> delay(
      {String prefix: "", bool ensureUser = false}) async {
    return await context.message.client.onMessage.firstWhere((i) {
      if (!i.message.content.startsWith(prefix)) return false;

      if (ensureUser) return i.message.author.id == context.message.author.id;

      return true;
    }).timeout(const Duration(seconds: 30),
        onTimeout: () {
      print("Timed out");
        return null;
    });
  }
}
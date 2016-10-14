part of discord;

/// A user.
class User extends _BaseObj {
  Timer _typing;
  Map<String, dynamic> _raw;

  /// The user's username.
  String username;

  /// The user's ID.
  String id;

  /// The user's discriminator.
  String discriminator;

  /// The user's avatar hash.
  String avatar;

  /// The user's avatar URL.
  String avatarURL;

  /// The string to mention the user.
  String mention;

  /// A timestamp of when the user was created.
  DateTime createdAt;

  /// Whether or not the user is a bot.
  bool bot = false;

  User._new(Client client, Map<String, dynamic> data) : super(client) {
    this._raw = data;
    this.username = this._map['username'] = data['username'];
    this.id = this._map['id'] = data['id'];
    this.discriminator = this._map['discriminator'] = data['discriminator'];
    this.avatar = this._map['avatar'] = data['avatar'];
    this.avatarURL = this._map['avatarURL'] =
        "https://discordapp.com/api/v6/users/${this.id}/avatars/${this.avatar}.jpg";
    this.mention = this._map['mention'] = "<@${this.id}>";
    this.createdAt =
        this._map['createdAt'] = this._client._util.getDate(this.id);
    this._map['key'] = this.id;

    // This will not be set at all in some cases.
    if (data['bot'] == true) {
      this.bot = this._map['bot'] = data['bot'];
    } else {
      this._map['bot'] = false;
    }
  }

  Future<DMChannel> _getChannel() async {
    try {
      return _client.channels.list
          .firstWhere(
              (dynamic c) => c is DMChannel && c.recipient.id == this.id)
          .id;
    } catch (err) {
      _HttpResponse r = await _client._http
          .post("/users/@me/channels", {"recipient_id": this.id});
      return r.json['id'];
    }
  }

  /// Sends a message.
  ///
  /// Throws an [Exception] if the HTTP request errored.
  ///     Channel.sendMessage("My content!");
  Future<Message> sendMessage(String content, [MessageOptions options]) async {
    MessageOptions newOptions;
    if (options == null) {
      newOptions = new MessageOptions();
    } else {
      newOptions = options;
    }

    String newContent;
    if (newOptions.disableEveryone == true ||
        (newOptions.disableEveryone == null &&
            this._client._options.disableEveryone)) {
      newContent = content
          .replaceAll("@everyone", "@\u200Beveryone")
          .replaceAll("@here", "@\u200Bhere");
    } else {
      newContent = content;
    }

    final _HttpResponse r = await this._client._http.post(
        '/channels/${await _getChannel()}/messages', <String, dynamic>{
      "content": newContent,
      "tts": newOptions.tts,
      "nonce": newOptions.nonce
    });
    return new Message._new(this._client, r.json);
  }

  /// Gets a [Message] object. Only usable by bot accounts.
  ///
  /// Throws an [Exception] if the HTTP request errored or if the client user
  /// is not a bot.
  ///     Channel.getMessage("message id");
  Future<Message> getMessage(dynamic message) async {
    if (this._client.user.bot) {
      final String id = this._client._util.resolve('message', message);

      final _HttpResponse r = await this
          ._client
          ._http
          .get('/channels/${await _getChannel()}/messages/$id');
      return new Message._new(this._client, r.json);
    } else {
      throw new Exception("'getMessage' is only usable by bot accounts.");
    }
  }

  /// Starts typing.
  Future<Null> startTyping() async {
    await this
        ._client
        ._http
        .post("/channels/${await _getChannel()}/typing", {});
    return null;
  }

  /// Loops `startTyping` until `stopTypingLoop` is called.
  void startTypingLoop() {
    startTyping();
    this._typing = new Timer.periodic(
        const Duration(seconds: 7), (Timer t) => startTyping());
  }

  /// Stops a typing loop if one is running.
  void stopTypingLoop() {
    this._typing?.cancel();
  }

  /// Returns a string representation of this object.
  @override
  String toString() {
    return this.username;
  }
}

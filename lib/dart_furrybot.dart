// ignore_for_file: non_constant_identifier_names

import 'package:openai_gpt3_api/openai_gpt3_api.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:dotenv/dotenv.dart';
import 'dart:convert';

void startBot() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  var api = GPT3(env['openai']!);
  String BOT_TOKEN = env['bot']!;
  try {
    String initialPrompt =
        "Мое имя - Фурри в пакетике. Я отношусь к субкультуре Фурри. Моя фурсона - Волк. Мой возраст - 18 лет. Мой создатель - Deargo. Я есть по ссылке vk.com. Мое фото есть по ссылке vk.com. Во мне более 400 строк. Моя сексуальная ориентация - бисексуальная.";
    final username = (await Telegram(BOT_TOKEN).getMe()).username;
    var teledart = TeleDart(BOT_TOKEN, Event(username!));
    teledart.start();

    print('initialized! \n');

    // init finished

    teledart.onMessage(entityType: 'bot_command', keyword: 'start').listen(
        (message) => teledart.sendMessage(message.chat.id, 'hi there :3'));
    String lastMessage = initialPrompt;
    teledart.onMessage().listen((event) async {
      teledart.sendChatAction(event.chat.id, 'typing');
      print(event.text);
      var result = await api.completion(
          // ${lastMessage != '' ? 'Friend: ${lastMessage.trim()}\n' : ''}
          "You: ${event.text?.trim()}\nFriend:",
          // temperature: 0,
          maxTokens: 200,
          stop: 'You:',
          topP: 1,
          temperature: 0.5,
          frequencyPenalty: 0.5,
          presencePenalty: 0);
      List<int> codeUnits = result.choices[0].text.codeUnits;
      String completed = Utf8Decoder().convert(codeUnits);

      print(completed);
      lastMessage = completed;
      event.reply(completed);
    });
  } catch (e) {
    print('error');
  }
}

import Vapor
import telegram_vapor_bot

final class DefaultBotHandlers {

    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        self.defaultHandler(app: app, bot: bot)
        self.commandPingHandler(app: app, bot: bot)
        self.commandCatHandler(app: app, bot: bot)
    }

    private static func commandPingHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/ping"]) { update, bot in
            try update.message?.reply(text: "pong", bot: bot)
        }
        bot.connection.dispatcher.add(handler)
    }

    private static func defaultHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: (.all && !.command.names(["/ping"]))) { update, bot in
            // let params: TGSendMessageParams = .init(chatId: .chat(update.message!.chat.id), text: "Success")
            // try bot.sendMessage(params: params)
            if let mediaID = update.message?.photo?.last?.fileId {
                try? bot.getFile(params: TGGetFileParams(fileId: mediaID)).whenSuccess({ file in
                    guard let filePath = file.filePath else {
                        return
                    }
                    let url = "https://api.telegram.org/file/bot\(tgApi)/\(filePath)"
                    try? update.message?.reply(text: url, bot: bot)
                })
            }

        }
        bot.connection.dispatcher.add(handler)
    }

    private static func commandCatHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/cat"]) { update, bot in
            app.http.client.shared.get(url: "https://cat-fact.herokuapp.com/facts").whenSuccess { result in
                guard let body = result.body, let data = body.getData(at: 0, length: body.readableBytes) else {
                    return
                }
                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonArray = jsonResponse as? [[String: Any]],
                      let title = jsonArray.randomElement()?["text"] as? String else {
                      return
                }
                try? update.message?.reply(text: title, bot: bot)
            }
        }
        bot.connection.dispatcher.add(handler)
    }

//    private static func defaultBaseHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGBaseHandler({ update, bot in
//            guard let message = update.message else { return }
//            let params: TGSendMessageParams = .init(chatId: .chat(message.chat.id), text: "TGBaseHandler")
//            try await bot.sendMessage(params: params)
//        }))
//    }
//
//    private static func messageHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGMessageHandler(filters: (.all && !.command.names(["/ping", "/show_buttons"]))) { update, bot in
//            let params: TGSendMessageParams = .init(chatId: .chat(update.message!.chat.id), text: "Success")
//            try await bot.sendMessage(params: params)
//        })
//    }

//    private static func commandPingHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGCommandHandler(commands: ["/ping"]) { update, bot in
//            try await update.message?.reply(text: "pong", bot: bot)
//        })
//    }



//    private static func commandShowButtonsHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGCommandHandler(commands: ["/show_buttons"]) { update, bot in
//            guard let userId = update.message?.from?.id else { fatalError("user id not found") }
//            let buttons: [[TGInlineKeyboardButton]] = [
//                [.init(text: "Button 1", callbackData: "press 1"), .init(text: "Button 2", callbackData: "press 2")]
//            ]
//            let keyboard: TGInlineKeyboardMarkup = .init(inlineKeyboard: buttons)
//            let params: TGSendMessageParams = .init(chatId: .chat(userId),
//                                                    text: "Keyboard active",
//                                                    replyMarkup: .inlineKeyboardMarkup(keyboard))
//            try await bot.sendMessage(params: params)
//        })
//    }

//    private static func buttonsActionHandler(app: Vapor.Application, connection: TGConnectionPrtcl) async {
//        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "press 1") { update, bot in
//            TGBot.log.info("press 1")
//            let params: TGAnswerCallbackQueryParams = .init(
//                callbackQueryId: update.callbackQuery?.id ?? "0",
//                text: update.callbackQuery?.data  ?? "data not exist",
//                showAlert: nil,
//                url: nil,
//                cacheTime: nil
//            )
//            try await bot.answerCallbackQuery(params: params)
//        })
//
//        await connection.dispatcher.add(TGCallbackQueryHandler(pattern: "press 2") { update, bot in
//            TGBot.log.info("press 2")
//            let params: TGAnswerCallbackQueryParams = .init(
//                callbackQueryId: update.callbackQuery?.id ?? "0",
//                text: update.callbackQuery?.data  ?? "data not exist",
//                showAlert: nil,
//                url: nil,
//                cacheTime: nil
//            )
//            try await bot.answerCallbackQuery(params: params)
//        })
//    }
}

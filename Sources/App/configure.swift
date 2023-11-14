import Vapor
import TelegramVaporBot

let tgApi: String = "6304662378:AAEiM672Yqn4eXvxrK2C1G5u6oGUXj7EJao"

public func configure(_ app: Application) async throws {
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 80

    TGBot.log.logLevel = app.logger.logLevel

    let bot: TGBot = .init(app: app, botId: tgApi)
    let connection = try await TGLongPollingConnection(bot: bot)

    await DefaultBotHandlers.addHandlers(app: app, connection: connection)
    try await connection.start()

    try routes(app)
}

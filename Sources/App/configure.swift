import Vapor
import telegram_vapor_bot

let tgApi: String = "6304662378:AAEiM672Yqn4eXvxrK2C1G5u6oGUXj7EJao"

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 80

    let connection: TGConnectionPrtcl = TGLongPollingConnection()
    TGBot.configure(connection: connection, botId: tgApi, vaporClient: app.client)
    try TGBot.shared.start()
    TGBot.log.logLevel = .error
    DefaultBotHandlers.addHandlers(app: app, bot: TGBot.shared)

    try routes(app)
}

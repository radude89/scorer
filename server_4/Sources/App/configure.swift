import Vapor
import FluentSQLiteDriver
import Fluent

// configures your application
public func configure(_ app: Application) throws {

    app.server.configuration.port = 8080
    app.databases.use(.sqlite(.memory), as: .sqlite)
    
    app.migrations.add(Gather())
    app.migrations.add(Player())
    app.migrations.add(PlayerGather())
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}

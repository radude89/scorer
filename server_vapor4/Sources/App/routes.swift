import Vapor
import Fluent

func routes(_ app: Application) throws {
    let gatherController = GatherController()
    try app.routes.register(collection: gatherController)
    
    let playerController = PlayerController()
    try app.routes.register(collection: playerController)
}

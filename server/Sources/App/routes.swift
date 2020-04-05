import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let playerController = PlayerController()
    try router.register(collection: playerController)
    
    let gatherController = GatherController()
    try router.register(collection: gatherController)
    
    let gatherBFFController = GatherBFFController()
    try router.register(collection: gatherBFFController)
    
    let bulkController = BulkController()
    try router.register(collection: bulkController)
}

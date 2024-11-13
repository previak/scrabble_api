import Vapor

struct RoomController: RouteCollection, Sendable {
    private let roomService: RoomService
    
    init(roomService: RoomService) {
        self.roomService = roomService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let rooms = routes.grouped("rooms")
        
        rooms.get(":id", use: getRoom)
        rooms.post(use: createRoom)
        rooms.put(":id", use: updateRoom)
        rooms.delete(":id", use: deleteRoom)
    }
    
    @Sendable
    func getRoom(req: Request) throws -> EventLoopFuture<RoomDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid room ID.")
        }
        return roomService.getRoom(id: id, on: req)
    }
    
    @Sendable
    func createRoom(req: Request) throws -> EventLoopFuture<RoomDTO> {
        let room = try req.content.decode(RoomDTO.self)
        return roomService.createRoom(room: room, on: req)
    }
    
    @Sendable
    func updateRoom(req: Request) throws -> EventLoopFuture<RoomDTO> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid room ID.")
        }
        var room = try req.content.decode(RoomDTO.self)
        room.id = id
        return roomService.updateRoom(room: room, on: req)
    }
    
    @Sendable
    func deleteRoom(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid room ID.")
        }
        return roomService.deleteRoom(id: id, on: req).transform(to: .noContent)
    }
}

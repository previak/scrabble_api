import Vapor

protocol RoomService: Sendable {
    func getRoom(id: UUID, on req: Request) -> EventLoopFuture<RoomDTO>
    func createRoom(createRequest: CreateRoomRequestModel, on req: Request) -> EventLoopFuture<CreateRoomResponseModel>
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO>
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void>
    func joinRoom(joinRequest: JoinRoomRequestModel, on req: Request) -> EventLoopFuture<Void>
}

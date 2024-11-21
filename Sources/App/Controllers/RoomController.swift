import Vapor


struct RoomController: RouteCollection, Sendable {
    private let roomService: RoomService
    
    init(roomService: RoomService) {
        self.roomService = roomService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let rooms = routes.grouped("rooms")
        
        rooms.post("create", use: createRoom)
            .openAPI(
                summary: "Create room",
                description: "Create new room and join it, becoming it's admin",
                body: .type(CreateRoomRequestDTO.self),
                response: .type(CreateRoomResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
        rooms.post("join", use: joinRoom)
            .openAPI(
                summary: "Join room",
                description: "Join an existing room using the provided invitation code",
                body: .type(JoinRoomRequestDTO.self),
                response: .type(Response.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func createRoom(req: Request) throws -> EventLoopFuture<CreateRoomResponseDTO> {
        let request = try req.content.decode(CreateRoomRequestDTO.self)
        
        let createRoomRequest = CreateRoomRequestModel(
            userId: request.userId,
            isOpen: request.isOpen,
            isPublic: request.isPublic,
            adminNickname: request.adminNickname
        )
        
        return roomService
            .createRoom(createRequest: createRoomRequest, on: req)
            .map { responseModel in
                CreateRoomResponseDTO(
                    adminUserId: responseModel.adminUserId,
                    invitationCode: responseModel.invitationCode
                )
            }
    }
    
    @Sendable
    func joinRoom(req: Request) throws -> EventLoopFuture<Response> {
        let request = try req.content.decode(JoinRoomRequestDTO.self)
        
        let joinRoomRequest = JoinRoomRequestModel(
            userId: request.userId,
            invitationCode: request.invitationCode,
            nickname: request.nickname
        )
        
        return roomService.joinRoom(joinRequest: joinRoomRequest, on: req).map{_ in
            return Response(statusCode: HTTPResponseStatus.ok)
        }
    }
}

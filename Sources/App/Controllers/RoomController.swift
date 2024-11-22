import Vapor


struct RoomController: RouteCollection, Sendable {
    private let roomService: RoomService
    private let userService: UserService

    
    init(
        roomService: RoomService,
        userService: UserService) {
        self.roomService = roomService
        self.userService = userService
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
        
        rooms.get("list", use: getPublicRooms)
            .openAPI(
                summary: "Rooms list",
                description: "Get list of all public rooms",
                response: .type(GetRoomsListResponseDTO.self),
                auth: .apiKey(), .bearer()
            )
        
        rooms.post("kick", use: kickPlayer)
            .openAPI(
                summary: "Kick player",
                description: "Kick player from room",
                body: .type(KickPlayerRequestDTO.self),
                response: .type(Response.self),
                auth: .apiKey(), .bearer()
            )
    }
    
    @Sendable
    func createRoom(req: Request) throws -> EventLoopFuture<CreateRoomResponseDTO> {
        let request = try req.content.decode(CreateRoomRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let createRoomRequest = CreateRoomRequestModel(
                userId: user.id!,
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
    }
    
    @Sendable
    func joinRoom(req: Request) throws -> EventLoopFuture<Response> {
        let request = try req.content.decode(JoinRoomRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { user in
            let joinRoomRequest = JoinRoomRequestModel(
                userId: user.id!,
                invitationCode: request.invitationCode,
                nickname: request.nickname
            )
            
            return roomService.joinRoom(joinRequest: joinRoomRequest, on: req).map{_ in
                return Response(statusCode: HTTPResponseStatus.ok)
            }
        }
    }
    
    @Sendable
    func getPublicRooms(req: Request) throws -> EventLoopFuture<GetRoomsListResponseDTO> {
        return roomService.getPublicRooms(on: req).flatMap{response in
            let responseDTO = GetRoomsListResponseDTO(rooms: response.rooms.map{ model in
                RoomInfoDTO(invitationCode: model.invitationCode, players: model.players)
            })
            
            return req.eventLoop.makeSucceededFuture(responseDTO)
        }
    }
    

    @Sendable
    func kickPlayer(req: Request) throws -> EventLoopFuture<Response> {
        let request = try req.content.decode(KickPlayerRequestDTO.self)
        
        let authHeader = req.headers.bearerAuthorization!
        let token = authHeader.token
        
        return userService.authenticate(jwt: token, on: req).flatMap { adminUser in
            let kickPlayerRequest = KickPlayerRequestModel(
                adminId: adminUser.id!,
                nickname: request.nickname
            )
            
            return self.roomService.kickPlayer(kickPlayerRequest: kickPlayerRequest, on: req).map {
                return Response(statusCode: HTTPResponseStatus.ok)
            }
        }
    }
}

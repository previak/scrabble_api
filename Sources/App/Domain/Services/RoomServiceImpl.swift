import Vapor

final class RoomServiceImpl: RoomService, Sendable {
    private let roomRepository: RoomRepository
    private let playerRepository: PlayerRepository
    
    init(roomRepository: RoomRepository, playerRepository: PlayerRepository) {
        self.roomRepository = roomRepository
        self.playerRepository = playerRepository
    }
    
    func getRoom(id: UUID, on req: Request) -> EventLoopFuture<RoomDTO> {
        return roomRepository.find(id: id, on: req).flatMapThrowing { room in
            guard let room = room else {
                throw Abort(.notFound)
            }
            return room.toDTO()
        }
    }
    
    func createRoom(createRequest: CreateRoomRequestModel, on req: Request) -> EventLoopFuture<CreateRoomResponseModel> {
        // Step 1: Create the room
        let roomRepositoryRequest = CreateRoomRequest(
            adminUserId: createRequest.userId,
            isOpen: createRequest.isOpen,
            isPublic: createRequest.isPublic
        )
        
        return roomRepository.create(createRequest: roomRepositoryRequest, on: req).flatMap { roomResponse in
            
            roomResponse.$admin.load(on: req.db).flatMap { _ in
                let admin = roomResponse.admin
                
                
                let createPlayerRequest = CreatePlayerRequest(
                    userId: createRequest.userId,
                    roomId: roomResponse.id!,
                    nickname: createRequest.adminNickname
                )
                
                return self.playerRepository.create(createRequest: createPlayerRequest, on: req).map { _ in
                    return CreateRoomResponseModel(
                        adminUserId: admin.id!,
                        roomId: roomResponse.id!,
                        invitationCode: roomResponse.invitationCode
                    )
                }
            }
        }
    }


    
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO> {
        let model = room.toModel()
        return roomRepository.update(room: model, on: req).map { $0.toDTO() }
    }
    
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return roomRepository.delete(id: id, on: req)
    }
}

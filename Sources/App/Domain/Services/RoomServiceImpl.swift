import Vapor
import Fluent

final class RoomServiceImpl: RoomService {
    private let roomRepository: RoomRepository
    private let playerRepository: PlayerRepository
    
    init(roomRepository: RoomRepository, playerRepository: PlayerRepository) {
        self.roomRepository = roomRepository
        self.playerRepository = playerRepository
    }
    
    func joinRoom(joinRequest: JoinRoomRequestModel, on req: Vapor.Request) -> EventLoopFuture<Void> {
        return roomRepository.find(invitationCode: joinRequest.invitationCode, on: req).flatMapThrowing { room in
            guard let room = room else {
                throw Abort(.notFound, reason: "Room with invitation code \(joinRequest.invitationCode) not found.")
            }
            
            let createPlayerRequest = CreatePlayerRequest(
                userId: joinRequest.userId,
                roomId: room.id!,
                nickname: joinRequest.nickname
            )
            
            _ = self.playerRepository.create(createRequest: createPlayerRequest, on: req)
            return
        }
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
    
    func getPublicRooms(on: Request) -> EventLoopFuture<GetRoomsListResponseModel> {
        return Room
            .query(on: on.db)
            .filter(\.$isPublic == true)
            .all()
            .flatMap { rooms in
                let roomInfoFutures = rooms.map { room in
                    self.getRoomMemberCount(roomId: room.id!, on: on.db).map { memberCount in
                        RoomInfoModel(invitationCode: room.invitationCode, players: memberCount)
                    }
                }

                return roomInfoFutures.flatten(on: on.eventLoop).map { roomInfoModels in
                    GetRoomsListResponseModel(rooms: roomInfoModels)
                }
            }
    }

    private func getRoomMemberCount(roomId: UUID, on: Database) -> EventLoopFuture<Int> {
        return Player
            .query(on: on)
            .filter(\Player.$room.$id == roomId)
            .count()
    }


    
    func updateRoom(room: RoomDTO, on req: Request) -> EventLoopFuture<RoomDTO> {
        let model = room.toModel()
        return roomRepository.update(room: model, on: req).map { $0.toDTO() }
    }
    
    func deleteRoom(id: UUID, on req: Request) -> EventLoopFuture<Void> {
        return roomRepository.delete(id: id, on: req)
    }
    

    func kickPlayer(adminUserId: UUID, playerNicknameToKick: String, on req: Request) -> EventLoopFuture<Void> {
        return Room.query(on: req.db)
            .filter(\.$admin.$id == adminUserId)
            .first()
            .flatMap { adminRoom in
                guard let adminRoom = adminRoom else {
                    return req.eventLoop.makeFailedFuture(Abort(.forbidden, reason: "You are not an admin of any room"))
                }
                
                // Find the player by nickname in the admin's room
                return self.playerRepository.findByNicknameAndRoomId(
                    nickname: playerNicknameToKick,
                    roomId: adminRoom.id!,
                    on: req
                ).flatMap { playerToKick in
                    guard let playerToKick = playerToKick else {
                        return req.eventLoop.makeFailedFuture(Abort(.notFound, reason: "Player not found"))
                    }
                    
                    // Remove the player
                    return self.playerRepository.delete(playerToKick, on: req)
                }
            }
    }


}

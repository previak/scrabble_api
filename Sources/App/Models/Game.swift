//
//  Game.swift
//  ScrabbleAPI
//
//  Created by Danil Kunashev on 10.11.2024.
//

import Vapor
import Fluent
import struct Foundation.UUID


final class Game: Model, @unchecked Sendable {
    static let schema = "games"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "room_id")
    var room: Room
    
    @Field(key: "is_paused")
    var isPaused: Bool
    
    init() {}
    
    init(id: UUID, room: Room, isPaused: Bool) {
        self.id = id
        self.room = room
        self.isPaused = isPaused
    }
    
    func toDTO() -> GameDTO {
        .init(id: self.id,
              room: self.room,
              isPaused: self.isPaused
        )
    }
}

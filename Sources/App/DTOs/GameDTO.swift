//
//  GameDTO.swift
//  ScrabbleAPI
//
//  Created by Danil Kunashev on 10.11.2024.
//

import Fluent
import Vapor

public struct GameDTO: Codable {
    var id: UUID?
    var room: Room
    var isPaused: Bool
    
    func toModel() -> Game {
        let model = Game()
        
        if let id {
            model.id = id
        }
        
        model.room = room
        model.isPaused = isPaused
        
        return model
    }
}

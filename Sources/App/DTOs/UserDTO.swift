//
//  UserDTO.swift
//  ScrabbleAPI
//
//  Created by Danil Kunashev on 10.11.2024.
//

import Fluent
import Vapor

public struct UserDTO: Codable {
    var id: UUID?
    var username: String
    var password_hash: String
    var api_key: String
    
    func toModel() -> User {
        let model = User()
        
        if let id = id {
            model.id = id
        }
        
        model.username = username
        model.password_hash = password_hash
        model.api_key = api_key
        
        return model
    }
}

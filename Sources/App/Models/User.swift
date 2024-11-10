//
//  User.swift
//  ScrabbleAPI
//
//  Created by Danil Kunashev on 10.11.2024.
//

import Fluent
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "api_key")
    var apiKey: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, passwordHash: String, apiKey: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.apiKey = apiKey
    }
    
    func toDTO() -> UserDTO {
        .init(id: self.id,
              username: self.username,
              passwordHash: self.passwordHash,
              apiKey: self.apiKey
        )
    }
}

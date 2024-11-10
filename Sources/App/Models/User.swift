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
    var password_hash: String
    
    @Field(key: "api_key")
    var api_key: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password_hash: String, api_key: String) {
        self.id = id
        self.username = username
        self.password_hash = password_hash
        self.api_key = api_key
    }
    
    func toDTO() -> UserDTO {
        .init(id: self.id,
              username: self.username,
              password_hash: self.password_hash,
              api_key: self.api_key
        )
    }
}

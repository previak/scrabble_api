import JWT
import Vapor

struct UserJWTPayload: JWTPayload {
    var id: UUID
    var username: String
    var exp: ExpirationClaim
    
    init(id: UUID, username: String, expiration: Date) {
        self.id = id
        self.username = username
        self.exp = ExpirationClaim(value: expiration)
    }
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

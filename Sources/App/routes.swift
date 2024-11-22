import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    // http://127.0.0.1:8080/swagger/
    app.get("swagger") { req in
      req.application.routes.openAPI(
        info: InfoObject(
          title: "Scrabble API",
          description: "Custom API for Scrabble game implementation",
          version: "0.0.1"
        )
      )
    }
    .excludeFromOpenAPI()
}

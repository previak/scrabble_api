import Fluent
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    app.get("Swagger", "swagger.json") { req in
      req.application.routes.openAPI(
        info: InfoObject(
          title: "Example API",
          description: "Example API description",
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()
}

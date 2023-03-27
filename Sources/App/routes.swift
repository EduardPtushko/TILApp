import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
//    app.get("api", "acronyms", "search") { req async throws -> [Acronym] in
//        guard let searchTerm = req.query[String.self, at: "term"] else {
//            throw Abort(.badRequest)
//        }
//        return try await Acronym.query(on: req.db)
//            .filter(\.$short == searchTerm)
//            .all()
//    }

//    app.post("api", "acronyms") { req async throws -> Acronym in
//        let acronym = try req.content.decode(Acronym.self)
//        try await acronym.create(on: req.db)
//        return acronym
//    }
    
//    app.get("api", "acronyms") { req async throws -> [Acronym] in
//        let acronyms = try await Acronym.query(on: req.db).all()
//
//        return acronyms
//    }
    
    
//    app.get("api", "acronyms", "first") { req async throws -> Acronym in
//        guard  let acronym = try await Acronym.query(on: req.db).first() else {
//            throw Abort(.notFound)
//        }
//        return acronym
//    }
    
//    app.get("api", "acronyms", "sorted") { req async throws -> [Acronym] in
//        return try await Acronym.query(on: req.db)
//            .sort(\.$short, .ascending)
//            .all()
//    }
    
//    app.get("api", "acronyms", ":acronymID") { req async throws -> Acronym in
//        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
//            throw Abort(.notFound)
//        }
//        
//        guard  let acronym = try await Acronym.find(acronymID, on: req.db) else {
//            throw Abort(.notFound)
//        }
//        
//        return acronym
//    }
    
//    app.put("api", "acronyms", ":acronymID") { req async throws -> Acronym in
//        let updatedAcronym = try req.content.decode(Acronym.self)
//        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
//            throw Abort(.notFound)
//        }
//        
//        guard  let acronym = try await Acronym.find(acronymID, on: req.db) else {
//            throw Abort(.notFound)
//        }
//        acronym.short = updatedAcronym.short
//        acronym.long = updatedAcronym.long
//        try await acronym.update(on: req.db)
//        return acronym
//    }

//    app.delete("api", "acronyms", ":acronymID") { req async throws -> HTTPStatus in
//        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
//            throw Abort(.badRequest)
//        }
//
//        guard  let acronym = try await Acronym.query(on: req.db)
//            .filter(\.$id == acronymID)
//            .first()
//        else {
//            throw Abort(.notFound)
//        }
//
//        try await acronym.delete(on: req.db)
//        return .noContent
//    }
    
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
}

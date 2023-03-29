//
//  File.swift
//  
//
//  Created by Eduard on 27.03.2023.
//

import Foundation
import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoriesHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategoriesHandler)
        acronymsRoutes.delete(":acronymID", "categories", ":categoryID", use: removeCategoriesHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [Acronym] {
        return try await Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) async throws -> Acronym {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        try await acronym.create(on: req.db)
        return acronym
    }
    
    func getHandler(_ req: Request) async throws -> Acronym {
        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        guard  let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return acronym
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym {
        let updatedData = try req.content.decode(CreateAcronymData.self)
        
        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        guard  let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        acronym.short = updatedData.short
        acronym.long = updatedData.long
        acronym.$user.id = updatedData.userID
        try await acronym.update(on: req.db)
        return acronym
    }
    
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard  let acronym = try await Acronym.query(on: req.db)
            .filter(\.$id == acronymID)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        try await acronym.delete(on: req.db)
        return .noContent
    }
    
    func searchHandler(_ req: Request) async throws -> [Acronym] {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return try await Acronym.query(on: req.db)
            .filter(\.$short == searchTerm)
            .all()
    }
    
    
    func getFirstHandler(_ req: Request) async throws -> Acronym {
        guard  let acronym = try await Acronym.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        return acronym
    }
    
    func sortedHandler(_ req: Request) async throws -> [Acronym] {
        return try await Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req: Request) async throws -> User {
        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        guard let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let user = try await acronym.$user.get(on: req.db)
        
        return user
    }
    
    func addCategoriesHandler(_ req: Request) async throws ->  HTTPStatus {
        guard let acronymQuery = try await
                Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            
            throw Abort(.notFound)
        }
        guard let categoryQuery = try await
                Category.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await acronymQuery.$categories
            .attach(categoryQuery, on: req.db)
        
        return .created
    }
    
    func getCategoriesHandler(_ req: Request) async throws -> [Category] {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let categories = try await acronym.$categories.get(on: req.db)
        return categories
    }
    func removeCategoriesHandler(_ req: Request) async throws ->  HTTPStatus {
        guard let acronymQuery = try await
                Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            
            throw Abort(.notFound)
        }
        guard let categoryQuery = try await
                Category.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await acronymQuery.$categories
            .detach(categoryQuery, on: req.db)
        
        return .noContent
    }

}

struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID
}

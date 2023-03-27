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
        acronymsRoutes.delete("search", use: searchHandler)
        acronymsRoutes.delete("first", use: getFirstHandler)
        acronymsRoutes.delete("sorted", use: sortedHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [Acronym] {
      return try await Acronym.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) async throws -> Acronym {
        let acronym = try req.content.decode(Acronym.self)
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
        let updatedAcronym = try req.content.decode(Acronym.self)
        guard let acronymID = req.parameters.get("acronymID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        guard  let acronym = try await Acronym.find(acronymID, on: req.db) else {
            throw Abort(.notFound)
        }
        acronym.short = updatedAcronym.short
        acronym.long = updatedAcronym.long
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
}

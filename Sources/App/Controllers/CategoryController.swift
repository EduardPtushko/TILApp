//
//  File.swift
//  
//
//  Created by Eduard on 28.03.2023.
//

import Foundation
import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoute = routes.grouped("api", "categories")
        
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(":categoryID", use: getHandler)
        categoriesRoute.get(":categoryID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) async throws -> Category {
        let category = try req.content.decode(Category.self)
        try await category.create(on: req.db)
        return category
    }
    
    func getAllHandler(_ req: Request) async throws -> [Category] {
        
        return try await Category.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> Category {
        guard let categoryID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard  let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return category
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        guard let categoryID = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard  let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound)
        }
        let acronyms = try await category.$acronyms.get(on: req.db)
        return acronyms
    }
}

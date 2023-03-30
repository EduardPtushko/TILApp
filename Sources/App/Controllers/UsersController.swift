//
//  File.swift
//  
//
//  Created by Eduard on 27.03.2023.
//

import Foundation
import Vapor

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get("first", use: getFirstHandler)
        usersRoute.get(":userID", use: getHandler)
        usersRoute.delete(":userID", use: deleteHandler)
        usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)
    }
    
    func createHandler(_ req: Request) async throws -> User  {
        let user = try req.content.decode(User.self)
        
        let users = try await User.query(on: req.db).all()
        
        try await user.create(on: req.db)
        return user
        
    }
    
    func getAllHandler(_ req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request) async throws -> User {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        guard  let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return user
    }
    
    func deleteHandler(_ req: Request) async throws -> HTTPStatus {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        guard  let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await user.delete(on: req.db)
        
        return .noContent
    }
    
    func getAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        guard  let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let acronyms = try await user.$acronyms.get(on: req.db)
        
        return acronyms
    }
    
    func getFirstHandler(_ req: Request) async throws -> User {
        guard  let user = try await User.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        return user
    }
    
}



enum UserError {
    case usernameAlreadyExist(String)
    case userNotLoggedIn
    case invalidEmail(String)
}

extension UserError: AbortError {
    var reason: String {
        switch self {
            case .userNotLoggedIn:
                return "User is not logged in."
            case .invalidEmail(let email):
                return "Email address is not valid: \(email)."
            case .usernameAlreadyExist(let name):
                return "User with username \(name) already exists."
        }
    }
    
    var status: HTTPStatus {
        switch self {
            case .userNotLoggedIn:
                return .unauthorized
            case .invalidEmail:
                return .badRequest
            case .usernameAlreadyExist:
                return .conflict
                
        }
    }
}

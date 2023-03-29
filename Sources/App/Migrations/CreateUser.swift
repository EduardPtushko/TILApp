//
//  File.swift
//  
//
//  Created by Eduard on 27.03.2023.
//

import Fluent
import Vapor

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await  database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}

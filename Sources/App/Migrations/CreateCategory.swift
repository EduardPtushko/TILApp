//
//  File.swift
//  
//
//  Created by Eduard on 28.03.2023.
//

import Foundation
import Fluent
import Vapor

struct CreateCategory: AsyncMigration {
    func revert(on database: FluentKit.Database) async throws {
      try await  database.schema("categories").delete()
    }
    
    func prepare(on database: Database) async throws {
        try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .create()
    }
    
    
}

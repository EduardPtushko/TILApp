//
//  File.swift
//  
//
//  Created by Eduard on 22.03.2023.
//

import Vapor
import Fluent

struct CreateAcronym: AsyncMigration {

  func prepare(on database: Database) async throws {
    try await database.schema("acronyms")
      .id()
      .field("short", .string, .required)
      .field("long", .string, .required)
      .field("userID", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: Database) async throws {
      try await  database.schema("acronyms").delete()
  }
}

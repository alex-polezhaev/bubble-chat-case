//
//  ImageController.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 22.12.2024.
//

import Vapor

struct ImageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let images = routes.grouped("images") // Group routes under /images
        images.get(":filename", use: getImage) // GET /images/:filename
    }

    func getImage(req: Request) async throws -> Response {
        // Get the file name from the request parameter
        guard let filename = req.parameters.get("filename") else {
            throw Abort(.badRequest, reason: "Filename is required.")
        }

        // Determine the file path in the Public folder
        let path = req.application.directory.publicDirectory + filename

        // Check whether the file exists
        guard FileManager.default.fileExists(atPath: path) else {
            throw Abort(.notFound, reason: "File \(filename) not found.")
        }

        // Read the file and return it as the response
        let file = try await req.fileio.streamFile(at: path)
        return file
    }
}

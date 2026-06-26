//
//  ValidationError.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 27.11.2024.
//

// Example of validation errors
enum ValidationError: Error {
    case invalidField(String = #function)
}

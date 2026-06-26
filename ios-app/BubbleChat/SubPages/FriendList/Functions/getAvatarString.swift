//
//  getAvatarString.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 06.10.2024.
//

func getAvatarString(from input: String) -> String {
    // Split the string into words
    let words = input.split(separator: " ")

    // If there are no words, return an empty string
    if words.isEmpty {
        return ""
    }

    // If there is only one word, return its first letter
    if words.count == 1 {
        return words[0].first.map { String($0) } ?? ""
    }

    // If there is more than one word, return the first letters of the first two words
    let firstChar1 = words[0].first.map { String($0) } ?? ""
    let firstChar2 = words[1].first.map { String($0) } ?? ""

    return firstChar1 + firstChar2
}

//
//  Crumb.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import Foundation

struct Crumb: Identifiable, Hashable {

    struct Tag: Identifiable, Hashable {
        var id: String { text }
        let text: String
    }

    typealias ID = String
    var id: String { location.string }

    var raw: String
    var prefix: String
    var text: String
    var tags: [Tag]
    var priority: UInt?

    var location: Location

    var preview: String

    struct Location: Identifiable, Hashable {
        var id: String { "\(fileID):\(line)" }

        let fileURL: URL
        let fileID: String
        let line: UInt

        var string: String {
            "\(fileURL.path): \(line)"
        }
    }

    private static func extractHashtags(from string: String) -> (String, [String], UInt?) {
        var string = string
        var tags = [String]()
        var priority: UInt?

        let words = string.components(
            separatedBy: .punctuationCharacters
                .subtracting(CharacterSet(["#"]))
                .union(.whitespacesAndNewlines)
        )
        for word in words{
            if word.hasPrefix("#") {
                let tag = word.dropFirst()
                if (tag.hasPrefix("p") || tag.hasPrefix("P")), let number = UInt(tag.dropFirst()) {
                    priority = number
                } else {
                    tags.append(String(tag))
                }
                string = string
                    .replacingOccurrences(of: "\(word) ", with: "") // TODO: handle whitespace more cleverly
                    .replacingOccurrences(of: word, with: "")
            }
        }
        return (string.trimmingCharacters(in: .whitespacesAndNewlines), tags, priority)
    }

    init(text: String, prefix: String, location: Location) {
        self.raw = text
        self.prefix = prefix
        
        let (text, tags, priority) = Self.extractHashtags(
            from: String(
                text.components(separatedBy: prefix)[1].trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )

        self.text = text
        self.tags = tags.map(Tag.init(text:))
        self.priority = priority
        self.location = location

        self.preview = Self.code(at: location)
    }

    static func code(at location: Crumb.Location) -> String {
        let text = try? FileSource(location: location)
            .lines(max: 10)
            .map(\.text)
            .joined()

        return text ?? "Code not found"
    }

}

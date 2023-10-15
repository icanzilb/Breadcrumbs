//
//  FileSource.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import Foundation

class FileSource {
    struct Line {
        let number: UInt
        let text: String
    }

    let location: Crumb.Location

    let contents: [String]

    init(location: Crumb.Location) throws {
        self.location = location
        self.contents = try String(contentsOf: location.fileURL).components(separatedBy: .newlines)
    }

    func lines(max: UInt) -> [Line] {
        var result = [Line]()
        for number in (location.line-1)...(location.line+max) where number < contents.count {
            result.append(
                Line(number: number, text: contents[Int(number)].appending("\n"))
            )
        }
        return result
    }
}

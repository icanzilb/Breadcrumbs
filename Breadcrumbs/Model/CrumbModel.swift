//
//  CrumbModel.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/15/23.
//

import SwiftUI

class CrumbModel: ObservableObject {
    var categories: [CrumbCategory] = [] {
        didSet {
            loadResults()
        }
    }

    @Published var results: [CrumbCategory] = []

    var searchQuery = "" {
        didSet {
            loadResults()
        }
    }

    @Published var url: URL?

    func crumb(withID: Crumb.ID) -> Crumb? {
        for category in categories {
            for crumb in category.children ?? [] {
                if crumb.id == withID {
                    return crumb
                }
            }
        }
        return nil
    }

    @Published var isLoading = false {
        didSet {
            if isLoading {
                fileCount = 0
            }
        }
    }
    @Published var fileCount = 0

    @Published var selection: Crumb.ID?

    var isEmpty: Bool {
        results.allSatisfy({ $0.children?.isEmpty == true })
    }

    init() {

    }

    @MainActor
    private func updateModelWith(categories: [CrumbCategory], url: URL) {
        self.categories = categories
        self.url = url
        if selection == nil, let firstCrumb = categories.first?.children?.first {
            selection = firstCrumb.id
        }
        isLoading = false
        print("Loaded \(url.path)")
    }

    func load(url: URL) throws {
        isLoading = true
        categories = []
        results = []
        
        Task {
            var categories: [CrumbCategory] = [
                CrumbCategory(name: "TODO", prefix: "// TODO: ", icon: "app.badge.checkmark.fill", tint: .indigo, children: []),
                CrumbCategory(name: "FIXIT", prefix: "// FIXIT: ", icon: "hammer.fill", tint: .mint, children: []),
            ]
            try loadCrumbs(
                in: &categories,
                fromFiles: url.fileURLs(in: url)
            )

            await updateModelWith(categories: categories, url: url)
        }
    }

    func reload() throws {
        guard let url else { return }
        try load(url: url)
    }

    func loadCrumbs(in categories: inout [CrumbCategory], fromFiles: [URL]) {
        for index in 0..<categories.count {
            if categories[index].children == nil {
                categories[index].children = []
            }
        }

        var crumbIDs = Set<String>()
        var count = 0

        for fileURL in fromFiles {
            count += 1
            if count % 10 == 0 {
                Task { @MainActor [count] in
                    fileCount = count
                }
            }
            guard let contents = try? String(contentsOf: fileURL).components(separatedBy: .newlines) else {
                continue
            }

            for (number, line) in contents.enumerated() {
                
                for (categoryIndex, category) in categories.enumerated() {
                    if line.contains(category.prefix) {
                        let newLocation = Crumb.Location(
                            fileURL: fileURL,
                            fileID: fileURL.path,
                            line: UInt(number)
                        )
                        if crumbIDs.contains(newLocation.string) {
                            print("Duplicate crumb")
                            continue
                        }
                        let newCrumb = Crumb(
                            text: line.trimmingCharacters(in: .whitespacesAndNewlines),
                            prefix: category.prefix,
                            location: newLocation
                        )
                        categories[categoryIndex].children!.append(newCrumb)
                        crumbIDs.insert(newCrumb.location.string)

                        // don't cycle other categories if the crumb is already added
                        continue
                    }
                }
            }
        }
    }

    func loadResults() {
        guard !searchQuery.isEmpty else {
            results = categories
            return
        }
        let query = searchQuery.lowercased()
        results = categories.map { category in
            var category = category
            if category.children != nil {
                category.children = category.children!.filter({ crumb in
                    crumb.raw.lowercased().contains(query)
                })
            }
            return category
        }
    }

    func positionForCrumbID(_ id: Crumb.ID?) -> (Int, Int)? {
        guard let id else { return nil }
        for (catIndex, category) in results.enumerated() {
            guard let children = category.children else { continue }
            for (crumbIndex, crumb) in children.enumerated() {
                if crumb.id == id {
                    return (catIndex, crumbIndex)
                }
            }
        }
        return nil
    }
}

struct FileError: Error {
    let message: String
}

extension URL {
    static let bigFileSize = 1_000_000

    var fileSize: Int {
        do {
            return try resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        } catch {
            return 0
        }
    }

    func fileURLs(in url: URL, withFileExtensions fileExtensions: Set<String>? = nil) throws -> [URL] {
        var files = [URL]()

        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            throw FileError(message: "Could not open folder at '\(url.path)'")
        }
        var isDirectory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw FileError(message: "'\(url.path)' is not a folder")
        }

        for case let fileURL as URL in enumerator {
            if let fileExtensions {
                guard fileExtensions.contains(fileURL.pathExtension) else { continue }
            }

            guard fileURL.fileSize < URL.bigFileSize else {
                continue
            }

            do {
                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                if let regularFile = fileAttributes.isRegularFile, regularFile {
                    files.append(fileURL)
                }
            } catch {
                // FIXIT: This is not a user error per se, add to a log?
            }
        }
        print("Discovered \(files.count) files")
        return files
    }
}

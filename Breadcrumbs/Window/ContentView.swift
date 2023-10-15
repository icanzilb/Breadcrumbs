import SwiftUI

extension URL {
    static let empty = URL(fileURLWithPath: "/")
}

struct ContentView: View {
    @AppStorage("lastURL") var lastURL: URL = .empty
    @EnvironmentObject var model: CrumbModel

    var body: some View {
        VStack {
            NavigationSplitView {
                SidebarView()
            } detail: {
                if let crumbID = model.selection, let crumb = model.crumb(withID: crumbID) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            CrumbDetailView(
                                crumb: crumb
                            )
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                } else {
                    EmptyView()
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        selectAndOpen()
                    }, label: {
                        Image(systemName: "externaldrive")
                    })
                    .keyboardShortcut(KeyEquivalent("o"), modifiers: .command)
                }
            })
        }
        .background(Color("DetailsBackground"))
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Text("Breadcrumbs").font(.headline)
                    .foregroundColor(Color("TitleColor"))
                    .offset(y: -1)
            }
        })
        .task {
            selectAndOpen()
        }
        .onReceive(model.$url, perform: { value in
            guard let value else { return }
            lastURL = value
        })
    }

    enum FailStrategy {
        case none, selectNew
    }

    func selectAndOpen() {
        if let url = Self.selectFolder(selected: lastURL != .empty ? lastURL : nil) {
            do {
                try model.load(url: url)
                lastURL = url
            } catch {
                lastURL = .empty
            }
        }
    }

    static func selectFolder(selected: URL? = nil) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select a project folder"
        if let selected {
            openPanel.directoryURL = selected
        }
        openPanel.allowedContentTypes = [.folder]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        guard openPanel.runModal() == .OK else {
            return nil
        }

        return openPanel.url
    }
}

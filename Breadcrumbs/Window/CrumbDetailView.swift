//
//  CrumbDetailView.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import SwiftUI
import STTextView

struct CrumbDetailView: View {
    @EnvironmentObject var model: CrumbModel
    let crumb: Crumb

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {

                HStack(alignment: .top) {
                    Text(crumb.location.fileURL.lastPathComponent + ": " + String(crumb.location.line))
                        .lineLimit(1)
                        .truncationMode(.head)
                        .foregroundColor(Color("SubTitleColor"))
                        .font(.title3)
                        .help(crumb.location.string)
                        .padding(.bottom, 26)

                    Spacer()

                    Button(action: {
                        guard let crumb = model.selection.flatMap(model.crumb(withID:)) else {
                            return
                        }
                        let process = Process()
                        process.launchPath = "/usr/bin/xcrun"
                        process.arguments = ["xed", "-l", "\(crumb.location.line + 1)", crumb.location.fileURL.path]
                        print("\(process.launchPath!) \(process.arguments!.joined(separator: " "))")
                        try? process.run()

                    }, label: {
                        Text("Open in Xcode").font(.callout)
                    })
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.return, modifiers: .command)
                    .shadow(color: .gray.opacity(0.5), radius: 1)
                }

                Text(crumb.text)
                    .font(.title2).padding(0)

                if !crumb.tags.isEmpty {
                    HStack(spacing: 4) {
                        if let priority = crumb.priority {
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.15)) {
                                    model.searchQuery = "#p\(priority)"
                                }
                            }, label: {

                                Text("Priority: \(priority)")
                                    .font(.callout.bold())
                                    .padding(2)
                                    .padding(.horizontal, 6)
                                    .background(priority == 1 ? .red.opacity(0.5) : .orange.opacity(0.5))
                                    .clipShape(Capsule())
                            })
                            .buttonStyle(.plain)
                        }

                        ForEach(crumb.tags) { tag in
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.15)) {
                                    model.searchQuery = "#\(tag.text)"
                                }
                            }, label: {
                                Text(tag.text)
                                    .font(.callout.bold())
                                    .padding(2)
                                    .padding(.horizontal, 6)
                                    .background(.mint.opacity(0.5))
                                    .clipShape(Capsule())
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 8)
                }

                Divider()
                    .padding(0)
                    .padding(.bottom, 8)

                VStack(alignment: .leading) {
                    CodeView(crumb: crumb)
                        .id(crumb.preview)
                }
                .background(Color("SidebarBackground"))
            }
            .padding()
        }
    }
}

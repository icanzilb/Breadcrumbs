//
//  SidebarView.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var model: CrumbModel

    enum Focus: Hashable {
        case none
        case search
    }

    @FocusState private var focus: Focus?

    @State var didLoad = false {
        didSet {
            if didLoad {
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    withAnimation(.easeIn(duration: 0.1)) {
                        didLoad = false
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                ScrollViewReader { reader in
                    ScrollView(.vertical) {
                        ForEach(model.results) { category in
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                    .renderingMode(.original)
                                    .foregroundColor(category.tint)

                                Text(category.name)
                                    .lineLimit(1)
                                    .bold().padding(2)

                                if category.children?.count ?? 0 > 0 {

                                    Text("\(category.children?.count ?? 0)")
                                        .foregroundColor(.gray)
                                        .font(.headline)
                                        .padding(2)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .onTapGesture(count: 2) {
                                guard let index = model.results.firstIndex(where: { $0.id == category.id }) else {
                                    return
                                }
                                model.results[index].displayContents.toggle()
                            }

                            if let children = category.children, category.displayContents {
                                ForEach(children) { crumb in
                                    CrumbRowView(crumb: crumb)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(content: {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(model.selection == crumb.id ? .blue.opacity(0.3) : Color("SidebarBackground"))
                                        })
                                        .frame(maxWidth: .infinity)
                                        .onTapGesture {
                                            model.selection = crumb.id
                                        }
                                }
                            }
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if !model.isEmpty {
                            VStack(spacing: -10) {
                                Button {
                                    guard let currentPosition = model.positionForCrumbID(model.selection) else {
                                        return
                                    }
                                    if currentPosition.1 > 0 {
                                        model.selection = model.results[currentPosition.0].children![currentPosition.1 - 1].id
                                        reader.scrollTo(model.selection!, anchor: .center)
                                    } else {
                                        NSSound.beep()
                                    }
                                } label: {
                                    Image(systemName: "chevron.up").font(.caption)
                                }
                                .scaleEffect(x: 0.67, y: 0.67)
                                .buttonStyle(.bordered)
                                .keyboardShortcut(.upArrow, modifiers: [])

                                Button {
                                    guard let currentPosition = model.positionForCrumbID(model.selection) else {
                                        return
                                    }
                                    if currentPosition.1 < model.results[currentPosition.0].children!.count - 1 {
                                        model.selection = model.results[currentPosition.0].children![currentPosition.1 + 1].id
                                        reader.scrollTo(model.selection!, anchor: .center)
                                    } else {
                                        NSSound.beep()
                                    }
                                } label: {
                                    Image(systemName: "chevron.down").font(.caption)
                                }
                                .scaleEffect(x: 0.67, y: 0.67)
                                .buttonStyle(.bordered)
                                .keyboardShortcut(.downArrow, modifiers: [])

                            }
                            .offset(y: 2)
                        }
                    }
                }

            }

            if model.isEmpty {
                Text("No crumbs found")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack {
                TextField("Search crumbs", text: $model.searchQuery)
                    .focused($focus, equals: .search)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 1)
                    .onChange(of: model.searchQuery, perform: { value in
                        if value.isEmpty {
                            DispatchQueue.main.async {
                                NSApp.keyWindow?.makeFirstResponder(nil)
                            }
                        }
                    })
                if !model.searchQuery.isEmpty || focus == .search {
                    Button {
                        withAnimation(.easeIn(duration: 0.25)) {
                            model.searchQuery = ""
                            defocus()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                }

            }
        }
        .padding(0)
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("SidebarBackground"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 2) {
                    Button {
                        guard !model.isLoading else { return }
                        Task {
                            do {
                                try model.reload()
                            } catch {}
                        }
                    } label: {
                        Image(systemName: model.isLoading ? "gearshape.arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath")
                    }
                    .keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
                    .opacity(model.isLoading ? 0.2 : 1.0)

                    if didLoad {
                        Text("Reloaded").font(.callout)
                    }

                    if model.isLoading {
                        Text("\(model.fileCount) files").font(.callout.monospacedDigit())
                        ProgressView().scaleEffect(x: 0.5, y: 0.5)
                    }
                    Spacer()
                }
                .onChange(of: model.isLoading) { _ in
                    if !model.isLoading {
                        Task {
                            didLoad = true
                            try? await Task.sleep(for: .seconds(1))
                            didLoad = false
                        }
                    }
                }
            }
        }
        .task {
            model.loadResults()
            defocus()
        }
    }

    func defocus() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }
}


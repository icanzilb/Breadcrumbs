//
//  CrumbRowView.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/15/23.
//

import SwiftUI

struct CrumbRowView: View {
    let crumb: Crumb
    var body: some View {
        HStack {
            Image(systemName: "chevron.right.square")
            Text(crumb.text)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

        }
        .font(.title3)
        .padding(2)
    }
}

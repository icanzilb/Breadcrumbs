//
//  CrumbTree.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import Foundation
import SwiftUI

struct CrumbCategory: Identifiable, Hashable {
    typealias ID = String
    
    var id: String { name }

    let name: String
    let prefixes: [String]
    let icon: String
    let tint: Color
    var children: [Crumb]? = nil

    var displayContents = true
}

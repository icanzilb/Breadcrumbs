//
//  CodeView.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import SwiftUI
import Firefly

struct CodeView: View {
    init(crumb: Crumb) {
        self.text = crumb.preview
    }

    @State var text: String

    @State var theme: String = NSApp.effectiveAppearance.name == .aqua ?  "Xcode Light" : "Xcode Dark"
    @State var fontName: String = "system"

    @State var update: Bool = false

    @State var dynamicGutter: Bool = false
    @State var gutterWidth: CGFloat = 40
    @State var placeholdersAllowed: Bool = false
    @State var linkPlaceholders: Bool = false
    @State var lineNumbers: Bool = false
    @State var fontSize: CGFloat = 13
    @State var cursorPosition: CGRect? = nil

    var body: some View {
        FireflySyntaxEditor(
            text: $text,
            language: .constant("Swift"),
            theme: $theme,
            fontName: $fontName,
            fontSize: $fontSize,
            dynamicGutter: $dynamicGutter,
            gutterWidth: $gutterWidth,
            placeholdersAllowed: $placeholdersAllowed,
            linkPlaceholders: $linkPlaceholders,
            lineNumbers: $lineNumbers,
            cursorPosition: $cursorPosition,
            isEditable: .constant(false),
            keyCommands: { return nil },
            didChangeText: { editor in

            },
            didChangeSelectedRange: { editor, range in

            },
            textViewDidBeginEditing: { editor in

            }
        )
    }
}

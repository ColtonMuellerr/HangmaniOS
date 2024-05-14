//
//  ViewModifiers.swift
//  hangman
//
//  Created by Colton Mueller on 4/30/24.
//

import SwiftUI

struct NavStackContainer: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content
            }
        } else {
            NavigationView {
                content
            }
            .navigationViewStyle(.stack)
        }
    }
}


extension View {
    public func inNavigationstack() -> some View {
        return self.modifier(NavStackContainer())
    }
}


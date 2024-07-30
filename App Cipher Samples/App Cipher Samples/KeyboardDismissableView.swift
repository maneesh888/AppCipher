//
//  DismissingKeyBoard.swift
//  App Cipher Samples
//
//  Created by Maneesh on 29/07/2024.
//

import SwiftUI

struct KeyboardDismissableView<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            content()
        }
    }
}

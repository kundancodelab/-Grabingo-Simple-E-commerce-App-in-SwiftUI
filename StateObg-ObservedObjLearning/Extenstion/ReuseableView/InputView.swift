//
//  CustomInputField.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 21/06/25.
//

import SwiftUI

struct InputView: View {
    let placeholder: String
    var isSecureField: Bool = false
    @Binding var text: String
    var height: CGFloat = 50
    
    var body: some View {
        VStack {
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding(.horizontal)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.5))
            )
        }
    }
}

#Preview {
    InputView(
        placeholder: "Email or Phone number",
        text: .constant("")
    )
}

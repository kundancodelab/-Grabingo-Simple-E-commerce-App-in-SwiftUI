//
//  TopToastView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI

struct TopToastView: View {
    var message: String
    var icon: String = "checkmark.circle.fill"
    var backgroundColor: Color = .green

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(message)
                    .foregroundColor(.white)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .transition(.move(edge: .top))

            Spacer()
        }
        .zIndex(1)
    }
}

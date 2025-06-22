//
//  CustomLoader.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI

struct CustomLoader: View {
    var loadingMessage:String = "Loading..."
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                ProgressView(loadingMessage)
                    .frame(width: 80, height: 60, alignment: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .font(.headline)

            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
        }
    }
}

#Preview {
    CustomLoader()
}

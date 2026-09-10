//
//  AsyncImg.swift
//  Altfolio
//
//  Created by Danila on 04.11.2022.
//

import SwiftUI

struct AsyncImg: View {
    var url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(.circular)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .padding(.leading, 5)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
            case .failure:
                Text("Failed")
                    .foregroundColor(.red)
            @unknown default:
                Text("Failed")
                    .foregroundColor(.red)
            }
        }
        .frame(width: 45.0, height: 45.0)
    }
}

struct AsyncImg_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImg(url: "https://upload.wikimedia.org/wikipedia/commons/4/46/Bitcoin.svg")
    }
}

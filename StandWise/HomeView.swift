//
//  HomeView.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                Text("Hello,")
                    .font(Font.title)
                Text("Peter Tan")
                    .font(Font.title.bold())

                Spacer()
            }
            .padding(20)
            .background(Color(.systemGray6))
            
        }
    }
}

#Preview {
    HomeView()
}

//
//  UserListView.swift
//  Auraplus
//
//  Created by Hussnain on 6/4/25.
//

import SwiftUI

struct UserListView: View {

    var body: some View {
        HStack{
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 45))
                
            VStack(alignment: .leading){
                
                Text("John Doe")
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                
                Text("@johndoe")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    UserListView()
}

//
//  EditProfileView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI

struct EditProfileView: View {
    @State var name: String = "John Doe"
    var body: some View {
        NavigationStack{
            List{
                Section{
                    HStack{
                        VStack(alignment: .leading, spacing: 2){
                            HStack{
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 50))
                                Text("Edit your name and add an optional profile picture")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .padding(.top, 4)
                                    .padding()
                            }
                            HStack{
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.leading,18)
                                    
                            }
                        }
                    }
                    VStack{
                        InputView(text: $name, title: "", placeholder: name)
                            .padding(.top,-18)
                            .padding(.bottom, 5)
                        Button {
                            
                        } label: {
                            Text("Confirm")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                                .padding(5)
                        }
                    }
                        
                    
                }
            }
        }
        Spacer()
        
        
        
    }
    
}

#Preview {
    EditProfileView()
}

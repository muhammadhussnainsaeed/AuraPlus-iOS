//
//  SettingsView.swift
//  Auraplus
//
//  Created by Hussnain on 8/3/25.
//

import SwiftUI

struct SettingsView: View {
    @State var user: String = ""
    @State var password: String = ""
    @State private var searchText = ""
    var body: some View {
        NavigationStack{
            List{
                Section{
                    NavigationLink{
                        EditProfileView()
                    }
                    label:{
                        HStack{
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 50))
                                
                            VStack(alignment: .leading,
                                   spacing: 2){
                                
                                Text("John Doe")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text("@johndoe")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                                   .padding(.horizontal,3)
                        }
                    }
                }
                Section("Account"){
                    
                    NavigationLink{
                        NewPasswordView()
                    }
                    label:{
                        SettingItemView(title: "Account",
                                        icon: "key.fill", color: .green)
                    }
                    NavigationLink{
                        
                    }
                    label:{
                        SettingItemView(title: "Logout",
                                        icon: "exclamationmark.triangle.fill", color: .red)
                    }
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
        }
    }
}

#Preview {
    SettingsView()
}

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
    var body: some View {
        NavigationStack{
            List{
                Section{
                    HStack{
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 55))
                            
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
                Section("Account"){
                    SettingItemView(title: "Account",
                                    icon: "key.fill", color: .green)
                    
                    SettingItemView(title: "Logout",
                                    icon: "exclamationmark.triangle.fill", color: .red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

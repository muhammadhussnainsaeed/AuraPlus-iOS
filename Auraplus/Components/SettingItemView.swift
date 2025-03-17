//
//  SettingItemView.swift
//  Auraplus
//
//  Created by Hussnain on 9/3/25.
//

import SwiftUI

struct SettingItemView: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18,height: 18)
                .padding(6)
                .foregroundColor(.white)
                .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(title)
                .font(.system(size: 18))
            
            Spacer()
            
        }
    }
}

#Preview {
    SettingItemView(title: "Test", icon: "lock.fill", color: .blue)
}

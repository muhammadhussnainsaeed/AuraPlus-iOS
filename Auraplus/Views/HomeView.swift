//
//  HomeView.swift
//  Auraplus
//
//  Created by Hussnain on 11/3/25.
//

import SwiftUI

struct HomeView: View {
    init(){
        let thumbImage = UIImage(systemName: "circle.fill")!
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    var body: some View {
        TabView{
            ChatsView()
                .tabItem{
                    Image(systemName: Tab.chats.icon)
                    Text(Tab.chats.title)
                }
            
            SettingsView()
                .tabItem{
                    Image(systemName: Tab.settings.icon)
                    Text(Tab.settings.title)
                }
        }
        .background(.white)
    }
}

extension HomeView {
    private enum Tab: String {
        case chats, settings

        fileprivate var title: String {
            return rawValue.capitalized
        }

        fileprivate var icon: String {
            switch self {
            case .chats:
                return "message"
            case .settings:
                return "gear"
            }
        }
    }
}

#Preview {
    HomeView()
}

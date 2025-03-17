//
//  HomeView.swift
//  Auraplus
//
//  Created by Hussnain on 11/3/25.
//

import SwiftUI

struct HomeView: View {
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

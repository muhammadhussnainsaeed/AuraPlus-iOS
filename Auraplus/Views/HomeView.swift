//
//  HomeView.swift
//  Auraplus
//
//  Created by Hussnain on 11/3/25.
//

import SwiftUICore
import UIKit
import SwiftUI

struct HomeView: View {
    init() {
        let thumbImage = UIImage(systemName: "circle.fill")!
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    var body: some View {
        VStack{
            NavigationStack {
                TabView {
                    ChatsView()
                        .tabItem {
                            Image(systemName: Tab.chats.icon)
                            Text(Tab.chats.title)
                        }
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: Tab.settings.icon)
                            Text(Tab.settings.title)
                        }
                }
                .background(Color.white)
                .navigationBarBackButtonHidden(true)  // Hide back button after login
            }
        }
    }
    private enum Tab: String {
        case chats, settings
        
        var title: String {
            rawValue.capitalized
        }
        
        var icon: String {
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
    


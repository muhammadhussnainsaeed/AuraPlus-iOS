//
//  ChatPartnerPickerView.swift
//  Auraplus
//
//  Created by Hussnain on 6/4/25.
//

import SwiftUI

struct ChatPartnerPickerView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack{
            List{
                ForEach(ChatPartnerPickerOption.allCases){item in
                    HeaderItemView(item: item)
                }
                Section{
                    ForEach(0..<12){_ in
                        UserListView()
                    }
                } header: {
                     Text("Users avaiable on Aura+")
                        .textCase(nil)
                        .bold()
                }
            }
            .searchable(text: $searchText, prompt: "Search for username")
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                trailingNavItem()
            }
        }
    }
}

extension ChatPartnerPickerView {
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing){
            cancelButton()
        }
        
    }
    
    private func cancelButton() -> some View{
        Button{
            dismiss()
        } label:{
            Image(systemName: "xmark")
                .font(.callout)
                .foregroundColor(.blue)
                .bold()
                .padding()
        }
    }
}

extension ChatPartnerPickerView {
    private struct HeaderItemView: View{
        let item: ChatPartnerPickerOption
        
        var body: some View{
            Button{
                
            } label:{
                HStack{
                    Image(systemName: item.imageName)
                        .frame(width: 35, height: 35)
                    
                    Text(item.title)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    
    var id: String {
        return rawValue
    }
    
    var title: String{
        return rawValue
    }
    
    var imageName: String{
        switch self{
        case .newGroup:
            return "person.2.badge.plus.fill"
        }
    }
    
}

#Preview {
    ChatPartnerPickerView()
}

//
//  ChatsView.swift
//  Auraplus
//
//  Created by Hussnain on 9/3/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var searchText = ""
    var body: some View {
            NavigationStack {
                List {
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Umer", lastmessage: "What's going on?", time: "01:00 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    NavigationLink{
                        ChatRoomView()
                    }label:{
                        ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
                    }
                    
                    inboxFooterView()
                        .listRowSeparator(.hidden)
                    
                }
                .navigationTitle("Chats")
                .searchable(text: $searchText)
                .toolbar {
                    trailingNavItems()
                    lendingNavItems()
                }
            }
        }
    
    private func inboxFooterView() -> some View {
        HStack{
            Image(systemName: "lock.fill")
            (
                Text("Your personal messages are ")
                +
                Text("end-to-end encrypted")
                    .foregroundColor(.blue)
            )
        }
        .foregroundColor(.gray)
        .font(.caption2)
        .padding(.horizontal)
        
    }

        @ToolbarContentBuilder
    private func lendingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu{
                Button{
                    
                } label: {
                    Label("Select Chats",systemImage: "checkmark.circle")
                    
                }
            }label: {
                Image(systemName: "ellipsis.circle")
            }
            newChatButton()
        }
    }
    
        private func trailingNavItems() -> some ToolbarContent {
            ToolbarItem(placement: .navigationBarTrailing) {
                newChatButton()
            }
        }

        private func newChatButton() -> some View {
            Button{
                // Action for new chat
            }
            label: {
                Image(systemName: "plus.circle.fill")
            }
        }
    }

#Preview {
    ChatsView()
}

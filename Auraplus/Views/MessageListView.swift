//
//  MessageListView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MessageListController
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController()
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {
        
    }
    
}

#Preview {
    MessageListView()
}

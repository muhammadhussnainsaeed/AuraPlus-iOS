//
//  MessageListController.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import Foundation
import UIKit
import SwiftUICore
import SwiftUI

final class MessageListController: UIViewController {
    
    //mark: view's lifrcycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private let cellIndentifier: String = "MessageListControllerCells"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func setUpViews() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.topAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                                    ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIndentifier)
    }
    
}

extension MessageListController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageItem.stubMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let message = MessageItem.stubMessage[indexPath.row]
        cell.contentConfiguration = UIHostingConfiguration{
            BubbleTextView(item: message)
            switch message.type{
            case .text:
                BubbleTextView(item: message)
                
            case .video, .photo:
                bubbleImageView(item: message)
                
            case .audio:
                BubbleAudioView(item : message)
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
}

#Preview {
    MessageListView()
}

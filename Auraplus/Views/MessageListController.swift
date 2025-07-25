import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {

    var chatId: Int = 0
    var currentUserId: Int = 0
    var username: String?
    var webSocketManager: WebSocketManager?
    var userid: Int = 0

    private var messages: [MessageItem] = []
    private var cancellables = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCells"

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        loadInitialMessages()
        observeWebSocketUpdates()
    }

    private func setUpViews() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func loadInitialMessages() {
        AuthService.shared.fetchMessages(chatId: chatId) { [weak self] backendMessages in
            guard let self = self else { return }

            self.messages = backendMessages.map { backendMessage in
                let decryptedContent: String = {
                    if let encrypted = backendMessage.content,
                       let decrypted = AESHelper.shared.decrypt(base64CipherText: encrypted) {
                        return decrypted
                    } else {
                        return ""
                    }
                }()

                let decryptedMessage = Message(
                    id: backendMessage.id,
                    chat_id: backendMessage.chat_id,
                    sender_id: backendMessage.sender_id,
                    username: backendMessage.username,
                    content: decryptedContent,
                    media_url: backendMessage.media_url,
                    message_type: backendMessage.message_type,
                    time_stamp: backendMessage.time_stamp
                )

                return MessageItem(from: decryptedMessage, currentUsername: self.username ?? "")
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }

    private func observeWebSocketUpdates() {
        webSocketManager?.$newIncomingMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessage in
                guard let self = self else { return }

                let messageItem = MessageItem(from: newMessage, currentUsername: self.username ?? "")
                self.messages.append(messageItem)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
            .store(in: &cancellables)
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension MessageListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        cell.contentConfiguration = UIHostingConfiguration {
            switch message.type {
            case .text:
                BubbleTextView(item: message) {
                    self.confirmDelete(at: indexPath.row)
                }
            case .photo, .video:
                bubbleImageView(item: message){
                    self.confirmDelete(at: indexPath.row)
                } // TODO: Add onDelete if needed
            case .audio:
                BubbleAudioView(item: message){
                    self.confirmDelete(at: indexPath.row)
                } // TODO: Add onDelete if needed
            }
        }
        return cell
    }

    private func confirmDelete(at index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete Message", style: .destructive) { _ in
            self.deleteMessage(at: index)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController,
           let sourceView = self.view {
            popover.sourceView = sourceView
            popover.sourceRect = CGRect(
                x: sourceView.bounds.midX,
                y: sourceView.bounds.maxY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    private func deleteMessage(at index: Int) {

//        guard let session = session, let userId = session.currentUser?.id else {
//                showError(message: "User session is not available.")
//                return
//            }

            // ✅ 2. Safely check index
            guard index >= 0, index < messages.count else {
                showError(message: "Message index is invalid.")
                return
            }
        
        let message = messages[index]
        print("🧾 Deleting message with DB ID:", message.messageid)
        
        AuthService.shared.deleteMessage(messageID: message.messageid, userID: userid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let deletedMessage):
                    print("✅ Deleted message from server: \(deletedMessage)")
                    self.messages.remove(at: index)
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                    print("❌ Delete error:", error)
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        print("------",message,"------")
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

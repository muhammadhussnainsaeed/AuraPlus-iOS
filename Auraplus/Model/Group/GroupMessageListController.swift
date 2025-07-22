import UIKit
import SwiftUI
import Combine

final class GroupMessageListController: UIViewController {

    var userid: Int = 0
    var groupId: Int = 0
    var currentUserId: Int = 0
    var username: String? // Current user's username
    var senderUsername: String? // The actual sender in the session
    var webSocketManagerG: WebSocketManagerG?

    private var messages: [GroupMessageItem] = []
    private var cancellables = Set<AnyCancellable>()

    private let cellIdentifier = "GroupMessageListControllerCell"

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
        AuthService.shared.fetchGroupMessages(groupId: groupId) { [weak self] backendMessages in
            guard let self = self else { return }

            self.messages = backendMessages.map { backendMessage in
                // 🔐 Decrypt the content (if any)
                let decryptedContent: String? = {
                    if let encrypted = backendMessage.content,
                       let decrypted = AESHelper.shared.decrypt(base64CipherText: encrypted) {
                        return decrypted
                    } else {
                        return nil // or fallback like "" if needed
                    }
                }()

                // 🔁 Recreate GroupMessage with decrypted content
                let decryptedMessage = GroupMessage(
                    id: backendMessage.id,
                    group_id: backendMessage.group_id,
                    sender_id: backendMessage.sender_id,
                    username: backendMessage.username,
                    content: decryptedContent,
                    media_url: backendMessage.media_url,
                    message_type: backendMessage.message_type,
                    time_stamp: backendMessage.time_stamp
                )

                return GroupMessageItem(
                    from: decryptedMessage,
                    currentUsername: self.username ?? ""
                )
            }

            // ✅ Reload UI
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }


    private func observeWebSocketUpdates() {
        webSocketManagerG?.$newIncomingMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessage in
                guard let self = self else { return }

                let messageItem = GroupMessageItem(
                    from: newMessage,
                    currentUsername: self.username ?? ""
                )

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

// MARK: - UITableView Delegate & DataSource

extension GroupMessageListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groupMessage = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        cell.contentConfiguration = UIHostingConfiguration {
            switch groupMessage.type {
            case .text:
                BubbleTextViewG(item: groupMessage) {
                    self.confirmDelete(at: indexPath.row)
                }
            case .photo, .video:
                bubbleImageViewG(item: groupMessage){
                    self.confirmDelete(at: indexPath.row)
                }
            case .audio:
                BubbleAudioViewG(item: groupMessage){
                    self.confirmDelete(at: indexPath.row)
                }
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
        guard index >= 0, index < messages.count else {
            showError(message: "Invalid index.")
            return
        }

        let message = messages[index]
        print("🧾 Deleting GroupMessage ID:", message.id)

        AuthService.shared.deleteGroupMessage(messageID: message.messageid, senderID: userid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let successMessage):
                    print("✅ Deleted group message: \(successMessage)")
                    self.messages.remove(at: index)
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                    print("❌ Delete failed:", error)
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        print("❌ Error: \(message)")
        self.present(alert, animated: true)
    }
}

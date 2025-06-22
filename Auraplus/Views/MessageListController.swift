import UIKit
import SwiftUI
import Combine

final class MessageListController: UIViewController {

    var session: SessionManager!

    var chatId: Int = 0
    var currentUserId: Int = 0
    var username: String? // Current user's username
    var webSocketManager: WebSocketManager?

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
            self.messages = backendMessages.map {
                MessageItem(
                    from: $0,
                    currentUsername: self.username ?? ""
                )
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }

    private func observeWebSocketUpdates() {
        webSocketManager?.$newIncomingMessage
            .compactMap { $0 } // Ignore nils
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessage in
                guard let self = self else { return }

                let messageItem = MessageItem(
                    from: newMessage,
                    currentUsername: self.username ?? ""
                )

                // ✅ Append just one message
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
                BubbleTextView(item: message)
            case .photo, .video:
                bubbleImageView(item: message)
            case .audio:
                BubbleAudioView(item: message)
            }
        }
        return cell
    }
}

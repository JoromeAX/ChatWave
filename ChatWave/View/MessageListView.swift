//
//  MessageListView.swift
//  ChatWave
//
//  Created by Roman Khancha on 03.11.2024.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var messageViewModel: MessageViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var showDeleteAlert: Bool
    @Binding var selectedMessageId: String?
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            List {
                ForEach(messageViewModel.messages.indices, id: \.self) { index in
                    let message = messageViewModel.messages[index]
                    let showDateHeader = shouldShowDateHeader(for: index)
                    
                    if showDateHeader {
                        Text(dateFormatter.string(from: message.timestamp))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    MessageRowView(
                        message: message,
                        isCurrentUser: message.senderId == authViewModel.user?.id,
                        timeFormatter: timeFormatter
                    )
                    .id(message.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedMessageId = message.id
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onAppear {
                if let lastMessage = messageViewModel.messages.last {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: messageViewModel.messages) {
                if let lastMessage = messageViewModel.messages.last {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func shouldShowDateHeader(for index: Int) -> Bool {
        guard index > 0 else { return true }
        let currentMessageDate = messageViewModel.messages[index].timestamp
        let previousMessageDate = messageViewModel.messages[index - 1].timestamp
        return !Calendar.current.isDate(currentMessageDate, inSameDayAs: previousMessageDate)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }
}

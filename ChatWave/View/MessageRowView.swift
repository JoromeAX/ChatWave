//
//  MessageRowView.swift
//  ChatWave
//
//  Created by Roman Khancha on 02.11.2024.
//

import SwiftUI

struct MessageRowView: View {
    let message: Message
    let isCurrentUser: Bool
    let timeFormatter: DateFormatter
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.text)
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        Text(timeFormatter.string(from: message.timestamp))
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Image(systemName: message.readStatus ? "checkmark.bubble" : "ellipsis.bubble")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    
                    VStack(alignment: .leading) {
                        Text(message.text)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        HStack {
                            Text(timeFormatter.string(from: message.timestamp))
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.leading, 10)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

//
//  fetchChatbot.swift
//  SpeakPerfect
//
//  Created by Mark on 5/30/24.
//

import Foundation
import SwiftUI

struct bodyData: Codable {
    let model: String
    let messages: [message]
}

struct message: Codable {
    let role: String
    let content: String
}

struct chatbotResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [choice]
    let usage: usageType
    let system_fingerprint: String
}

struct usageType: Decodable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct choice: Decodable {
    let index : Int
    let message : message
    let logprobs: String?
    let finish_reason: String
}

func chat(messageList: [message]) async throws -> [message]{
    let chatBotURL = "https://api.openai.com/v1/chat/completions"
    print(messageList.isEmpty)
    let requestBody = bodyData(model: "gpt-4o", messages: messageList)
    guard let url = URL(string: chatBotURL) else {return []}
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer sk-proj-your own key", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    let encoder = JSONEncoder()
    let data = try encoder.encode(requestBody)
    
    let (responseData, response) = try await URLSession.shared.upload(for: request, from: data)

    do {
        let APIresponse = try JSONDecoder().decode(chatbotResponse.self, from: responseData)
        let responseMessage = APIresponse.choices[APIresponse.choices.endIndex-1].message
        var updatedMessageList = messageList
        updatedMessageList.append(responseMessage)
        return updatedMessageList
    } catch let error {
        print("Failed to parse JSON: \(error.localizedDescription)")
    }
    return messageList
}

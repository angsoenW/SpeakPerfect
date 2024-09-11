//
//  fetchAPI.swift
//  SpeakPerfect
//
//  Created by Mark on 5/30/24.
//

import Foundation
import SwiftUI

struct speechaceResponse: Decodable {
    let status: String
    let quota_remaining: Int
    let text_score: textScore
    let version: String
}

struct textScore: Decodable {
    let text: String
    let word_score_list: [wordScore]
    let ielts_score: pronunciationScore
    let pte_score: pronunciationScore
    let speechace_score: pronunciationScore
    let toeic_score: pronunciationScore
    let cefr_score: pronunciationScore
}

struct pronunciationScore: Decodable {
    let pronunciation: qualityScore
}

struct wordScore: Decodable {
    let word: String
    let quality_score: qualityScore
    let phone_score_list: [phoneScore]
    let syllable_score_list: [syllableScore]
    let ending_punctuation: String?
}

enum qualityScore: Decodable {
    case int(Int)
    case string(String)
    case double(Double)
    
    init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let doubleValue = try? container.decode(Double.self) {
                self = .double(doubleValue)
            } else {
                throw DecodingError.typeMismatch(qualityScore.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode Int or String for quality_score"))
            }
        }
}

struct phoneScore: Decodable {
    let phone: String
    let stress_level: Int?
    let extent: [Int]
    let quality_score: qualityScore
    let stress_score: Int?
    let predicted_stress_level: Int?
    let word_extent: [Int]
    let sound_most_like: String?
}

struct syllableScore: Decodable {
    let phone_count: Int
    let stress_level: Int?
    let letters: String
    let quality_score: qualityScore
    let stress_score: Int
    let predicted_stress_level: Int
    let extent: [Int]
}

func evaluatePronunciation(filePath: String, text: String, completion: @escaping (_ success: Bool, _ data: speechaceResponse?) -> Void) {
    let speechAceurl = "https://api.speechace.co/api/scoring/text/v9/json?key=AnRQQQCTQv%2BbfECXQgzYHoDnvadQYzxlJ5QX0sLvhbgjlmX%2Bs1fxSBtnF%2Bn3htR6%2FsdamNRGj5Crz3fkGqjzldLvMVU%2BDxWWsA4JL7TfrfZ5olyFl3Y4%2BZZxVu6puNNJ&dialect=en-us&user_id=XYZ-ABC-99001"
    guard let url = URL(string: speechAceurl) else { return }
    var apiRequest = URLRequest(url: url)
    apiRequest.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    apiRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    // Add Text field
    let textField = "text"
//    let textValue = "apple"
    let textValue = text

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(textField)\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(textValue)\r\n".data(using: .utf8)!)
    
    
    // Add file field
    let fileFieldName = "user_audio_file"
    let fileName = "basic_samples_v9_apple.wav"
    let mimeType = "audio/m4a"
//    let filePath = "/Users/mark/Desktop/INFO 449/SpeakPerfect/SpeakPerfect/Preview Content/basic_samples_v9_apple.wav"
    let filePath = filePath
    let fileURL = URL(fileURLWithPath: filePath)
    var audioData: Data = Data()
    do {
        // Read the file data
        audioData = try Data(contentsOf: fileURL)
    } catch {
        // Handle the error
        print("Failed to read file data: \(error.localizedDescription)")
    }
    let fileData = audioData // Your file data here

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)

    // Close the body with the boundary
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    apiRequest.httpBody = body
    
    
    let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
        guard let data = data else { return }
    

           do {
               if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                   let APIresponse = try JSONDecoder().decode(speechaceResponse.self, from: data)
                   DispatchQueue.main.async {
                       completion(true, APIresponse)
                   }
               }
           } catch let error {
               print(String(describing: error))
               print("Failed to parse JSON: \(error.localizedDescription)")
               DispatchQueue.main.async {
                   completion(false, nil)
               }
           }
    }
    
    task.resume()
}

func getScore(inputScore: qualityScore) -> Double {
    var outputScore: Double = 0.0
    switch inputScore {
    case .int(let intValue):
        outputScore = Double(intValue)
    case .string(let stringValue):
        outputScore = Double(stringValue) ?? 0.0
    case .double(let doubleValue):
        outputScore = doubleValue
    }
    return outputScore
}


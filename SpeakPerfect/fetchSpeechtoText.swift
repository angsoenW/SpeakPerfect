//
//  fetchSpeechtoText.swift
//  SpeakPerfect
//
//  Created by Mark on 5/30/24.
//

import Foundation

struct textResponse: Decodable {
    let text: String?
}

func speechToText(filePath: String, completion: @escaping (String) -> Void) -> String{
    var transcribedText = ""
    let openAIURL = "https://api.openai.com/v1/audio/transcriptions"
    guard let url = URL(string: openAIURL) else { return ""}
    var apiRequest = URLRequest(url: url)
    apiRequest.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    apiRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    apiRequest.setValue("Bearer sk-proj-your own key", forHTTPHeaderField: "Authorization")
    

    var body = Data()

    // Add Text field
    let textField = "model"
    let textValue = "whisper-1"

    // form data
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(textField)\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(textValue)\r\n".data(using: .utf8)!)
    
    
    // Add file field
    let fileFieldName = "file"
    let fileName = "userAudioInput.m4a"
    let mimeType = "audio/m4a"
    let filePath = filePath
    let fileURL = URL(fileURLWithPath: filePath)
    var audioData: Data = Data()
    do {
        // Read the file data
        audioData = try Data(contentsOf: fileURL)
        // Process the audio data as needed
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
        
        do{
            let APIresponse = try JSONDecoder().decode(textResponse.self, from: data)
            transcribedText = APIresponse.text ?? ""
            DispatchQueue.main.async {
                completion(transcribedText)
            }
        } catch {
            print(String(describing: error))
            DispatchQueue.main.async {
                completion("")
            }
        }
    }
    task.resume()
    return transcribedText
}

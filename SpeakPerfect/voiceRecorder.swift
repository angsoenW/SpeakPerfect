//
//  voiceRecorder.swift
//  SpeakPerfect
//
//  Created by stlp on 5/31/24.
//

import Foundation
import SwiftUI
import AVFoundation

class VoiceRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var inputURL: URL?
    @State var alert = false
    var session: AVAudioSession!
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer?

    init() {
        setupAudioSession()
    }

    func setupAudioSession() {
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.alert.toggle()
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func toggleRecording(completion: @escaping (String) -> Void) -> String{
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = url.appendingPathComponent("UserInput.m4a")
            inputURL = fileName
            if isRecording {
                var userInputText = ""
                recorder.stop()
                isRecording.toggle()
                speechToText(filePath: inputURL!.path) { response in
                    userInputText = response
                    DispatchQueue.main.async {
                        completion(userInputText)
                    }
                }
                return userInputText
            }
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            recorder = try AVAudioRecorder(url: fileName, settings: settings)
            recorder.record()
            isRecording.toggle()
        } catch {
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion("")
            }
        }
        return ""
    }

    func playAudio() {
        guard let url = inputURL else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

}


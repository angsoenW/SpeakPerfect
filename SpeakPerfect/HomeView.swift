//
//  HomeView.swift
//  SpeakPerfect
//
//  Created by stlp on 6/3/24.
//

import SwiftUI

struct HomeView: View {
    @State var messageList : [message] = []
    @State var speechaceScoreList: [Double] = []
    @State var speechaceDetailList: [speechaceResponse] = []
    @State private var chatContent: String = ""
    @State private var userInputText: String = ""
    @StateObject var voiceRecorder = VoiceRecorder()
    @State var speechaceData: speechaceResponse?
    
    var body: some View {
        NavigationStack{
            VStack {
                // Title
                Text("SpeakPerfect")
                    .font(.largeTitle)
                    .padding(.top, 20)
                
                Spacer()
                
                // Scroll view displaying user input and chatbot response
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if(messageList.count > 1){
                            ForEach(1..<messageList.count, id: \.self) { index in
                                if messageList[index].role == "user" {
                                    HStack {
                                        Spacer()
                                        Text(messageList[index].content)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        
                                        //Navigate to detailView
                                        if(speechaceScoreList.endIndex-1 >= index){
                                            NavigationLink(destination: WordDetailView(speechaceData: speechaceDetailList[index])) {
                                                Text(String(Int(speechaceScoreList[index])) +  " >").foregroundColor(getColor(for: Int(speechaceScoreList[index])))
                                            }
                                        }
                                    }
                                } else {
                                    HStack {
                                        Text(messageList[index].content)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Text field that updates from user input
                // on submit: send data to chatbot and store response in @state var messageList to display
                // after speechace api is finished, add functionality to submit data to speechace and save response in @state array
                HStack {
                    //Record button
                    Button(action: {
                        voiceRecorder.toggleRecording() { response in
                            userInputText = response
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 50, height: 50)
                            
                            if voiceRecorder.isRecording {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 60, height: 60)
                            }
                        }
                    }
                    
                    TextField("Record Voice to Start", text: $userInputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.3)) // Enhanced visibility
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Enter Button
                    // when clicked: send data to chatbot and store response in @state var messageList to display
                    // after speechace api is finished, add functionality to submit data to speechace and save response in @state array
                    Button(action: {
                        if(messageList.isEmpty){
                            messageList.append(message(role: "system", content: "human in a casual conversation"))
                        }
                        if(userInputText != "") {
                            messageList.append(message(role: "user", content: userInputText))
                            let currentIndex = messageList.endIndex - 1
                            Task{
                                messageList = try await chat(messageList: messageList)
                            }
                            if let url = voiceRecorder.inputURL {
                                evaluatePronunciation(filePath:url.path , text: userInputText) { success, data in
                                    if success {
                                        speechaceData = data
                                        let emptySpeechaceResponse = speechaceResponse(
                                            status: "",
                                            quota_remaining: 0,
                                            text_score: textScore(
                                                text: "",
                                                word_score_list: [],
                                                ielts_score: pronunciationScore(pronunciation: .double(0)),
                                                pte_score: pronunciationScore(pronunciation: .double(0)),
                                                speechace_score: pronunciationScore(pronunciation: .double(0)),
                                                toeic_score: pronunciationScore(pronunciation: .double(0)),
                                                cefr_score: pronunciationScore(pronunciation: .string(""))
                                            ),
                                            version: ""
                                        )
                                        while(speechaceDetailList.endIndex - 1 < currentIndex){
                                            speechaceDetailList.append(emptySpeechaceResponse)
                                        }
                                        speechaceDetailList.insert(speechaceData ?? emptySpeechaceResponse, at: currentIndex)
                                        let pronunciationEnum = speechaceData?.text_score.speechace_score.pronunciation
                                        let speechaceScore = getScore(inputScore: pronunciationEnum!)
                                        while(speechaceScoreList.endIndex - 1 < currentIndex){
                                            speechaceScoreList.append(0)
                                        }
                                        speechaceScoreList.insert(speechaceScore, at: currentIndex)
                                    } else {
                                        print ("No data returned")
                                    }
                                }
                            } else {
                                print("URL is nil")
                            }
                            userInputText = ""
                            
                        }
                    }) {
                        Text("Enter")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                }
                .padding(.horizontal)
                
                // Dynamic recording status
                if voiceRecorder.isRecording {
                    Text("You are recording now")
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                }
                Spacer()
                
            }
            .background(Color.black.opacity(0.05))
            .padding(.bottom)
        }
        .navigationBarBackButtonHidden(true)
    }
}

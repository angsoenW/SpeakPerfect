//
//  WelcomeView.swift
//  SpeakPerfect
//
//  Created by Jasper Wang on 6/3/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()

                    Text("Welcome to SpeakPerfect")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: HomeView()) {
                        Text("Get Started")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}


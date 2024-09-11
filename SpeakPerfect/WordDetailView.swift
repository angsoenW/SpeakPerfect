//
//  WordDetailView.swift
//  SpeakPerfect
//
//  Created by Mark on 6/3/24.
//

import Foundation
import SwiftUI

struct WordDetailView: View {
    var speechaceData: speechaceResponse

    var body: some View {
        NavigationStack {
            List(speechaceData.text_score.word_score_list, id: \.word) { wordScore in
                NavigationLink(destination: PhoneDetailView(phone_score_list: wordScore.phone_score_list, word:wordScore.word)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(wordScore.word)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Text(String(Int(getScore(inputScore: wordScore.quality_score))))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(getColor(for: Int(getScore(inputScore: wordScore.quality_score))))
                    }
                    .padding()
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Quality Score By Word")
        }
    }
}

func getColor(for score: Int) -> Color {
    if score > 80 {
        return .blue
    } else if score >= 60 {
        return .yellow
    } else {
        return .red
    }
}

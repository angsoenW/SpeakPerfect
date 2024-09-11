//
//  PhoneDetailView.swift
//  SpeakPerfect
//
//  Created by Mark on 6/3/24.
//

import Foundation
import SwiftUI

struct PhoneDetailView: View {
    var phone_score_list: [phoneScore]
    var word: String

    var body: some View {
        VStack{
            Text(word)
                .font(.largeTitle)
                .fontWeight(.bold)
            List(phone_score_list, id: \.phone) { phoneScore in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(phoneScore.phone)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Text(String(Int(getScore(inputScore: phoneScore.quality_score))))
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(getColor(for: Int(getScore(inputScore: phoneScore.quality_score))))
                }
                .padding()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Quality Score By Phone")
        }
    }
}

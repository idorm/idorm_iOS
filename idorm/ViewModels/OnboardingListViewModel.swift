//
//  OnboardingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import Foundation

class OnboardingListViewModel {
    private var questions: [String] = [
        "흡연 여부",
        "코골이 여부",
        "이갈이 여부",
        "야식 허용 여부",
        "소음이 있는 취미가 있나요?",
        "만약 있다면 이어폰 착용 여부"
        ]

    var numberOfRowsInSection: Int {
        return questions.count
    }
    
    func gainOnboardingVM(index: Int) -> OnboardingViewModel {
        return OnboardingViewModel(question: questions[index])
    }
}

struct OnboardingViewModel {
    let question: String
}

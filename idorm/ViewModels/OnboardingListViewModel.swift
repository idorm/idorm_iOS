//
//  OnboardingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import Foundation

class OnboardingListViewModel {
    private var questions: [String] = [
        "입사 기간",
        "본인의 성별",
        "본인의 나이",
        "코골이 여부",
        "흡연 여부",
        "이갈이 여부",
        "야식 허용 여부",
        "이어폰 착용 의사 여부"
        ]
    
    private var detailQuestions: [String] = [
        "기상시간을 알려주세요.",
        "정리정돈은 얼마나 하시나요?",
        "샤워는 주로 언제/몇 분 동안 하시나요?",
        "MBTI를 알려주세요.",
        "미래의 룸메에게 하고싶은 말은?"
    ]
    
    var onboardingVerifyArray = [Bool](repeating: false, count: 8)
    var onboardingDetailVerifyArray = [Bool](repeating: false, count: 5)

    var questionsNumberOfRowsInSection: Int {
        return questions.count
    }
    
    var detailNumberOfRowsInSection: Int {
        return detailQuestions.count
    }
    
    func gainOnboardingVM(index: Int) -> OnboardingViewModel {
        return OnboardingViewModel(question: questions[index])
    }
    
    func gainOnboardingDetailVM(index: Int) -> OnboardingDetailViewModel {
        return OnboardingDetailViewModel(question: detailQuestions[index])
    }
}

struct OnboardingViewModel {
    let question: String
}

struct OnboardingDetailViewModel {
    let question: String
}

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
        "만약 있다면 이어폰 착용 여부",
        "본인의 성별"
        ]
    
    private var detailQuestions: [String] = [
        "기상시간을 알려주세요.",
        "취침시간을 알려주세요.",
        "정리정돈은 얼마나 하시나요.",
        "샤워는 주로 언제/몇 분 동안 하시나요",
        "나이를 알려주세요",
        "MBTI를 알려주세요.",
        "하고싶은 말을 작성해주세요."
    ]
    
    var onboardingVerifyArray = [Bool](repeating: false, count: 7)
    var onboardingDetailVerifyArray = [Bool](repeating: false, count: 7)

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

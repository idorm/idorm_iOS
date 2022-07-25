//
//  OnboardingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import Foundation

class OnboardingListViewModel {
  private var questions: [String] = [
    "기상시간을 알려주세요.",
    "정리정돈은 얼마나 하시나요?",
    "샤워는 주로 언제/몇 분 동안 하시나요?",
    "MBTI를 알려주세요.",
    "룸메와 연락을 위한 개인 오픈채팅 링크를 알려주세요.",
    "미래의 룸메에게 하고 싶은 말은?"
  ]
  
  var onboardingVerifyArray = [Bool](repeating: false, count: 5)
  
  var numberOfRowsInSection: Int {
    return questions.count
  }
  
  func getQuestionText(index: Int) -> String {
    return questions[index]
  }
}

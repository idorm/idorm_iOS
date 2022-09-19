//
//  HomeListViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/09.
//

import Foundation

enum HomeSection: String, CaseIterable {
    case roommate = "룸메이트 매칭👍"
    case popular = "내 기숙사 인기글"
}

class HomeListViewModel {
    
    var numberOfSections: Int {
        return HomeSection.allCases.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 10 // 변경 예정
        }
    }
}

struct HomeViewModel {
    
}

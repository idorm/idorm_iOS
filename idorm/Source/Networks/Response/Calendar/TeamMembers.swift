//
//  Target.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import Foundation

/// 팀원 전체 조회 API를 호출 했을 때 얻을 수 있는 모델입니다.
struct TeamMembers: Codable, Hashable {
  let teamId: Int
  let isNeedToConfirmDeleted: Bool
  let members: [TeamMember]
}


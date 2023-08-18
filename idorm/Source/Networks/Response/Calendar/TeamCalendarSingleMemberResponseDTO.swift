//
//  TeamMember.swift
//  idorm
//
//  Created by 김응철 on 7/31/23.
//

import Foundation

/// 공유 캘린더 각 멤버의 정보를 나타내는 모델입니다.
struct TeamCalendarSingleMemberResponseDTO: Codable, Hashable {
  let memberId: Int
  let nickname: String
  let order: Int
  let profilePhotoUrl: String?
  let sleepoverYn: Bool
}

//
//  MemberResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/31/23.
//

import Foundation

struct MemberSingleResponseDTO: Decodable {
  let memberId: Int
  let email: String
  let nickname: String
  let profilePhotoUrl: String?
}

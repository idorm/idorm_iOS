//
//  ResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/29.
//

import Foundation

struct ResponseDTO<Model: Codable>: Codable {
  let responseMessage: String
  let data: Model
}
//
//  BottomSheet.swift
//  idorm
//
//  Created by 김응철 on 2023/02/14.
//

import Foundation

enum BottomSheet {
  case selectDorm
  case comment
  case myComment
  case post
  case myPost
  
  var height: CGFloat {
    switch self {
    case .post: return 166
    case .comment: return 171
    case .myComment: return 171
    case .myPost: return 250
    case .selectDorm: return 182
    }
  }
}

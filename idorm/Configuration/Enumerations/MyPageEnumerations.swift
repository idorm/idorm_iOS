//
//  MyPageEnumerations.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import Foundation

struct MyPageEnumerations {}

extension MyPageEnumerations {
  enum ManageMyInfoView {
    case onlyArrow(title: String)
    case onlyDescription(description: String = "", title: String)
    case both(description: String = "", title: String)
  }
  
  enum Sort {
    case lastest
    case past
  }
  
  enum BottomAlert {
    case like
    case dislike
    
    var height: Int {
      switch self {
      case .like: return 208
      case .dislike: return 208
      }
    }
  }

  enum Roommate {
    case like
    case dislike
  }
}

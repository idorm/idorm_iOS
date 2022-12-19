//
//  ViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import RxSwift

protocol ViewModel {
  associatedtype Input
  associatedtype Output
  
  var input: Input { get }
  var output: Output { get }
  var disposeBag: DisposeBag { get }
}

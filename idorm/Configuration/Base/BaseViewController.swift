//
//  BaseViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/09/20.
//

import UIKit

import class RxSwift.DisposeBag
import ReactorKit
import Alamofire
import SnapKit

class BaseViewController: UIViewController {
  
  // MARK: - UI Components
  
  /// 로딩을 나타내는 인디케이터입니다.
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .darkGray
    return indicator
  }()
  
  // MARK: - Properties
  
  /// A dispose bag. 각 ViewController에 종속적이다.
  var disposeBag = DisposeBag()
  
  /// 현재 `indicator`의 재생을 판별하는 `Bool` 값입니다.
  var isLoading: Bool = false {
    willSet { self.isLoadingWillChange(newValue) }
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupStyles()
    setupLayouts()
    setupConstraints()
    bind()
  }
  
  // MARK: - Setup
  
  /// UI 프로퍼티를 view에 할당합니다.
  ///
  /// ```
  /// func setupLayouts() {
  ///   self.view.addSubview(label)
  ///   self.stackView.addArrangedSubview(label)
  ///   self.label.layer.addSubLayer(gradientLayer)
  ///   // codes..
  /// }
  /// ```
  func setupLayouts() { }

  /// UI 프로퍼티의 제약조건을 설정합니다.
  ///
  /// ```
  /// func setupConstraints() {
  ///   // with SnapKit
  ///   label.snp.makeConstraints { make in
  ///     make.edges.equalToSuperview()
  ///   }
  ///   // codes..
  /// }
  /// ```
  func setupConstraints() { }

  /// View와 관련된 Style을 설정합니다.
  ///
  /// ```
  /// func setupStyles() {
  ///   navigationController?.navigationBar.tintColor = .white
  ///   view.backgroundColor = .white
  ///   // codes..
  /// }
  /// ```
  func setupStyles() { }
  
  // MARK: - Bind

  /// Action, State 스트림을 bind합니다.
  /// 예를들어, Button이 tap 되었을 때, 또는 tableView를 rx로 설정할 때 이용됩니다.
  ///
  /// ```
  /// func bind() {
  ///   button.rx.tap
  ///     .subscribe {
  ///       print("Tapped")
  ///     }
  ///     .disposed(by: disposeBag)
  ///   // codes..
  /// }
  /// ```
  func bind() { }
  
  // MARK: - Functions
  
  /// `indicator`의 상태를 변경합니다.
  /// 최상단 레이어의 정중앙에서 재생됩니다.
  ///
  /// - Parameters:
  ///  - isLoading: 현재 로딩의 상태입니다.
  func isLoadingWillChange(_ isLoading: Bool) {
    if isLoading {
      // 로딩 중
      self.indicator.startAnimating()
      self.view.addSubview(self.indicator)
      
      self.indicator.snp.makeConstraints { make in
        make.center.equalToSuperview()
      }
    } else {
      // 로딩 중이 아님
      self.indicator.stopAnimating()
      self.indicator.removeFromSuperview()
    }
  }
}

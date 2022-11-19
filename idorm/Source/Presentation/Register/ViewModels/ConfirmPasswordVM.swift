import Foundation

import RxSwift
import RxCocoa

final class ConfirmPasswordViewModel: ViewModel {
  struct Input {
    // Interaction
    let confirmButtonTapped = PublishSubject<Void>()
    let passwordText = BehaviorRelay<String>(value: "")
    let passwordText_2 = BehaviorRelay<String>(value: "")
  }
  
  struct Output {
    // UI
    let isEnableConfirmButton = PublishSubject<Bool>()
    let verificationCount = BehaviorRelay<Bool>(value: false)
    let verificationCombine = BehaviorRelay<Bool>(value: false)
    let verificationEquality = BehaviorRelay<Bool>(value: false)
    
    // Presentation
    let showErrorPopupVC = PublishSubject<String>()
    let showLoginVC = PublishSubject<Void>()
    let pushToConfirmNicknameVC = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  private let vcType: RegisterVCTypes.ConfirmPasswordVCType
  
  var passwordText: String { return input.passwordText.value }
  var passwordText2: String { return input.passwordText_2.value }
  
  init(_ vcType: RegisterVCTypes.ConfirmPasswordVCType) {
    self.vcType = vcType
    bind()
  }
  
  // MARK: - Bind
  
  func bind() {
    
    // 텍스트 입력 -> 로직 검증
    input.passwordText
      .bind(onNext: { [weak self] password in
        if password.count >= 8 {
          self?.output.verificationCount.accept(true)
        } else {
          self?.output.verificationCount.accept(false)
        }
        
        if LoginUtilities.isValidPassword(pwd: password) {
          self?.output.verificationCombine.accept(true)
        } else {
          self?.output.verificationCombine.accept(false)
        }
      })
      .disposed(by: disposeBag)
    
    // 검증 작업 -> 확인 버튼 활성화/비활성화
    Observable.combineLatest(
      output.verificationCount,
      output.verificationCombine,
      output.verificationEquality
    )
    .map {
      $0.0 && $0.1 && $0.2 ? true : false
    }
    .bind(to: output.isEnableConfirmButton)
    .disposed(by: disposeBag)
    
    // 텍스트 입력 -> 비밀번호1, 2 동등성 확인
    Observable.combineLatest(
      input.passwordText,
      input.passwordText_2
    )
    .map {
      $0 == $1 ? true : false
    }
    .bind(to: output.verificationEquality)
    .disposed(by: disposeBag)
    
    switch vcType {
    case .signUp:
      // 회원가입 Flow일 때, 확인 버튼 클릭 -> ConfirmNicknameVC로 이동
      input.confirmButtonTapped
        .map { [weak self] in
          Logger.instance.password = self?.passwordText ?? ""
        }
        .bind(to: output.pushToConfirmNicknameVC)
        .disposed(by: disposeBag)
      
    case .findPW, .updatePW:
      // 비밀번호 변경 Flow일 때, -> LoginVC로 이동
      input.confirmButtonTapped
        .map { [weak self] in
          let email = Logger.instance.email ?? ""
          let password = self?.passwordText ?? ""
          return (email, password)
        }
        .flatMap { APIService.memberProvider.rx.request(.changePassword(id: $0.0, pw: $0.1)) }
        .subscribe(onNext: { [weak self] response in
          switch response.statusCode {
          case 200:
            self?.output.showErrorPopupVC.onNext("비밀번호가 변경 되었습니다.")
            self?.output.showLoginVC.onNext(Void())
          case 400:
            self?.output.showErrorPopupVC.onNext("입력은 필수입니다.")
          default:
            fatalError("비밀번호 변경 실패했습니다,,,")
          }
        })
        .disposed(by: disposeBag)
    }
  }
}

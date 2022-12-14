import UIKit

import RxSwift
import RxCocoa
import RxMoya

final class ConfirmPasswordViewModel: ViewModel {
  
  struct Input {
    let confirmButtonDidTap = PublishSubject<Void>()
    let passwordTf1DidChange = PublishSubject<String>()
    let passwordTf2DidChange = PublishSubject<String>()
    let passwordTf1DidBegin = PublishSubject<Void>()
    let passwordTf1DidEnd = PublishSubject<Void>()
    let passwordTf2DidEnd = PublishSubject<Void>()
  }
  
  struct Output {
    let presentPopupVC = PublishSubject<String>()
    let presentLoginVC = PublishSubject<Void>()
    let pushToConfirmNicknameVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let isHiddenCheckmark = PublishSubject<Bool>()
    let textCountConditionLabelTextColor = PublishSubject<UIColor>()
    let compoundConditionLabelTextColor = PublishSubject<UIColor>()
    let infoLabelTextColor = PublishSubject<UIColor>()
    let infoLabel2Text = PublishSubject<String>()
    let infoLabel2TextColor = PublishSubject<UIColor>()
    let passwordTf1BorderColor = PublishSubject<CGColor>()
    let passwordTf2BorderColor = PublishSubject<CGColor>()
  }
  
  // MARK: - Properties
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  let currentPassword1 = BehaviorRelay<String>(value: "")
  let currentPassword2 = BehaviorRelay<String>(value: "")
  let isValidTextCountCondition = BehaviorRelay<Bool>(value: false)
  let isValidCompoundCondition = BehaviorRelay<Bool>(value: false)
  let isValidEqualityCondition = BehaviorRelay<Bool>(value: false)
  let isValidWholeCondition = BehaviorRelay<Bool>(value: false)
  
  // MARK: - Bind
  
  init(_ vcType: RegisterVCTypes.ConfirmPasswordVCType) {
    
    // 완료 버튼 클릭 -> 조건 확인 오류 팝업
    input.confirmButtonDidTap
      .filter { [weak self] in (self?.isValidWholeCondition.value ?? false) == false }
      .map { "조건을 다시 확인해주세요." }
      .bind(to: output.presentPopupVC)
      .disposed(by: disposeBag)
    
    // 글자수 조건 -> 글자수 텍스트 컬러
    isValidTextCountCondition
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_gray_400 }
      .bind(to: output.textCountConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 글자 조합 조건 -> 조합 텍스트 컬러
    isValidCompoundCondition
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_gray_400 }
      .bind(to: output.compoundConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 시작 -> 체크마크 숨김
    input.passwordTf1DidBegin
      .map { true }
      .bind(to: output.isHiddenCheckmark)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 해제 -> 체크마크 표시/숨김
    input.passwordTf1DidEnd
      .map { [weak self] in
        (self?.isValidTextCountCondition.value ?? false) && (self?.isValidCompoundCondition.value ?? false)
      }
      .map { !$0 }
      .bind(to: output.isHiddenCheckmark)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 해제 -> 텍스트필드1 모서리 컬러
    input.passwordTf1DidEnd
      .map { [weak self] in
        (self?.isValidTextCountCondition.value ?? false) && (self?.isValidCompoundCondition.value ?? false)
      }
      .map { $0 ? UIColor.idorm_gray_400.cgColor : UIColor.idorm_red.cgColor }
      .bind(to: output.passwordTf1BorderColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 해제 -> 글자수 레이블 컬러
    input.passwordTf1DidEnd
      .map { [weak self] in self?.isValidTextCountCondition.value ?? false }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.textCountConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 해제 -> 글자수 조합 레이블 컬러
    input.passwordTf1DidEnd
      .map { [weak self] in self?.isValidCompoundCondition.value ?? false }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.compoundConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 포커싱 해제 -> 비밀번호 레이블 컬러
    input.passwordTf1DidEnd
      .map { [weak self] in
        (self?.isValidTextCountCondition.value ?? false) && (self?.isValidCompoundCondition.value ?? false)
      }
      .map { $0 ? UIColor.black : UIColor.idorm_red }
      .bind(to: output.infoLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 포커싱 해제 -> infoLabel2 텍스트 변경
    input.passwordTf2DidEnd
      .map { [weak self] in self?.isValidEqualityCondition.value ?? false }
      .map { $0 ? "비밀번호 확인" : "두 비밀번호가 일치하지 않습니다. 다시 확인해주세요." }
      .bind(to: output.infoLabel2Text)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 포커싱 해제 -> infoLabel2 텍스트 컬러 변경
    input.passwordTf2DidEnd
      .map { [weak self] in self?.isValidEqualityCondition.value ?? false }
      .map { $0 ? UIColor.black : UIColor.idorm_red }
      .bind(to: output.infoLabel2TextColor)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 포커싱 해제 -> password2TextField 모서리 컬러 변경
    input.passwordTf2DidEnd
      .map { [weak self] in self?.isValidEqualityCondition.value ?? false }
      .map { $0 ? UIColor.idorm_gray_400.cgColor : UIColor.idorm_red.cgColor }
      .bind(to: output.passwordTf2BorderColor)
      .disposed(by: disposeBag)
    
    // 확인 버튼 클릭 -> 팝업VC
    input.confirmButtonDidTap
      .filter { [weak self] in (self?.isValidWholeCondition.value ?? false) == false }
      .map { _ in "조건을 다시 확인해주세요." }
      .bind(to: output.presentPopupVC)
      .disposed(by: disposeBag)
    
    // 텍스트필드1 반응 -> 변수 저장
    input.passwordTf1DidChange
      .bind(to: currentPassword1)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 반응 -> 변수 저장
    input.passwordTf2DidChange
      .bind(to: currentPassword2)
      .disposed(by: disposeBag)
    
    // 비밀번호 반응 -> 글자수 유효성 검사
    currentPassword1
      .map { $0.count > 8 }
      .bind(to: isValidTextCountCondition)
      .disposed(by: disposeBag)
    
    // 비밀번호 반응 -> 문자 조합 유효성 검사
    currentPassword1
      .map { $0.isValidPasswordCondition }
      .bind(to: isValidCompoundCondition)
      .disposed(by: disposeBag)
    
    // 비밀번호 반응 -> 비밀번호 동일 유효성 검사
    Observable.combineLatest(
      currentPassword1,
      currentPassword2
    )
    .map { $0.0 == $0.1 }
    .bind(to: isValidEqualityCondition)
    .disposed(by: disposeBag)
    
    // 각각 유효성 검사 반응 -> 전체 유효성 검사
    Observable.combineLatest(
      isValidEqualityCondition,
      isValidCompoundCondition,
      isValidTextCountCondition
    )
    .map { $0.0 && $0.1 && $0.2 }
    .bind(to: isValidWholeCondition)
    .disposed(by: disposeBag)
    
    // Logger에 저장
    currentPassword1
      .bind(to: Logger.instance.currentPassword)
      .disposed(by: disposeBag)
    
    let currentEmail = Logger.instance.currentEmail.value
    let currentPassword = Logger.instance.currentPassword.value
    
    switch vcType {
    case .signUp:
      
      // 확인 버튼 -> ConfirmNicknameVC
      input.confirmButtonDidTap
        .withUnretained(self)
        .filter { $0.0.isValidWholeCondition.value }
        .map { _ in Void() }
        .bind(to: output.pushToConfirmNicknameVC)
        .disposed(by: disposeBag)
      
    case .findPW, .updatePW:
      
      // 확인 버튼 -> 비밀번호 변경 API 요청
      input.confirmButtonDidTap
        .withUnretained(self)
        .filter { $0.0.isValidWholeCondition.value }
        .do { $0.0.output.isLoading.onNext(true) }
        .map { _ in (currentEmail, currentPassword) }
        .flatMap {
          APIService.memberProvider.rx.request(.changePassword(id: $0.0, pw: $0.1))
            .asObservable()
            .materialize()
        }
        .withUnretained(self)
        .subscribe(onNext: { owner, event in
          owner.output.isLoading.onNext(false)
          
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.presentPopupVC.onNext("비밀번호가 변경 되었습니다.")
              owner.output.presentLoginVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        })
        .disposed(by: disposeBag)
    }
  }
}

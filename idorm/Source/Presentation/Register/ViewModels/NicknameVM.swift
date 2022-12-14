import UIKit

import RxSwift
import RxCocoa
import RxMoya

final class NicknameViewModel: ViewModel {
  struct Input {
    let textDidChange = BehaviorRelay<String>(value: "")
    let confirmButtonDidTap = PublishSubject<Void>()
    let textFieldEditingDidBegin = PublishSubject<Void>()
    let textFieldEditingDidEnd = PublishSubject<Void>()
  }
  
  struct Output {
    let currentTextCount = PublishSubject<Int>()
    let currentText = BehaviorRelay<String>(value: "")
    let countConditionLabelTextColor = PublishSubject<UIColor>()
    let spacingConditionLabelTextColor = PublishSubject<UIColor>()
    let textConditionLabelTextColor = PublishSubject<UIColor>()
    let textFieldBorderColor = PublishSubject<CGColor>()
    let isHiddenCheckmark = PublishSubject<Bool>()
    let presentPopupVC = PublishSubject<String>()
    let presentCompleteSignUpVC = PublishSubject<Void>()
    let isLoading = PublishSubject<Bool>()
    let popVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  let isValidTextCountCondition = BehaviorRelay<Bool>(value: false)
  let isValidSpacingCondition = BehaviorRelay<Bool>(value: false)
  let isValidTextCondition = BehaviorRelay<Bool>(value: false)
  let isValidCondition = BehaviorRelay<Bool>(value: false)
  var currentText: String { output.currentText.value }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init(_ vcType: RegisterVCTypes.NicknameVCType) {
    
    // 텍스트 변화 -> 8글자 초과 입력X
    input.textDidChange
      .scan("") { $1.count > 8 ? $0 : $1 }
      .bind(to: output.currentText)
      .disposed(by: disposeBag)
    
    // 텍스트 변화 -> 텍스트 글자 수 감지
    output.currentText
      .map { $0.count }
      .bind(to: output.currentTextCount)
      .disposed(by: disposeBag)
    
    // 텍스트필드 포커싱 해제 -> 체크버튼 유무
    input.textFieldEditingDidEnd
      .withUnretained(self)
      .map { $0.0.isValidCondition.value }
      .map { $0 ? false : true }
      .bind(to: output.isHiddenCheckmark)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 글자수 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .withUnretained(self)
      .map { $0.0.isValidTextCountCondition.value }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.countConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 공백 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .withUnretained(self)
      .map { $0.0.isValidSpacingCondition.value }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.spacingConditionLabelTextColor)
      .disposed(by: disposeBag)

    // 텍스트 필드 포커싱 해제 -> 특수문자 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .withUnretained(self)
      .map { $0.0.isValidTextCondition.value }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.textConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 텍스트 필드 모서리 컬러 변경
    input.textFieldEditingDidEnd
      .withUnretained(self)
      .map { $0.0.isValidCondition.value }
      .map { $0 ? UIColor.idorm_gray_300.cgColor : UIColor.idorm_red.cgColor }
      .bind(to: output.textFieldBorderColor)
      .disposed(by: disposeBag)

    // 완료 버튼 -> 오류 팝업 창 띄우기
    input.confirmButtonDidTap
      .withUnretained(self)
      .map { $0.0.isValidCondition.value }
      .filter { $0 == false }
      .map { _ in "조건을 다시 확인해주세요." }
      .bind(to: output.presentPopupVC)
      .disposed(by: disposeBag)
    
    // 특수문자 유효성 검사 -> 특수문자 텍스트 컬러
    isValidTextCondition
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_gray_400 }
      .bind(to: output.textConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 글자 수 유효성 검사 -> 글자 수 텍스트 컬러
    isValidTextCountCondition
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_gray_400 }
      .bind(to: output.countConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 공백 유효성 검사 -> 공백 텍스트 컬러
    isValidSpacingCondition
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_gray_400 }
      .bind(to: output.spacingConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 유효성 조건 전체 검사
    Observable.combineLatest(
      isValidTextCondition.asObservable(),
      isValidSpacingCondition.asObservable(),
      isValidTextCountCondition.asObservable()
    )
    .map { $0.0 && $0.1 && $0.2 ? true : false }
    .bind(to: isValidCondition)
    .disposed(by: disposeBag)
    
    // 텍스트 글자 수 -> 글자 수 유효 조건 검사
    output.currentTextCount
      .map { $0 >= 2 && $0 <= 8 ? true : false }
      .bind(to: isValidTextCountCondition)
      .disposed(by: disposeBag)
    
    // 텍스트 감지 -> 공백 유무 유효 조건 검사
    output.currentText
      .map { $0.contains(" ") ? false : true }
      .bind(to: isValidSpacingCondition)
      .disposed(by: disposeBag)
    
    // 텍스트 감지 -> 특수문자 유효 조건 검사
    output.currentText
      .map { $0.isValidNickname }
      .bind(to: isValidTextCondition)
      .disposed(by: disposeBag)
    
    let email = Logger.instance.currentEmail.value
    let password = Logger.instance.currentPassword.value
    
    switch vcType {
    case .signUp:
      // 완료버튼 -> 회원가입 API
      input.confirmButtonDidTap
        .withUnretained(self)
        .filter { $0.0.isValidCondition.value }
        .do { $0.0.output.isLoading.onNext(true) }
        .map { (email, password, $0.0.currentText) }
        .flatMap {
          APIService.memberProvider.rx.request(.register(id: $0.0, pw: $0.1, nickname: $0.2))
            .asObservable()
            .materialize()
        }
        .withUnretained(self)
        .subscribe(onNext: { owner, event in
          owner.output.isLoading.onNext(false)
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              owner.output.presentCompleteSignUpVC.onNext(Void())
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
      
    case .update:
      // 완료버튼 -> 닉네임 변경 API 요청
      input.confirmButtonDidTap
        .withUnretained(self)
        .map { $0.0.isValidCondition.value }
        .filter { $0 }
        .withUnretained(self)
        .do { $0.0.output.isLoading.onNext(true) }
        .map { $0.0.currentText }
        .flatMap {
          APIService.memberProvider.rx.request(.changeNickname(nickname: $0))
            .asObservable()
            .materialize()
        }
        .withUnretained(self)
        .subscribe { owner, event in
          owner.output.isLoading.onNext(false)
          
          switch event {
          case .next(let response):
            if response.statusCode == 200 {
              let info = APIService.decode(
                ResponseModel<MemberModel.MyInformation>.self,
                data: response.data
              ).data
              MemberInfoStorage.instance.saveMyInformation(from: info)
              owner.output.popVC.onNext(Void())
            } else {
              let error = APIService.decode(ErrorResponseModel.self, data: response.data)
              owner.output.presentPopupVC.onNext(error.message)
            }
          case .error:
            owner.output.presentPopupVC.onNext("네트워크를 다시 확인해주세요.")
          case .completed:
            break
          }
        }
        .disposed(by: disposeBag)
    }
  }
}

import UIKit

import RxSwift
import RxCocoa

final class ChangeNicknameViewModel: ViewModel {
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
    let isLoading = PublishSubject<Bool>()
    let popVC = PublishSubject<Void>()
  }
  
  // MARK: - Properties
  
  let isValidTextCountCondition = BehaviorRelay<Bool>(value: false)
  let isValidSpacingCondition = BehaviorRelay<Bool>(value: false)
  let isValidTextCondition = BehaviorRelay<Bool>(value: false)
  let isValidCondition = BehaviorRelay<Bool>(value: false)
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  // MARK: - Bind
  
  init() {
    mutate()
    
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
      .map { [weak self] in self?.isValidCondition.value ?? false }
      .map { $0 ? false : true }
      .bind(to: output.isHiddenCheckmark)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 글자수 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .map { [weak self] in self?.isValidTextCountCondition.value ?? false }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.countConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 공백 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .map { [weak self] in self?.isValidSpacingCondition.value ?? false }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.spacingConditionLabelTextColor)
      .disposed(by: disposeBag)

    // 텍스트 필드 포커싱 해제 -> 특수문자 텍스트 컬러 변경
    input.textFieldEditingDidEnd
      .map { [weak self] in self?.isValidTextCondition.value ?? false }
      .map { $0 ? UIColor.idorm_blue : UIColor.idorm_red }
      .bind(to: output.textConditionLabelTextColor)
      .disposed(by: disposeBag)
    
    // 텍스트 필드 포커싱 해제 -> 텍스트 필드 모서리 컬러 변경
    input.textFieldEditingDidEnd
      .map { [weak self] in self?.isValidCondition.value ?? false }
      .map { $0 ? UIColor.idorm_gray_300.cgColor : UIColor.idorm_red.cgColor }
      .bind(to: output.textFieldBorderColor)
      .disposed(by: disposeBag)

    // 완료 버튼 -> 오류 팝업 창 띄우기
    input.confirmButtonDidTap
      .map { [weak self] in self?.isValidCondition.value ?? false }
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
        
    // 완료버튼 -> API요청
    input.confirmButtonDidTap
      .map { [unowned self] in self.isValidCondition.value }
      .filter { $0 }
      .map { [weak self] _ in self?.output.currentText.value ?? "" }
      .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(true) })
      .flatMap { APIService.memberProvider.rx.request(.changeNickname(nickname: $0)) }
      .do(onNext: { [weak self] _ in self?.output.isLoading.onNext(false) })
      .subscribe(onNext: { [weak self] response in
        switch response.statusCode {
        case 200:
          let newValue = APIService.decode(MemberModel.LoginResponseModel.self, data: response.data).data
          MemberInfoStorage.instance.myInformation.accept(newValue)
          self?.output.popVC.onNext(Void())
        case 409:
          self?.output.presentPopupVC.onNext("이미 존재하는 닉네임입니다.")
        default: fatalError("닉네임을 변경하지 못했습니다! ")
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func mutate() {
    
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
  }
}

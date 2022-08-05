//
//  SetCalendarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/03.
//

import PanModal
import UIKit
import RxSwift
import RxCocoa

enum SetCalendarVcType {
  case start
  case end
}

class SetCalendarViewController: UIViewController {
  // MARK: - Properties
  lazy var calendarView: CalendarView = {
    let view = CalendarView(type: .set)
    
    return view
  }()
  
  lazy var datePicker: UIDatePicker = {
    let pickerView = UIDatePicker()
    pickerView.datePickerMode = .time
    pickerView.preferredDatePickerStyle = .wheels
    pickerView.backgroundColor = .white
    pickerView.tintColor = .green
    pickerView.setValue(UIColor.black, forKeyPath: "textColor")
    pickerView.setValue(1, forKeyPath: "alpha")
    pickerView.setValue(false, forKeyPath: "highlightsToday")
    
    return pickerView
  }()
  
  lazy var allDayLabel: UILabel = {
    let label = UILabel()
    label.text = "하루종일"
    label.textColor = .black
    label.font = .init(name: Font.regular.rawValue, size: 14)
    
    return label
  }()
  
  lazy var allDayButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    config.image = #imageLiteral(resourceName: "toggleHover(Matching)")
    let btn = UIButton(configuration: config)
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.image = #imageLiteral(resourceName: "toggleHover(Matching)")
      default:
        button.configuration?.image = UIImage(named: "toggle(Matching)")
      }
    }
    btn.configurationUpdateHandler = handler
    
    return btn
  }()
  
  lazy var confirmButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_blue
    var container = AttributeContainer()
    container.font = .init(name: Font.regular.rawValue, size: 14)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("완료", attributes: container)
    let btn = UIButton(configuration: config)
    btn.layer.cornerRadius = 10
    
    return btn
  }()
  
  let type: SetCalendarVcType
  let viewModel: SetCalendarViewModel
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  init(type: SetCalendarVcType, viewModel: SetCalendarViewModel) {
    self.type = type
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    /// 하루종일 버튼 선택
    allDayButton.rx.tap
      .map { [weak self] in
        guard let self = self else { return false }
        self.allDayButton.isSelected = !self.allDayButton.isSelected
        return self.allDayButton.isSelected
      }
      .bind(to: viewModel.output.onChangedAllDayButtonState)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    
    let allDayStack = UIStackView(arrangedSubviews: [ allDayLabel, allDayButton ])
    allDayStack.spacing = 6
    
    [ calendarView, datePicker, allDayStack, confirmButton ]
      .forEach { view.addSubview($0) }
    
    calendarView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.trailing.equalToSuperview()
    }
    
    datePicker.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(allDayStack.snp.top).offset(-32)
      make.height.equalTo(100)
    }

    allDayStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(confirmButton.snp.top).offset(-24)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      make.height.equalTo(50)
    }
  }
}

//
//  OnboardingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit

protocol OnboardingViewDelegate: AnyObject {
    func verifyConfirmButton(index: Int)
}
 
class OnboardingViewController: UIViewController {
    // MARK: - Properties
    let viewModel = OnboardingListViewModel()
    weak var delegate: OnboardingViewDelegate?
    
    lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
        button.tintColor = .gray
        
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: OnboardingTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 70.0
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    lazy var dorm1Button: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.setTitle("1 기숙사", for: .normal)
        button.isSelected = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.backgroundColor = UIColor.mainColor
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(didTapDorm1Button), for: .touchUpInside)
        
        return button
    }()
    
    lazy var dorm2Button: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.setTitle("2 기숙사", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.backgroundColor = UIColor.init(rgb: 0xF4F2FA)
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(didTapDorm2Button), for: .touchUpInside)
        
        return button
    }()
    
    lazy var dorm3Button: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.baseBackgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.setTitle("3 기숙사", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.backgroundColor = UIColor.init(rgb: 0xF4F2FA)
        button.layer.cornerRadius = 15.0
        button.addTarget(self, action: #selector(didTapDorm3Button), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        
        return singleTapGestureRecognizer
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapDorm1Button() {
        dorm1Button.isSelected = true
        dorm1Button.setTitleColor(UIColor.white, for: .normal)
        dorm1Button.backgroundColor = .mainColor
        
        dorm2Button.isSelected = false
        dorm2Button.setTitleColor(UIColor.gray, for: .normal)
        dorm2Button.backgroundColor = .init(rgb: 0xF4F2FA)
        
        dorm3Button.isSelected = false
        dorm3Button.setTitleColor(UIColor.gray, for: .normal)
        dorm3Button.backgroundColor = .init(rgb: 0xF4F2FA)
    }
    
    @objc private func didTapDorm2Button() {
        dorm1Button.isSelected = false
        dorm1Button.setTitleColor(UIColor.gray, for: .normal)
        dorm1Button.backgroundColor = .init(rgb: 0xF4F2FA)
        
        dorm2Button.isSelected = true
        dorm2Button.setTitleColor(UIColor.white, for: .normal)
        dorm2Button.backgroundColor = .mainColor
        
        dorm3Button.isSelected = false
        dorm3Button.setTitleColor(UIColor.gray, for: .normal)
        dorm3Button.backgroundColor = .init(rgb: 0xF4F2FA)
    }

    @objc private func didTapDorm3Button() {
        dorm1Button.isSelected = false
        dorm1Button.setTitleColor(UIColor.gray, for: .normal)
        dorm1Button.backgroundColor = .init(rgb: 0xF4F2FA)
        
        dorm2Button.isSelected = false
        dorm2Button.setTitleColor(UIColor.gray, for: .normal)
        dorm2Button.backgroundColor = .init(rgb: 0xF4F2FA)
        
        dorm3Button.isSelected = true
        dorm3Button.setTitleColor(UIColor.white, for: .normal)
        dorm3Button.backgroundColor = .mainColor
    }
    
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        view.addGestureRecognizer(tapGesture)
        
        let buttonStack = UIStackView(arrangedSubviews: [ dorm1Button, dorm2Button, dorm3Button ])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12.0
        
        view.addSubview(tableView)
        view.addSubview(buttonStack)
        
        tableView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(buttonStack.snp.bottom).offset(8.0)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(14)
            make.height.equalTo(34.0)
        }
    }
    
    private func verifyButton(type: OnboardingCellType) {
        if type == .ox {
            for index in 0..<(viewModel.questionsNumberOfRowsInSection) {
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = tableView.cellForRow(at: indexPath) as? OnboardingTableViewCell else { return }
                if (cell.leftButton.isSelected || cell.rightButton.isSelected) {
                    continue
                } else {
                    completeButton.isEnabled = false
                    return
                }
            }
            completeButton.isEnabled = true
            return
        } else {
            let row = viewModel.questionsNumberOfRowsInSection - 1
            let indexPath = IndexPath(row: row, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? OnboardingTableViewCell else { return }
//            if (cell.femaleButton.isSelected || cell.maleButton.isSelected) {
//                return
//            } else {
//                return
//            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension OnboardingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingTableViewCell.identifier, for: indexPath) as? OnboardingTableViewCell else { return UITableViewCell() }
        let onboardingVM = viewModel.gainOnboardingVM(index: indexPath.row)
        cell.viewModel = onboardingVM
        cell.index = indexPath.row
        cell.delegate = self
        
        if indexPath.row == 0 {
            cell.configureUI(type: .period)
            return cell
        } else if indexPath.row == 1 {
            cell.configureUI(type: .gender)
            return cell
        } else if indexPath.row == 2 {
            cell.configureUI(type: .age)
            return cell
        } else {
            cell.configureUI(type: .ox)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.questionsNumberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = OnboardingTableHeaderView()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension OnboardingViewController: OnboardingTableViewCellDelegate {
    func didTapXmarkButton(type: OnboardingCellType, index: Int) {
        verifyButton(type: type)
        delegate?.verifyConfirmButton(index: index)
    }
    
    func didTapOmarkButton(type: OnboardingCellType, index: Int) {
        verifyButton(type: type)
        delegate?.verifyConfirmButton(index: index)
    }
}


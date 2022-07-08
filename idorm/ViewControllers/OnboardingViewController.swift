//
//  OnboardingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit
import SnapKit
 
class OnboardingViewController: UIViewController {
    // MARK: - Properties
    let viewModel = OnboardingListViewModel()
    
    lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .semibold)
        button.tintColor = .blue
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: OnboardingTableViewCell.identifier)
        tableView.rowHeight = 100.0
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapCompleteButton() {
        print("CompleteButton Tapped!")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 정보 입력"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeButton)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        completeButton.isEnabled = false
    }
    
    private func verifyCompleteButton() {
        for index in 0..<(viewModel.numberOfRowsInSection) {
            let indexPath = IndexPath(row: index, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? OnboardingTableViewCell else { return }
            if (cell.xmarkButton.isSelected || cell.omarkButton.isSelected) {
                continue
            } else {
                completeButton.isEnabled = false
                return
            }
        }
        completeButton.isEnabled = true
        return
    }
}

extension OnboardingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingTableViewCell.identifier, for: indexPath) as? OnboardingTableViewCell else { return UITableViewCell() }
        let onboardingVM = viewModel.gainOnboardingVM(index: indexPath.row)
        cell.viewModel = onboardingVM
        cell.configureUI()
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return OnboardingTableHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
}

extension OnboardingViewController: OnboardingTableViewCellDelegate {
    func didTapXmarkButton() {
        verifyCompleteButton()
        print("XmarkButton Tapped!")
    }
    
    func didTapOmarkButton() {
        verifyCompleteButton()
        print("OmarkButton Tapped!")
    }
}

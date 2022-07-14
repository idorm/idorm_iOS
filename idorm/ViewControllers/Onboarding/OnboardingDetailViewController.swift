//
//  OnboardingDetailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

protocol OnboardingDetailViewDelegate: AnyObject {
    func detailVerifyConfirmButton(index: Int, result: Bool)
}

class OnboardingDetailViewController: UIViewController {
    // MARK: - Properties
    let viewModel = OnboardingListViewModel()
    weak var delegate: OnboardingDetailViewDelegate?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(OnboardingDetailTableViewCell.self, forCellReuseIdentifier: OnboardingDetailTableViewCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 120
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        gesture.cancelsTouchesInView = false
        
        return gesture
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Selectors
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        tableView.addGestureRecognizer(tapGesture)
    }
}

extension OnboardingDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingDetailTableViewCell.identifier, for: indexPath) as? OnboardingDetailTableViewCell else { return UITableViewCell() }
        cell.viewModel = viewModel.gainOnboardingDetailVM(index: indexPath.row)
        cell.index = indexPath.row
        cell.delegate = self
        
        if indexPath.row == 3 {
            cell.configureUI(type: .Optional)
            return cell
        } else if indexPath.row == 4 {
            cell.configureUI(type: .Free)
            return cell
        } else {
            cell.configureUI(type: .Essential)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.detailNumberOfRowsInSection
    }
}

extension OnboardingDetailViewController: OnboardingDetailTableViewCellDelegate {
    func textFieldIsEmptyTrue(index: Int) {
        delegate?.detailVerifyConfirmButton(index: index, result: false)
    }
    
    func textFieldIsEmptyFalse(index: Int) {
        delegate?.detailVerifyConfirmButton(index: index, result: true)
    }
}

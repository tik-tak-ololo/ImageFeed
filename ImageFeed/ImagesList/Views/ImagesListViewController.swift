//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 31.01.2026.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    var presenter: ImagesListPresenterProtocol?

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlackIOS
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        setupTableView()

        presenter?.viewDidLoad()
    }

    private func setupView() {
        view.backgroundColor = .ypBlackIOS
    }

    private func setupSubviews() {
        view.addSubview(tableView)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configure(_ cell: ImagesListCell, with viewModel: ImagesListCellViewModel) {
        cell.cellImage.kf.indicatorType = .activity

        let placeholder = UIImage(resource: .placeholder)
        cell.cellImage.tintColor = .systemGray3
        cell.cellImage.contentMode = .center
        cell.cellImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)

        if let imageURL = viewModel.imageURL {
            cell.cellImage.kf.setImage(
                with: imageURL,
                placeholder: placeholder,
                options: [.transition(.fade(0.2)), .cacheOriginalImage]
            )
        } else {
            cell.cellImage.image = placeholder
        }

        cell.dateLabel.text = viewModel.dateText
        cell.setIsLiked(viewModel.isLiked)
    }
}

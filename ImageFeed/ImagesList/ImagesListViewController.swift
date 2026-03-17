//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 31.01.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlackIOS
    }
    
    private func setupTableView() {
        // Регистрация ячейки
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.backgroundColor = .ypBlackIOS

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Заменяем prepare(for:sender:) на явную навигацию кодом
    func showSingleImage(at indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let singleImageViewController = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {
            assertionFailure("Не удалось найти SingleImageViewController по идентификатору")
            return
        }
        
        let image = UIImage(named: photosName[indexPath.row])
        singleImageViewController.image = image
        present(singleImageViewController, animated: true)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }

        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())

        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }


}


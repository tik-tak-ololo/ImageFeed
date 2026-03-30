//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 31.01.2026.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    let tableView = {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlackIOS
        
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var photos: [Photo] = []
    let imagesListService = ImagesListService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        setupTableView()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        
        imagesListService.fetchPhotosNextPage(){ result in}
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
    
    // Заменяем prepare(for:sender:) на явную навигацию кодом
    func showSingleImage(at indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        let url = URL(string: photo.largeImageURL)
        guard let url else { return }
        
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.imageURL = url
        present(singleImageViewController, animated: true)
    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    deinit {
        if let imagesListServiceObserver {
            NotificationCenter.default.removeObserver(imagesListServiceObserver)
        }
    }
    
    func configureCell(imageListCell: ImagesListCell, with photo: Photo) {

        imageListCell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder_image")
        if let imageURL = URL(string: photo.smallImageURL) {
            imageListCell.cellImage.kf.setImage(
                with: imageURL,
                placeholder: placeholder,
                options: [.transition(.fade(0.2)), .cacheOriginalImage])
        }
        
        imageListCell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        } ?? ""
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        imageListCell.likeButton.setImage(likeImage, for: .normal)
        
    }

}


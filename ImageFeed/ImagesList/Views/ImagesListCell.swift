//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Хмелёв on 04.02.2026.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    weak var delegate: ImagesListCellDelegate?

    let cellImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 16
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .ypWhiteIOS
        return dateLabel
    }()

    let likeButton: UIButton = {
        let likeButton = UIButton(type: .custom)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.accessibilityIdentifier = "likeButton"
        likeButton.setImage(UIImage(resource: .likeButtonOff), for: .normal)
        return likeButton
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupSubviews()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupSubviews()
        setupConstraints()
        setupActions()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(resource: .placeholder)
        cellImage.kf.indicatorType = .none
        dateLabel.text = nil
        setIsLiked(false)
    }

    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked
            ? UIImage(resource: .likeButtonOn)
            : UIImage(resource: .likeButtonOff)
        likeButton.setImage(image, for: .normal)
        likeButton.accessibilityValue = isLiked ? "liked" : "not_liked"
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
    }

    private func setupSubviews() {
        contentView.addSubview(cellImage)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellImage.trailingAnchor),

            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor)
        ])
    }

    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeButtonClicked(_:)), for: .touchUpInside)
    }

    @objc
    private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
}

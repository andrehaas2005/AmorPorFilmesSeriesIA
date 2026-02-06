//
//  WatchlistPosterCell.swift
//  AmorPorFilmesSeries
//
//  Created by Jules on 05/06/25.
//

import UIKit
import SnapKit
import Kingfisher

class WatchlistPosterCell: UICollectionViewCell {

    static let identifier = "WatchlistPosterCell"

    private let posterImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()

    private let ratingBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()

    private let starIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = Color.accentYellow
        return iv
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let statusIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = Color.primary
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 10
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(posterImage)
        contentView.addSubview(titleLabel)
        posterImage.addSubview(ratingBadge)
        posterImage.addSubview(statusIcon)

        ratingBadge.addSubview(starIcon)
        ratingBadge.addSubview(ratingLabel)

        posterImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(contentView.snp.width).multipliedBy(1.5)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImage.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        ratingBadge.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }

        starIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }

        ratingLabel.snp.makeConstraints { make in
            make.leading.equalTo(starIcon.snp.trailing).offset(2)
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }

        statusIcon.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(20)
        }
    }

    func configure(title: String, rating: String, imageURL: String?) {
        titleLabel.text = title
        ratingLabel.text = rating
        if let urlString = imageURL, let url = URL(string: urlString) {
            posterImage.kf.setImage(with: url, placeholder: UIImage(named: "movie-placeholder"))
        } else {
            posterImage.image = UIImage(named: "movie-placeholder")
        }
    }
}

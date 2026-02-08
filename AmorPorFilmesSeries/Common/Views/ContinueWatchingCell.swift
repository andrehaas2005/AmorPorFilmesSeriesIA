//
//  ContinueWatchingCell.swift
//  AmorPorFilmesSeries
//
//  Created by Jules on 05/06/25.
//

import UIKit
import SnapKit
import Kingfisher

class ContinueWatchingCell: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface.withAlphaComponent(0.4)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.03).cgColor
        return view
    }()

    private let posterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textColor = .white.withAlphaComponent(0.3)
        return label
    }()

    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = Color.teal
        progress.trackTintColor = .white.withAlphaComponent(0.05)
        progress.layer.cornerRadius = 1.5
        progress.clipsToBounds = true
        return progress
    }()

    private let playButton: UIButton = {
        let btn = UIButton()
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: "play.circle")
            btn.setImage(image, for: .normal)
            btn.tintColor = Color.teal.withAlphaComponent(0.6)
        }
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        containerView.addSubview(posterImage)
        containerView.addSubview(titleLabel)
        containerView.addSubview(infoLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(playButton)

        posterImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }

        playButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImage).offset(4)
            make.leading.equalTo(posterImage.snp.trailing).offset(16)
            make.trailing.equalTo(playButton.snp.leading).offset(-8)
        }

        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(titleLabel)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(3)
        }
    }

    func configure(title: String, info: String, progress: Float, imageURL: String?) {
        titleLabel.text = title
        infoLabel.text = info.uppercased()
        progressView.progress = progress

        if let urlString = imageURL, let url = URL(string: urlString) {
            posterImage.kf.setImage(with: url, placeholder: UIImage(named: "movie-placeholder"))
        } else {
            posterImage.image = UIImage(named: "movie-placeholder")
        }
    }
}

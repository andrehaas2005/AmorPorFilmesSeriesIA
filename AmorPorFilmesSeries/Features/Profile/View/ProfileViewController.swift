//
//  ProfileViewController.swift
//  AmorPorFilmesSeries
//
//  Created by Jules on 05/06/25.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = Color.surface
        iv.layer.borderWidth = 4
        iv.layer.borderColor = Color.primary.withAlphaComponent(0.2).cgColor
        if #available(iOS 13.0, *) {
            iv.image = UIImage(systemName: "person.fill")
            iv.tintColor = .gray
        }
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Andre Haas"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "andre.haas@example.com"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let settingsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 1
        stack.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.backgroundDark
        title = "Perfil"
        setupUI()
        setupSettings()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in make.edges.equalToSuperview() }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(settingsStackView)

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    private func setupSettings() {
        let options = [
            ("Editar Perfil", "person"),
            ("Notificações", "bell"),
            ("Privacidade", "lock"),
            ("Ajuda & Suporte", "questionmark.circle"),
            ("Sair", "arrow.right.square")
        ]

        for (title, icon) in options {
            let row = createSettingRow(title: title, icon: icon, isDestructive: title == "Sair")
            settingsStackView.addArrangedSubview(row)
        }
    }

    private func createSettingRow(title: String, icon: String, isDestructive: Bool) -> UIView {
        let row = UIView()
        row.backgroundColor = Color.backgroundDark

        let iconView = UIImageView()
        if #available(iOS 13.0, *) {
            iconView.image = UIImage(systemName: icon)
        }
        iconView.tintColor = isDestructive ? .systemRed : .white
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = title
        label.textColor = isDestructive ? .systemRed : .white
        label.font = UIFont.systemFont(ofSize: 16)

        let chevron = UIImageView()
        if #available(iOS 13.0, *) {
            chevron.image = UIImage(systemName: "chevron.right")
        }
        chevron.tintColor = .gray
        chevron.contentMode = .scaleAspectFit

        row.addSubview(iconView)
        row.addSubview(label)
        row.addSubview(chevron)

        row.snp.makeConstraints { make in make.height.equalTo(60) }

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        return row
    }
}

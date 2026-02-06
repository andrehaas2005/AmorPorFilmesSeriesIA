//
//  DetailsViewController.swift
//  AmorPorFilmesSeries
//
//  Created by Andre Haas on 28/05/25.
//

import UIKit
import SnapKit
import Kingfisher

class DetailsViewController: UIViewController {

    private let viewModel: DetailsViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    private let backdropImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let gradientView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, Color.backgroundDark.withAlphaComponent(0.8).cgColor, Color.backgroundDark.cgColor]
        gradient.locations = [0, 0.7, 1]
        view.layer.addSublayer(gradient)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(hex: "#baba9c")
        return label
    }()

    private let actionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private let favoriteButton = createActionButton(title: "Favoritar", icon: "heart.fill")
    private let watchlistButton = createActionButton(title: "Quero Ver", icon: "bookmark.fill")

    private let watchedButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Marcar como Assistido", for: .normal)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        }
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .black
        btn.layer.borderColor = Color.purple.withAlphaComponent(0.6).cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 12
        btn.tintColor = Color.purple
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    // Series Progress Section (Screen 4)
    private let progressSection = createSectionTitle("Seu Progresso")
    private let progressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Color.primary.withAlphaComponent(0.2).cgColor
        return view
    }()

    // Content Sections
    private let providersSection = createSectionTitle("Onde Assistir")
    private let providersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let synopsisSection = createSectionTitle("Sinopse")
    private let synopsisLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#baba9c")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let castSection = createSectionTitle("Elenco")
    private let castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    private let trailerSection = createSectionTitle("Trailer")
    private let trailerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let playIcon = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        playIcon.tintColor = Color.purple
        view.addSubview(playIcon)
        playIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(64)
        }
        return view
    }()

    private let ratingSection = createSectionTitle("Sua Nota")
    private let ratingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.layer.borderColor = Color.purple.withAlphaComponent(0.2).cgColor
        view.layer.borderWidth = 1
        return view
    }()

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.backgroundDark
        setupUI()
        setupBindings()
        setupNavigation()
        setupMockData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.sublayers?.first?.frame = gradientView.bounds
    }

    private func setupNavigation() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.largeTitleDisplayMode = .never

        if #available(iOS 13.0, *) {
            let shareItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItem = shareItem
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }

        contentView.addSubview(backdropImage)
        backdropImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(450)
        }

        backdropImage.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(backdropImage).offset(-40)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        contentView.addSubview(metadataLabel)
        metadataLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }

        contentView.addSubview(actionsStackView)
        actionsStackView.addArrangedSubview(favoriteButton)
        actionsStackView.addArrangedSubview(watchlistButton)

        actionsStackView.snp.makeConstraints { make in
            make.top.equalTo(backdropImage.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }

        contentView.addSubview(watchedButton)
        watchedButton.snp.makeConstraints { make in
            make.top.equalTo(actionsStackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }

        let mainContentStack = UIStackView(arrangedSubviews: [
            providersSection, providersStackView,
            synopsisSection, synopsisLabel,
            progressSection, progressContainer,
            castSection, castCollectionView,
            trailerSection, trailerView,
            ratingSection, ratingContainer
        ])
        mainContentStack.axis = .vertical
        mainContentStack.spacing = 16
        mainContentStack.setCustomSpacing(24, after: providersStackView)
        mainContentStack.setCustomSpacing(24, after: synopsisLabel)
        mainContentStack.setCustomSpacing(24, after: progressContainer)
        mainContentStack.setCustomSpacing(24, after: castCollectionView)
        mainContentStack.setCustomSpacing(24, after: trailerView)

        contentView.addSubview(mainContentStack)
        mainContentStack.snp.makeConstraints { make in
            make.top.equalTo(watchedButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-40)
        }

        castCollectionView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        trailerView.snp.makeConstraints { make in
            make.height.equalTo(trailerView.snp.width).multipliedBy(0.56)
        }

        ratingContainer.snp.makeConstraints { make in
            make.height.equalTo(100)
        }

        progressContainer.snp.makeConstraints { make in
            make.height.equalTo(180)
        }

        setupRatingView()
        setupProgressView()
    }

    private func setupProgressView() {
        let lastEpLabel = UILabel()
        lastEpLabel.text = "ÚLTIMO EPISÓDIO VISTO"
        lastEpLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lastEpLabel.textColor = Color.primary

        let epCodeLabel = UILabel()
        epCodeLabel.text = "T02E05"
        epCodeLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        epCodeLabel.textColor = .white

        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = 0.45
        progressBar.progressTintColor = Color.primary
        progressBar.trackTintColor = .white.withAlphaComponent(0.1)

        let nextButton = UIButton()
        nextButton.setTitle("Próximo Episódio: T02E06", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nextButton.backgroundColor = Color.primary
        nextButton.layer.cornerRadius = 12

        progressContainer.addSubview(lastEpLabel)
        progressContainer.addSubview(epCodeLabel)
        progressContainer.addSubview(progressBar)
        progressContainer.addSubview(nextButton)

        lastEpLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        epCodeLabel.snp.makeConstraints { make in
            make.top.equalTo(lastEpLabel.snp.bottom).offset(4)
            make.leading.equalTo(lastEpLabel)
        }
        progressBar.snp.makeConstraints { make in
            make.top.equalTo(epCodeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(progressBar.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
    }

    private func setupRatingView() {
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 8
        for i in 0..<5 {
            let star = UIImageView(image: UIImage(systemName: i < 4 ? "star.fill" : "star"))
            star.tintColor = i < 4 ? Color.purple : .darkGray
            starsStack.addArrangedSubview(star)
        }

        let scoreLabel = UILabel()
        scoreLabel.text = "4 / 5"
        scoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        scoreLabel.textColor = .white

        let ratingStack = UIStackView(arrangedSubviews: [starsStack, scoreLabel])
        ratingStack.axis = .vertical
        ratingStack.alignment = .center
        ratingStack.spacing = 8

        ratingContainer.addSubview(ratingStack)
        ratingStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.title.bind { [weak self] text in
            self?.titleLabel.text = text
        }

        viewModel.imageUrl.bind { [weak self] url in
            self?.backdropImage.kf.setImage(with: url, placeholder: UIImage(named: "movie-placeholder"))
        }

        viewModel.description.bind { [weak self] text in
            self?.synopsisLabel.text = text
        }

        metadataLabel.text = "2024 • 2h 46m • Ficção Científica, Ação"
    }

    private func setupMockData() {
        let netflix = createProviderView(name: "Netflix", color: UIColor(hex: "#E50914"))
        let max = createProviderView(name: "Max", color: UIColor(hex: "#002be7"))

        let row1 = UIStackView(arrangedSubviews: [netflix, max])
        row1.axis = .horizontal
        row1.spacing = 12
        row1.distribution = .fillEqually
        providersStackView.addArrangedSubview(row1)

        castCollectionView.register(ActorCell.self, forCellWithReuseIdentifier: "CastCell")
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
    }

    private static func createActionButton(title: String, icon: String) -> UIButton {
        let btn = UIButton()
        btn.setTitle(" " + title, for: .normal)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: icon), for: .normal)
        }
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .black
        btn.layer.borderColor = Color.purple.withAlphaComponent(0.3).cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 12
        btn.tintColor = Color.purple
        return btn
    }

    private static func createSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }

    private func createProviderView(name: String, color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 12

        let label = UILabel()
        label.text = name
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.snp.makeConstraints { make in make.height.equalTo(48) }
        return view
    }
}

extension DetailsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! ActorCell
        // Mock data
        cell.configure(name: "Timothée Chalamet", imageURL: nil)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
}

class ActorCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40
        iv.layer.borderWidth = 2
        iv.layer.borderColor = Color.purple.withAlphaComponent(0.2).cgColor
        iv.backgroundColor = .darkGray
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(name: String, imageURL: String?) {
        nameLabel.text = name
    }
}

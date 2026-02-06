//
//  HomeViewController.swift
//  PaixaoPorFilmesESeries
//
//  Created by Andre Haas on 28/05/25.
//

import Kingfisher
import UIKit
import SnapKit

protocol HomeViewControllerDelegate: AnyObject {
    func didSelectMovie(_ movie: Movie)
    func didRequestLogout()
}

class HomeViewController: UIViewController {
    
    weak var delegate: HomeViewControllerDelegate?
    private let viewModel: HomeViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    private let posterHero: PosterCollectionView = {
        let poster = PosterCollectionView(service: MockMovieService())
        return poster
    }()

    private let continueWatchingLabel = createSectionLabel("CONTINUAR ASSISTINDO")
    private let continueWatchingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let trendingLabel = createSectionLabel("TENDÊNCIAS DA SEMANA")
    private let trendingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let recommendationsLabel = createSectionLabel("RECOMENDADO PARA VOCÊ")
    private let recommendationsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = Color.teal
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupUI()
        setupBindings()
        registerCollection()
        viewModel.fetchData()
    }
    
    private func setupTheme() {
        view.backgroundColor = Color.backgroundDark

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = Color.backgroundDark.withAlphaComponent(0.8)
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        title = "Pipocando"

        if #available(iOS 13.0, *) {
            let searchItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
            let notifyItem = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: nil, action: nil)
            searchItem.tintColor = .white.withAlphaComponent(0.4)
            notifyItem.tintColor = .white.withAlphaComponent(0.4)
            navigationItem.rightBarButtonItems = [notifyItem, searchItem]

            let logoItem = UIBarButtonItem(image: UIImage(systemName: "movieclapper"), style: .plain, target: nil, action: nil)
            logoItem.tintColor = Color.teal
            navigationItem.leftBarButtonItem = logoItem
        }
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        mainStackView.addArrangedSubview(posterHero)
        posterHero.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).multipliedBy(1.25)
        }

        let continueSection = createSectionStack(label: continueWatchingLabel, content: continueWatchingStackView)
        mainStackView.addArrangedSubview(continueSection)

        let trendingSection = createSectionStack(label: trendingLabel, content: trendingCollectionView)
        mainStackView.addArrangedSubview(trendingSection)
        trendingCollectionView.snp.makeConstraints { make in
            make.height.equalTo(180)
        }

        let recommendationsSection = createSectionStack(label: recommendationsLabel, content: recommendationsCollectionView)
        mainStackView.addArrangedSubview(recommendationsSection)
        recommendationsCollectionView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }

        let spacer = UIView()
        spacer.snp.makeConstraints { make in make.height.equalTo(100) }
        mainStackView.addArrangedSubview(spacer)

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func createSectionStack(label: UILabel, content: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [label, content])
        stack.axis = .vertical
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        if content is UICollectionView {
            stack.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        }
        return stack
    }
    
    private func setupBindings() {
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading == true {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.items.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.trendingCollectionView.reloadData()
                self?.recommendationsCollectionView.reloadData()
            }
        }
        
        viewModel.continueWatching.bind { [weak self] items in
          guard let items = items else {return}
            DispatchQueue.main.async {
                self?.updateContinueWatching(items)
            }
        }
    }
  
    private func updateContinueWatching(_ items: [(title: String, info: String, progress: Float, image: String)]) {
        continueWatchingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let cell = ContinueWatchingCell()
            cell.configure(title: item.title, info: item.info, progress: item.progress, imageURL: item.image)
            cell.snp.makeConstraints { make in make.height.equalTo(88) }
            continueWatchingStackView.addArrangedSubview(cell)
        }
    }
    
    private func registerCollection() {
        [trendingCollectionView, recommendationsCollectionView].forEach { cv in
            cv.delegate = self
            cv.dataSource = self
            cv.register(MovieCarouselCell.self, forCellWithReuseIdentifier: MovieCarouselCell.identifier)
        }
    }
    
    private static func createSectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white.withAlphaComponent(0.9)
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: title.count))
        label.attributedText = attributedString
        return label
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.items.value?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
  UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCarouselCell.identifier,
                                                        for: indexPath) as? MovieCarouselCell
    else { return UICollectionViewCell() }
    
    if let movie = viewModel.items.value?[indexPath.item] {
      cell.configure(with: movie)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == trendingCollectionView {
      return CGSize(width: 100, height: 160)
    } else {
      return CGSize(width: 160, height: 100)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let movie = viewModel.items.value?[indexPath.item] {
      delegate?.didSelectMovie(movie)
    }
  }
}

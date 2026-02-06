//
//  WatchlistViewController.swift
//  AmorPorFilmesSeries
//
//  Created by Andre Haas on 03/06/25.
//

import UIKit
import SnapKit

class WatchlistViewController: UIViewController {
    
    var viewModel: WatchlistViewModel!
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Minha Lista"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let filterButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Filtrar", for: .normal)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        }
        btn.setTitleColor(Color.primary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.tintColor = Color.primary
        return btn
    }()

    private let segmentedControl: UISegmentedControl = {
        let items = ["Assistidos", "Interesse", "Favoritos"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = .clear

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Color.primary,
            .font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ]

        sc.setTitleTextAttributes(normalAttributes, for: .normal)
        sc.setTitleTextAttributes(selectedAttributes, for: .selected)
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        return sc
    }()

    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary
        return view
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        return cv
    }()

    init(viewModel: WatchlistViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.primaryDark
        setupNavigation()
        setupUI()
        setupCollectionView()
        setupBindings()
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUnderlinePosition()
    }

    private func setupNavigation() {
        title = "Pipocando"
        navigationController?.navigationBar.prefersLargeTitles = false

        if #available(iOS 13.0, *) {
            let searchItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
            let profileItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItems = [profileItem, searchItem]

            let logoItem = UIBarButtonItem(image: UIImage(systemName: "movieclapper"), style: .plain, target: nil, action: nil)
            logoItem.tintColor = Color.primary
            navigationItem.leftBarButtonItem = logoItem
        }
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(filterButton)
        view.addSubview(segmentedControl)
        view.addSubview(underlineView)
        view.addSubview(collectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        underlineView.snp.makeConstraints { make in
            make.bottom.equalTo(segmentedControl)
            make.height.equalTo(3)
            make.width.equalTo(view.snp.width).dividedBy(3)
            make.leading.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WatchlistPosterCell.self, forCellWithReuseIdentifier: WatchlistPosterCell.identifier)
    }

    private func setupBindings() {
        viewModel.items.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }

    @objc private func segmentChanged() {
        updateUnderlinePosition()
        collectionView.reloadData()
    }

    private func updateUnderlinePosition() {
        let segmentWidth = view.frame.width / 3
        let leadingDistance = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex)

        UIView.animate(withDuration: 0.3) {
            self.underlineView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(leadingDistance)
            }
            self.view.layoutIfNeeded()
        }
    }
}

extension WatchlistViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchlistPosterCell.identifier, for: indexPath) as! WatchlistPosterCell
        if let item = viewModel.items.value?[indexPath.item] {
            cell.configure(title: item.title, rating: item.rating, imageURL: item.image)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16 * 2 - 16) / 2
        return CGSize(width: width, height: width * 1.5 + 30)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectMovie(at: indexPath.item)
    }
}

//
//  CalendarViewController.swift
//  AmorPorFilmesSeries
//
//  Created by Jules on 05/06/25.
//

import UIKit
import SnapKit

class CalendarViewController: UIViewController {
    private let viewModel: CalendarViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let dateSelectorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return cv
    }()

    private let timelineTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        return tv
    }()

    private var timelineTableViewHeightConstraint: Constraint?

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.backgroundDark
        setupNavigation()
        setupUI()
        setupCollections()
        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }

    private func setupNavigation() {
        title = "Calendário"
        if #available(iOS 13.0, *) {
            let searchItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
            let settingsItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: nil, action: nil)
            navigationItem.rightBarButtonItems = [settingsItem, searchItem]
            let profileImage = UIImageView(image: UIImage(systemName: "person.circle.fill"))
            profileImage.tintColor = Color.primary.withAlphaComponent(0.2)
            profileImage.snp.makeConstraints { make in make.width.height.equalTo(32) }
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImage)
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        let updateNotifLabel = createSectionLabel("NOTIFICAÇÕES DE ATUALIZAÇÃO")
        let updateCount = UILabel()
        updateCount.text = "2"
        updateCount.textColor = .white
        updateCount.backgroundColor = Color.primary
        updateCount.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        updateCount.textAlignment = .center
        updateCount.layer.cornerRadius = 10
        updateCount.clipsToBounds = true

        let notifHeader = UIStackView(arrangedSubviews: [updateNotifLabel, updateCount])
        notifHeader.spacing = 8
        updateCount.snp.makeConstraints { make in make.width.height.equalTo(20) }

        contentView.addSubview(notifHeader)
        notifHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        let notifCard = UIView()
        notifCard.backgroundColor = Color.surface.withAlphaComponent(0.4)
        notifCard.layer.cornerRadius = 16
        notifCard.layer.borderWidth = 1
        notifCard.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        contentView.addSubview(notifCard)
        notifCard.snp.makeConstraints { make in
            make.top.equalTo(notifHeader.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }

        contentView.addSubview(dateSelectorCollectionView)
        dateSelectorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(notifCard.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        let todayHeader = UILabel()
        todayHeader.text = "Lançamentos de Hoje"
        todayHeader.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        todayHeader.textColor = .white

        let todayDate = UILabel()
        todayDate.text = "Quarta-feira, 14 de Agosto"
        todayDate.font = UIFont.systemFont(ofSize: 14)
        todayDate.textColor = .gray

        contentView.addSubview(todayHeader)
        contentView.addSubview(todayDate)

        todayHeader.snp.makeConstraints { make in
            make.top.equalTo(dateSelectorCollectionView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }

        todayDate.snp.makeConstraints { make in
            make.top.equalTo(todayHeader.snp.bottom).offset(4)
            make.leading.equalTo(todayHeader)
        }

        contentView.addSubview(timelineTableView)
        timelineTableView.snp.makeConstraints { make in
            make.top.equalTo(todayDate.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview()
            self.timelineTableViewHeightConstraint = make.height.equalTo(0).priority(.low).constraint
        }
    }

    private func setupCollections() {
        dateSelectorCollectionView.delegate = self
        dateSelectorCollectionView.dataSource = self
        dateSelectorCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.register(TimelineCell.self, forCellReuseIdentifier: "TimelineCell")
    }

    private func setupBindings() {
        viewModel.dates.bind { [weak self] _ in
            DispatchQueue.main.async { self?.dateSelectorCollectionView.reloadData() }
        }
        viewModel.releases.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.timelineTableView.reloadData()
                self?.updateTableViewHeight()
            }
        }
    }

    private func updateTableViewHeight() {
        timelineTableView.layoutIfNeeded()
        timelineTableViewHeightConstraint?.update(offset: timelineTableView.contentSize.height)
    }

    private func createSectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = Color.primary
        return label
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dates.value?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        if let item = viewModel.dates.value?[indexPath.item] {
            cell.configure(day: item.day, date: item.date, isSelected: item.isSelected)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 72)
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.releases.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        if let item = viewModel.releases.value?[indexPath.row] {
            cell.configure(title: item.title, episode: item.episode, time: item.time, isFirst: item.isFirst, isLast: indexPath.row == (viewModel.releases.value?.count ?? 0) - 1)
        }
        return cell
    }
}

class DateCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(day: String, date: String, isSelected: Bool) {
        dayLabel.text = day
        dateLabel.text = date
        contentView.backgroundColor = isSelected ? Color.primary : Color.surface.withAlphaComponent(0.4)
        dayLabel.textColor = isSelected ? .white.withAlphaComponent(0.8) : .gray
        dateLabel.textColor = isSelected ? .white : .white
    }
}

class TimelineCell: UITableViewCell {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()

    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.backgroundColor = .darkGray
        return view
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface.withAlphaComponent(0.4)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let episodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(lineView)
        contentView.addSubview(dotView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(cardView)

        cardView.addSubview(titleLabel)
        cardView.addSubview(episodeLabel)

        dotView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        lineView.snp.makeConstraints { make in
            make.centerX.equalTo(dotView)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(2)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(dotView).offset(8)
            make.leading.equalTo(dotView.snp.trailing).offset(16)
        }

        cardView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
            make.leading.equalTo(timeLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }

        episodeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(title: String, episode: String, time: String, isFirst: Bool, isLast: Bool) {
        titleLabel.text = title
        episodeLabel.text = episode
        timeLabel.text = time
        if isFirst {
            dotView.backgroundColor = Color.primary
            if #available(iOS 13.0, *) {
                let icon = UIImageView(image: UIImage(systemName: "bell.fill"))
                icon.tintColor = .white
                dotView.addSubview(icon)
                icon.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(18) }
            }
        }
    }
}

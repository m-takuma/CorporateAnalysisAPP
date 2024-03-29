//
//  SettingViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/02/27.
//

// swiftlint:disable force_cast

import UIKit
import SwiftUI
import SafariServices
import GoogleMobileAds

class SettingViewController: UIViewController, UICollectionViewDelegate {
    var bannerView = GADBannerView()
    private enum SettingSection: Int, Hashable, CaseIterable, CustomStringConvertible {
        case user
        case app
        
        var description: String {
            switch self {
            case .user: return "user"
            case .app: return "app"
            }
        }

    }
    
    struct User: Hashable {
        private let indentifier = UUID()
        let id: String?
        let name: String?
        init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }

    struct Item: Hashable {
        // swiftlint:disable nesting
        enum CellType {
            case cell, header, footer
        }
        // swiftlint:enable nesting
        private let identifier = UUID()
        let title: String?
        let image: UIImage?
        let url_str: String!
        let type: CellType!
        init(title: String? = nil, image: UIImage, type: CellType, url_str: String) {
            self.title = title
            self.image = image
            self.type = type
            self.url_str = url_str
        }
    }
    
    var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<SettingSection, AnyHashable>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        // navigationItemの設定をする
        configureNavItem()
        // collectionViewの設定をする
        configureCollectionView()
        configBannerView()
        // cellの構造の設定をする
        configureDataSource()
        // データを作る
        applyInitialSnapshots()
        
        configAutoLayout()
        
    }
    
    private func configAutoLayout() {
        collectionView.widthAnchor.constraint(
            equalTo: view.widthAnchor
        ).isActive = true
        collectionView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor
        ).isActive = true
        collectionView.bottomAnchor.constraint(
            equalTo: bannerView.topAnchor
        ).isActive = true
        bannerView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        bannerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        ).isActive = true
    }
    
    private func configBannerView() {
        bannerView = GADBannerView()
        bannerView.adUnitID = GoogleAdUnitID_Banner
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        bannerView.rootViewController = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    private func configureNavItem() {
        navigationItem.title = "その他"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "お問い合わせ", style: .plain, target: self, action: #selector(addBarButtonTapped(_:)))
    }
    
    @objc func addBarButtonTapped(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdG97LVQrPmRKL7Sr1HbyRFHbOqs0rTsT4JTA2zPFl-HyXFDg/viewform?usp=sf_link")
        let safariVC = SFSafariViewController(url: url!)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = SettingSection(rawValue: sectionIndex) else { return nil }
            var section: NSCollectionLayoutSection! = nil
            
            if sectionKind == .user {
                /*
                let w = self.view.frame.size.width - 32
                let h = w / 4.4
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: -16)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w + 32), heightDimension: .absolute(h))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                //section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
                */
                let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            } else if sectionKind == .app {
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.headerMode = .firstItemInSection
                /*
                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
                    guard let self = self else { return nil }
                    guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                    return self.leadingSwipeActionConfigurationForListCellItem(item)
                }*/
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    func accessoriesForListCellItem(_ item: Item) -> [UICellAccessory] {
        let accessories = [UICellAccessory.disclosureIndicator()]
        return accessories
    }
    func leadingSwipeActionConfigurationForListCellItem(_ item: Item) -> UISwipeActionsConfiguration? {
        let starAction = UIContextualAction(style: .normal, title: nil) {_, _, _ in
            print("")
        }
        return UISwipeActionsConfiguration(actions: [starAction])
    }
    
    private func configureDataSource() {
        let userSettingCellRegistration = createAppSettingCellRegistration()
        let appSettingCellRegistration = createAppSettingCellRegistration()
        let headerCellRegistration = createOutlineHeaderCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<SettingSection, AnyHashable>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            let item_1 = item as! Item
            guard let section = SettingSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .user:
                return collectionView.dequeueConfiguredReusableCell(using: userSettingCellRegistration, for: indexPath, item: item_1)
            case .app:
                if item_1.type == .header {
                    return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item_1)
                }
                return collectionView.dequeueConfiguredReusableCell(using: appSettingCellRegistration, for: indexPath, item: item_1)
            }
        })
        
    }
    
    private func createUserSettingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewCell, Item>.init { cell, _, itemIdentifier in
            var content = UIListContentConfiguration.cell()
            content.text = itemIdentifier.title
            content.textProperties.font = .boldSystemFont(ofSize: 38)
            content.textProperties.alignment = .center
            content.directionalLayoutMargins = .zero
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            cell.backgroundConfiguration = background
        }
    }
    
    private func createAppSettingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>.init { [weak self] (cell, _, itemIdentifier) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.cell()
            content.text = itemIdentifier.title
            content.image = itemIdentifier.image
            cell.contentConfiguration = content
            cell.accessories = self.accessoriesForListCellItem(itemIdentifier)
    
        }
    }
    private func createOutlineHeaderCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            // cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    func applyInitialSnapshots() {
        let sections = SettingSection.allCases
        var snapshot = NSDiffableDataSourceSnapshot<SettingSection, AnyHashable>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        let usePolicy = Item(title: "利用規約", image: UIImage(), type: .cell, url_str: "https://corporateanalysishubapp.firebaseapp.com/%E5%88%A9%E7%94%A8%E8%A6%8F%E7%B4%84.html")
        let privacyPolicy = Item(title: "プライバシーポリシー", image: UIImage(), type: .cell, url_str: "https://corporateanalysishubapp.firebaseapp.com/%E3%83%97%E3%83%A9%E3%82%A4%E3%83%90%E3%82%B7%E3%83%BC%E3%83%9D%E3%83%AA%E3%82%B7%E3%83%BC.html")
        let aboutApp = Item(title: "当アプリについて", image: UIImage(), type: .cell, url_str: "https://corporateanalysishubapp.firebaseapp.com/%E5%BD%93%E3%82%A2%E3%83%97%E3%83%AA%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6.html")
        let items = [usePolicy, privacyPolicy, aboutApp]
        var recentsSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        recentsSnapshot.append(items)
        dataSource.apply(recentsSnapshot, to: .user, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.dataSource.itemIdentifier(for: indexPath) as! Item
        
        let url = URL(string: item.url_str)
        let safariVC = SFSafariViewController(url: url!)
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true, completion: nil)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SettingViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if let errorView = bannerView.subviews.first(where: { view in
            view is NotLoadAdView
        }) {
            errorView.removeFromSuperview()
        }
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        guard bannerView.subviews.contains(where: { view in
            view is NotLoadAdView
        }) else {
            let errorView = NotLoadAdView(frame: bannerView.bounds)
            bannerView.addSubview(errorView)
            return
        }
    }
}

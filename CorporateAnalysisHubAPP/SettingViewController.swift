//
//  SettingViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/02/27.
//

import UIKit
import SwiftUI



class SettingViewController: UIViewController,UICollectionViewDelegate{
    private enum SettingSection:Int, Hashable, CaseIterable, CustomStringConvertible{
        case user
        case app
        
        var description: String {
            switch self {
            case .user: return "user"
            case .app: return "app"
            }
        }

    }

    struct Item: Hashable {
        private let identifier = UUID()
        let title: String?
        init(title:String? = nil){
            self.title = title
        }
    }
    
    var collectionView: UICollectionView!
    /*
    = { () -> UICollectionView in
        //let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        
        return collectionView
    }()*/
    
    
    private var dataSource: UICollectionViewDiffableDataSource<SettingSection, Item>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItemの設定をする
        configureNavItem()
        //collectionViewの設定をする
        configureCollectionView()
        //cellの構造の設定をする
        configureDataSource()
        //データを作る
        applyInitialSnapshots()
        
    }
    
    private func configureNavItem() {
        navigationItem.title = "設定"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: configureCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout{
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = SettingSection(rawValue: sectionIndex) else { return nil }
            var section: NSCollectionLayoutSection! = nil
            
            if sectionKind == .user {
                let w = self.view.frame.size.width - 32
                let h = w / 3.303
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(w), heightDimension: .absolute(h))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: -16)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(w + 32), heightDimension: .absolute(h))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                //section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                //section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
            }else if sectionKind == .app{
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
                    guard let self = self else { return nil }
                    guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                    return self.leadingSwipeActionConfigurationForListCellItem(item)
                }
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    func accessoriesForListCellItem(_ item: Item) -> [UICellAccessory] {
        var accessories = [UICellAccessory.disclosureIndicator()]
        
        return accessories
    }
    func leadingSwipeActionConfigurationForListCellItem(_ item: Item) -> UISwipeActionsConfiguration? {
        let starAction = UIContextualAction(style: .normal, title: nil) {_,_,_ in
            print("")
        }
        return UISwipeActionsConfiguration(actions: [starAction])
    }
    
    private func configureDataSource(){
        let userSettingCellRegistration = createUserSettingCellRegistration()
        let appSettingCellRegistration = createAppSettingCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<SettingSection, Item>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = SettingSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .user:
                return collectionView.dequeueConfiguredReusableCell(using: userSettingCellRegistration, for: indexPath, item: item)
            case .app: 
                return collectionView.dequeueConfiguredReusableCell(using: appSettingCellRegistration, for: indexPath, item: item)
            }
        })
        
    }
    
    private func createUserSettingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, Item>{
        return UICollectionView.CellRegistration<UICollectionViewCell, Item>.init { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.cell()
            content.text = itemIdentifier.title
            content.textProperties.font = .boldSystemFont(ofSize: 38)
            content.textProperties.alignment = .center
            content.directionalLayoutMargins = .zero
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listPlainCell()
            background.cornerRadius = 8
            background.strokeColor = .systemGray3
            background.strokeWidth = 1.0 / cell.traitCollection.displayScale
            cell.backgroundConfiguration = background
        }
    }
    
    private func createAppSettingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>.init { [weak self] (cell,indexPath,ItemIdentifier) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.valueCell()
            content.text = ItemIdentifier.title
            cell.contentConfiguration = content
            cell.accessories = self.accessoriesForListCellItem(ItemIdentifier)
        }
    }
    
    func applyInitialSnapshots() {
        let sections = SettingSection.allCases
        var snapshot = NSDiffableDataSourceSnapshot<SettingSection, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        
        let item = Item(title: "TEST")
        let recentItems = [item]
        var recentsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        recentsSnapshot.append(recentItems)
        dataSource.apply(recentsSnapshot, to: .user, animatingDifferences: false)
        
        let item_2 = Item(title: "TEST_2")
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let recentItems_2 = [item_2,Item(title: "TEST_3")]
        allSnapshot.append(recentItems_2)
        dataSource.apply(allSnapshot, to: .app, animatingDifferences: false)
    }
}

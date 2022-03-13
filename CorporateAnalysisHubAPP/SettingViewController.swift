//
//  SettingViewController.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/02/27.
//

import UIKit
import SwiftUI
import WebKit



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
    
    struct User: Hashable {
        private let indentifier = UUID()
        let id: String?
        let name: String?
        init(id:String,name:String){
            self.id = id
            self.name = name
        }
    }

    struct Item: Hashable {
        private let identifier = UUID()
        let title: String?
        let image:UIImage = UIImage(systemName: "person.crop.circle")!
        let type:CellType!
        init(title:String? = nil,type:CellType){
            self.title = title
            self.type = type
        }
        enum CellType{
            case cell
            case header
            case footer
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
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
            }else if sectionKind == .app{
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
        let userSettingCellRegistration = createAppSettingCellRegistration()
        let appSettingCellRegistration = createAppSettingCellRegistration()
        let headerCellRegistration = createOutlineHeaderCellRegistration()
        dataSource = UICollectionViewDiffableDataSource<SettingSection, Item>.init(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let section = SettingSection(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .user:
                return collectionView.dequeueConfiguredReusableCell(using: userSettingCellRegistration, for: indexPath, item: item)
            case .app:
                if item.type == .header{
                    return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
                }
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
            cell.backgroundConfiguration = background
        }
    }
    
    private func createAppSettingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item>.init { [weak self] (cell,indexPath,itemIdentifier) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.title
            content.image = itemIdentifier.image
            var background = UIBackgroundConfiguration.listPlainCell()
            cell.contentConfiguration = content
            cell.accessories = self.accessoriesForListCellItem(itemIdentifier)
            cell.backgroundConfiguration = background
    
        }
    }
    private func createOutlineHeaderCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            //cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }
    }
    
    func applyInitialSnapshots() {
        let sections = SettingSection.allCases
        var snapshot = NSDiffableDataSourceSnapshot<SettingSection, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        
        let item = Item(title: "アカウント",type:.cell)
        let recentItems = [item]
        var recentsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        recentsSnapshot.append(recentItems)
        dataSource.apply(recentsSnapshot, to: .user, animatingDifferences: false)
        
        let header = Item(title: "ヘッダー", type: .header)
        let item_2 = Item(title: "設定_1",type:.cell)
        var allSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let recentItems_2 = [header,item_2,Item(title: "設定_2",type:.cell)]
        allSnapshot.append(recentItems_2)
        //dataSource.apply(allSnapshot, to: .app, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
    }
}

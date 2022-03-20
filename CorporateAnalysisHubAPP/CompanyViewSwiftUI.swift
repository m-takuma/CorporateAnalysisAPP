//
//  CompanyViewSwiftUI.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2022/03/17.
//

import SwiftUI
import UIKit
import RealmSwift
import Combine


struct ContentView:View{
    @ObservedRealmObject var model:CategoryRealm
    var body :some View{
        ZStack{
            List{
                ForEach(model.list,id: \.jcn){ company in
                    HStack{
                        VStack(alignment: .leading){
                            Text("\(company.simpleCompanyName!)")
                                .font(.headline)
                                .scaledToFit()
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            Text(company.secCode!)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.system(size: 13, weight: .semibold, design: .default))
                            .frame(alignment: .trailing)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
                .onDelete(perform: $model.list.remove(atOffsets:))
            }
            if model.list.count == 0{
                Text("登録されていません")
                    .padding()
                    .font(Font(UIFont.systemFont(ofSize: 44, weight: .bold)))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .frame(alignment: .center)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView(model: .init())
    }
}

class TestViewController:UIViewController{
    
    @ObservedResults(CategoryRealm.self, filter: NSPredicate(format: "id == 'History'")) var model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationItem()
        self.view.backgroundColor = .systemGroupedBackground
        guard model.count != 0 else{
            return configWhenNoneFav()
        }
        let fav = model.first
        guard let fav = fav else{
            return configWhenNoneFav()
        }
        configFavView(fav: fav)
        
    }
    
    private func configWhenNoneFav(){
        let label = UILabel()
        label.text = "予期しないエラーが発生しました"
        label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        label.textColor = .tertiaryLabel
        label.frame.size = CGSize(width: self.view.frame.width / 3, height: 44)
        label.center = self.view.center
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        self.view.addSubview(label)
    }
    private func configFavView(fav:CategoryRealm){
        let listView = ContentView(model: fav)
        let vc:UIHostingController = UIHostingController(rootView: listView)
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        NSLayoutConstraint.activate([
            vc.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            vc.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            vc.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vc.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configNavigationItem(){
        navigationItem.title = "お気に入り"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
}

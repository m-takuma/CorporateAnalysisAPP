//
//  CompanyViewSwiftUI.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/03/17.
//

import SwiftUI
import UIKit
import RealmSwift
import Combine
import FirebaseFirestore
import GoogleMobileAds


struct ContentView:View{
    @ObservedRealmObject var model:CategoryRealm
    var present: ((_ company:CompanyRealm) -> Void)?
    @State private var selectedCompany:CompanyRealm?
    init(model:CategoryRealm){
        self.model = model
    }
    var body :some View{
        if model.list.count == 0{
            VStack{
                Spacer()
                Text("登録されていません")
                    .padding()
                    .font(Font(UIFont.systemFont(ofSize: 44, weight: .bold)))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .frame(alignment: .center)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .onAppear {self.selectedCompany = nil}
                    .onDisappear {self.selectedCompany = nil}
                Spacer()
                AdView()
                    .frame(width: 320, height: 50, alignment: .bottom)
            }
        }else{
            List{
                Section(header:Spacer()
                            .listRowInsets(.init(top:0,leading:0,bottom:0,trailing:0))){
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
                                .font(Font.system(size: 13, weight: .semibold, design:.default))
                                .frame(alignment: .trailing)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .contentShape(Rectangle())
                        .listRowBackground(selectedCompany == company ?    Color(UIColor.systemFill):nil)
                        .onTapGesture {
                            selectedCompany = company
                            self.present?(company)
                        }
                    }
                    .onDelete(perform: $model.list.remove(atOffsets:))
                }
                AdView()
                    .frame(width: 320, height: 50, alignment: .center)
            }
            .onAppear {self.selectedCompany = nil}
            .onDisappear {self.selectedCompany = nil}
        }
    }
}

struct AdView:View{
    var body: some View{
        HStack{
            Spacer()
            admobBannerView().frame(width: 320, height: 50, alignment: .bottom)
            Spacer()
        }
    }
}


struct admobBannerView:UIViewRepresentable{
    
    func makeUIView(context:Context) -> GADBannerView{
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = GoogleAdUnitID_Banner_Release
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }
    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}


struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView(model:.init())
    }
}
class viewModel{
    @ObservedResults(CategoryRealm.self, filter: NSPredicate(format: "id == 'FAV'")) var fav
}

class FavViewController:UIViewController{
    var model = viewModel()
    
    
    lazy var indicator = {() -> UIActivityIndicatorView in
        let indicator = UIActivityIndicatorView()
        indicator.center = self.view.center
        indicator.style = UIActivityIndicatorView.Style.large
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationItem()
        self.view.backgroundColor = .systemGroupedBackground
        guard model.fav.count != 0 else{
            return configWhenNoneFav()
        }
        let fav = model.fav.first
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
        vc.rootView.present = {(_ company:CompanyRealm) -> Void in
            vc.view.addSubview(self.indicator)
            self.indicator.frame = self.view.bounds
            self.indicator.startAnimating()
            let db = Firestore.firestore()
            db.collection("COMPANY_v2").document(company.jcn!).getDocument{ doc, err in
                if err != nil {
                    self.indicator.stopAnimating()
                    self.indicator.removeFromSuperview()
                    let aleart = UIAlertController(title: "エラーが発生しました", message: "お手数ですが、通信状況を確認してもう一度行ってください", preferredStyle: .alert)
                    aleart.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    self.present(aleart, animated: true, completion: nil)
                }else{
                    Task{
                        do{
                            let core = CompanyCoreDataClass(companyCoreDataDic: doc!.data()!)
                            let company = try await FireStoreFetchDataClass().makeCompany_v2(for: core)
                            let companyRootVC = CompanyRootViewController()
                            companyRootVC.company = company
                            self.indicator.stopAnimating()
                            self.indicator.removeFromSuperview()
                            self.navigationController?.pushViewController(companyRootVC, animated: true)
                        }catch{
                            self.indicator.stopAnimating()
                            self.indicator.removeFromSuperview()
                            let aleart = UIAlertController(title: "エラーが発生しました", message: "お手数ですが、通信状況を確認してもう一度行ってください", preferredStyle: .alert)
                            aleart.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                            self.present(aleart, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
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

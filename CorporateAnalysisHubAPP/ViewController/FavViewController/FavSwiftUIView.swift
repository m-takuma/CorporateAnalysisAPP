//
//  SwiftUIView.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Taku on 2022/09/18.
//

import GoogleMobileAds
import SwiftUI
import RealmSwift

struct FavSwiftUIView:View{
    @ObservedRealmObject var model:CategoryRealm
    var present: ((_ company:CompanyRealm) -> Void)?
    @State private var selectedCompany:CompanyRealm?
    @State private var height: CGFloat = 0
    @State private var width: CGFloat = 0
    init(model:CategoryRealm){
        self.model = model
    }
    var body :some View{
        if model.list.count == 0{
            NotExistCompanyView(selectedCompany: $selectedCompany)
        }else{
            ExistCompanyView(
                model: model,
                selectedCompany: $selectedCompany,
                height: $height,
                width: $width,
                present: present)
        }
    }
    
    struct NotExistCompanyView: View {
        @Binding var selectedCompany: CompanyRealm?
        var body: some View {
            ZStack{
                Color(uiColor: UIColor.systemGroupedBackground)
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
                        .onAppear {selectedCompany = nil}
                        .onDisappear {selectedCompany = nil}
                    Spacer()
                }
            }
        }
    }
    
    struct ExistCompanyView: View {
        @ObservedRealmObject var model: CategoryRealm
        @Binding var selectedCompany: CompanyRealm?
        @Binding var height: CGFloat
        @Binding var width: CGFloat
        var present: ((_ company:CompanyRealm) -> Void)?
        var body: some View {
            VStack(spacing: 0){
                FavCompanyListView(model: model, selectedCompany: $selectedCompany, present: present)
                    .onAppear {self.selectedCompany = nil}
                    .onDisappear {self.selectedCompany = nil}
                ZStack{
                    Color(uiColor: UIColor.systemGroupedBackground)
                    VStack{
                        //Spacer()
                        BannerAd()
                            .frame(width: width, height: height, alignment: .center)
                            .onAppear{
                                setFrame()
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                                setFrame()
                            }
                    }
                }
                .frame(height: height ,alignment: .bottom)
            }
        }
        func setFrame() {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let safeAreaInsets = windowScene?.windows.first(where:{ $0.isKeyWindow })?.safeAreaInsets ?? .zero
            let frame = UIScreen.main.bounds.inset(by: safeAreaInsets)
            //Use the frame to determine the size of the ad
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.width)
            //Set the ads frame
            self.width = adSize.size.width
            self.height = adSize.size.height
        }
    }
    
    struct FavCompanyListView: View {
        @ObservedRealmObject var model: CategoryRealm
        @Binding var selectedCompany: CompanyRealm?
        var present: ((_ company:CompanyRealm) -> Void)?
        var body: some View {
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
            }
        }
    }
}

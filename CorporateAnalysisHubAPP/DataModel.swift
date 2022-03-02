//
//  DataModel.swift
//  CorporateAnalysisHubAPP
//
//  Created by 松尾卓磨 on 2021/12/25.
//

import Foundation
import Firebase
import FirebaseFirestore
class CompanyDataClass{
    var coreData:CompanyCoreDataClass!
    var finDataDict:Dictionary<String,CompanyFinData>!
    init(coreData:CompanyCoreDataClass){
        self.coreData = coreData
    }
    
    /// - parameter type:typeが0の場合昇順。それ以外は降順。
    func finDataSort(type:Int) -> Array<String>{
        var tmp:[String:Date] = [:]
        for key in self.finDataDict.keys{
            tmp[key] = self.finDataDict[key]?.CurrentPeriodEndDate.dateValue()
        }
        if type == 0{
            let sortDataKey = tmp.sorted {$0.value < $1.value}.map{$0.key}
            return sortDataKey
        }else{
            let sortDataKey = tmp.sorted {$0.value > $1.value}.map{$0.key}
            return sortDataKey
        }
    }
    
}

class CompanyCoreDataClass{
    var CorporateENGName:String!
    var CorporateJPNName:String!
    var EDINETCode:String!
    var JCN:String!
    var SecCode:String!
    var lastModified:Timestamp!
    init(companyCoreDataDic:Dictionary<String,Any>){
        self.CorporateENGName = (companyCoreDataDic["CorporateENGName"] as! String)
        self.CorporateJPNName = (companyCoreDataDic["CorporateJPNName"] as! String)
        self.EDINETCode = (companyCoreDataDic["EDINETCode"] as! String)
        self.JCN = (companyCoreDataDic["JCN"] as! String)
        self.SecCode = (companyCoreDataDic["SecCode"] as! String)
        self.lastModified = (companyCoreDataDic["lastModified"] as! Timestamp)
    }
}

class CompanyFinData{
    
    var AccountingStandard:String!
    var FiscalYear:String!
    var TypeOfCurrentPeriod:String!
    var CurrentFiscalYearStartDate:Timestamp!
    var CurrentFiscalYearEndDate:Timestamp!
    var CurrentPeriodEndDate:Timestamp!
    var IndustryCodeDEI:String!
    var WhetherConsolidated:String!
    var formCode:String!
    var ordinanceCode:String!
    
    var bs:CompanyBSCoreData!
    var pl:CompanyPLCoreData!
    var cf:CompanyCFCoreData!
    var other:CompanyOhterData!
    var finIndex:CompanyFinIndexData!
    
    init(companyFinData:Dictionary<String,Any>){
        
        AccountingStandard = (companyFinData["AccountingStandard"] as! String)
        FiscalYear = (companyFinData["FiscalYear"] as! String)
        TypeOfCurrentPeriod = (companyFinData["TypeOfCurrentPeriod"] as! String)
        CurrentFiscalYearStartDate = (companyFinData["CurrentFiscalYearStartDate"] as! Timestamp)
        CurrentFiscalYearEndDate = (companyFinData["CurrentFiscalYearEndDate"] as! Timestamp)
        CurrentPeriodEndDate = (companyFinData["CurrentPeriodEndDate"] as! Timestamp)
        IndustryCodeDEI = (companyFinData["IndustryCodeDEI"] as! String)
        WhetherConsolidated = (companyFinData["WhetherConsolidated"] as! String)
        formCode = (companyFinData["formCode"] as! String)
        ordinanceCode = (companyFinData["ordinanceCode"] as! String)
    }
    
    
}

class CompanyBSCoreData{
    var Assets:Int?//共通
    var CurrentAssets:Int?//共通
    var NoncurrentAssets:Int?//科目名が異なる
    var DeferredAssets:Int?//JPNのみ
    var Liabilities:Int?//共通
    var CurrentLiabilities:Int?//共通
    var NoncurrentLiabilities:Int?//科目名が異なる
    var NetAssets:Int?//科目名が異なる
    var EquityAssets:Int?//株主持分
    var NonControllingInterests:Int?//共通
    var SubscriptionRightsToShares:Int?//JPNのみ
    
    init(bs:Dictionary<String,Any>,accountStandard:String){
        
        if accountStandard == "Japan GAAP"{
            Assets = bs["Assets"] as? Int
            CurrentAssets = bs["CurrentAssets"] as? Int
            NoncurrentAssets = bs["NoncurrentAssets"] as? Int
            DeferredAssets = bs["DeferredAssets"] as? Int
            Liabilities = bs["Liabilities"] as? Int
            CurrentLiabilities = bs["CurrentLiabilities"] as? Int
            NoncurrentLiabilities = bs["NoncurrentLiabilities"] as? Int
            NetAssets = bs["NetAssets"] as? Int
            NonControllingInterests = bs["NonControllingInterests"] as? Int
            SubscriptionRightsToShares = bs["SubscriptionRightsToShares"] as? Int
        }else if accountStandard == "IFRS"{
            Assets = bs["AssetsIFRS"] as? Int
            CurrentAssets = bs["CurrentAssetsIFRS"] as? Int
            NoncurrentAssets = bs["NonCurrentAssetsIFRS"] as? Int
            Liabilities = bs["LiabilitiesIFRS"] as? Int
            CurrentLiabilities = bs["TotalCurrentLiabilitiesIFRS"] as? Int
            NoncurrentLiabilities = bs["NonCurrentLiabilitiesIFRS"] as? Int
            NetAssets = bs["EquityIFRS"] as? Int
            NonControllingInterests = bs["NonControllingInterestsIFRS"] as? Int
        }else if accountStandard == "US GAAP"{
            Assets = bs["TotalAssetsUSGAAPSummaryOfBusinessResults"] as? Int
            NetAssets = bs["EquityIncludingPortionAttributableToNonControllingInterestUSGAAPSummaryOfBusinessResults"] as? Int
            EquityAssets = bs["EquityAttributableToOwnersOfParentUSGAAPSummaryOfBusinessResults"] as? Int
        }
        
    }
    
}

class CompanyPLCoreData{
    var OperatingRevenue1:Int?//売上高、営業収益、銀行経常収益など{共通
    var OperatingIncome:Int?//営業利益{共通
    var OrdinaryIncome:Int?//経常利益{JPNのみ
    var IncomeBeforeIncomeTaxes:Int?//税引前当期純利益{共通
    var ProfitLossAttributableToOwnersOfParent:Int?//親会社当期純利益{共通
    
    init(pl:Dictionary<String,Any>,accountingStandard:String){
        if accountingStandard == "Japan GAAP"{
            if let operatingRev = pl["NetSales"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["OperatingRevenue1"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["OrdinaryIncomeBNK"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["OperatingRevenueSEC"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["OperatingIncomeINS"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else{
                OperatingRevenue1 = nil
            }
            OperatingIncome = pl["OperatingIncome"] as? Int
            OrdinaryIncome = pl["OrdinaryIncome"] as? Int
            IncomeBeforeIncomeTaxes = pl["IncomeBeforeIncomeTaxes"] as? Int
            ProfitLossAttributableToOwnersOfParent = pl["ProfitLossAttributableToOwnersOfParent"] as? Int
        }else if accountingStandard == "IFRS"{
            if let operatingRev = pl["RevenueIFRS"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["NetSalesIFRS"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else if let operatingRev = pl["Revenue2IFRS"]{
                OperatingRevenue1 = (operatingRev as? Int)
            }else{
                OperatingRevenue1 = nil
            }
            OperatingIncome = pl["OperatingProfitLossIFRS"] as? Int
            OrdinaryIncome = nil
            IncomeBeforeIncomeTaxes = pl["ProfitLossBeforeTaxIFRS"] as? Int
            ProfitLossAttributableToOwnersOfParent = pl["ProfitLossAttributableToOwnersOfParentIFRS"] as? Int
        }else if accountingStandard == "US GAAP"{
            OperatingRevenue1 = pl["RevenuesUSGAAPSummaryOfBusinessResults"] as? Int
            OperatingIncome = pl["OperatingIncomeLossUSGAAPSummaryOfBusinessResults"] as? Int
            IncomeBeforeIncomeTaxes = pl["ProfitLossBeforeTaxUSGAAPSummaryOfBusinessResults"] as? Int
            ProfitLossAttributableToOwnersOfParent = pl["NetIncomeLossAttributableToOwnersOfParentUSGAAPSummaryOfBusinessResults"]as? Int
            
        }
    }
    
}

class CompanyCFCoreData{
    var NetCashProvidedByUsedInOperatingActivities:Int?
    var NetCashProvidedByUsedInInvestmentActivities:Int?
    var NetCashProvidedByUsedInFinancingActivities:Int?
    var NetIncreaseDecreaseInCashAndCashEquivalents:Int?
    var CashAndCashEquivalents:Int?
    
    init(cf:Dictionary<String,Any>,accountStandard:String){
        if accountStandard == "Japan GAAP"{
            NetCashProvidedByUsedInOperatingActivities = cf["NetCashProvidedByUsedInOperatingActivities"] as? Int
            NetCashProvidedByUsedInInvestmentActivities = cf["NetCashProvidedByUsedInInvestmentActivities"] as? Int
            NetCashProvidedByUsedInFinancingActivities = cf["NetCashProvidedByUsedInFinancingActivities"] as? Int
            NetIncreaseDecreaseInCashAndCashEquivalents = cf["NetIncreaseDecreaseInCashAndCashEquivalents"] as?
            Int
            CashAndCashEquivalents = cf["CashAndCashEquivalents"] as? Int
        }else if accountStandard == "IFRS"{
            NetCashProvidedByUsedInOperatingActivities = cf["NetCashProvidedByUsedInOperatingActivitiesIFRS"] as? Int
            NetCashProvidedByUsedInInvestmentActivities = cf["NetCashProvidedByUsedInInvestingActivitiesIFRS"] as? Int
            NetCashProvidedByUsedInFinancingActivities = cf["NetCashProvidedByUsedInFinancingActivitiesIFRS"] as? Int
            NetIncreaseDecreaseInCashAndCashEquivalents = cf["NetIncreaseDecreaseInCashAndCashEquivalentsIFRS"] as? Int
            CashAndCashEquivalents = cf["CashAndCashEquivalentsIFRS"] as? Int
        }else if accountStandard == "US GAAP"{
            NetCashProvidedByUsedInOperatingActivities = cf["CashFlowsFromUsedInOperatingActivitiesUSGAAPSummaryOfBusinessResults"] as? Int
            NetCashProvidedByUsedInInvestmentActivities = cf["CashFlowsFromUsedInInvestingActivitiesUSGAAPSummaryOfBusinessResults"] as? Int
            NetCashProvidedByUsedInFinancingActivities = cf["CashFlowsFromUsedInFinancingActivitiesUSGAAPSummaryOfBusinessResults"] as? Int
            CashAndCashEquivalents = cf["CashAndCashEquivalentsUSGAAPSummaryOfBusinessResults"] as? Int
            
        }
    }
}

class CompanyOhterData{
    var NumberOfIssuedSharesAsOfFiscalYearEndIssuedSharesTotalNumberOfSharesEtc:Int?
    var TotalNumberOfSharesHeldTreasurySharesEtc:Int?
    
    init(other:Dictionary<String,Any>){
        NumberOfIssuedSharesAsOfFiscalYearEndIssuedSharesTotalNumberOfSharesEtc = other["NumberOfIssuedSharesAsOfFiscalYearEndIssuedSharesTotalNumberOfSharesEtc"] as? Int
        TotalNumberOfSharesHeldTreasurySharesEtc = other["TotalNumberOfSharesHeldTreasurySharesEtc"] as? Int
    }
}

class CompanyFinIndexData{
    var capitalAdequacyRatio:Double?
    var currentRatio:Double?
    var fixedRatio:Double?
    var fixedAssetsToLongtermCapitalRatio:Double?
    var operatigMarginRatio:Double?
    var netProfitMarginRatio:Double?
    var netsalesOperatingCFRadio:Double?
    var capitalOperatingCFRadio:Double?
    var currentRate_CF:Double?
    var ROA:Double?
    var ROE:Double?
    
    init(indexData:Dictionary<String,Any>){
        capitalAdequacyRatio = indexData["ECR"] as? Double
        currentRatio = indexData["CR"] as? Double
        fixedRatio = indexData["FAR"] as? Double
        fixedAssetsToLongtermCapitalRatio = indexData["FAR2"] as? Double
        operatigMarginRatio = indexData["OMR"] as? Double
        netProfitMarginRatio = indexData["NPMR"] as? Double
        netsalesOperatingCFRadio = indexData["売上営業CF比率"] as? Double
        capitalOperatingCFRadio = indexData["自己資本営業CF比率"] as? Double
        currentRate_CF = indexData["CFATR"] as? Double
        ROA = indexData["ROA"] as? Double
        ROE = indexData["ROE"] as? Double
        
    }
}

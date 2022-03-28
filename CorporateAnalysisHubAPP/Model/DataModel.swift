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
    var finDataDict:Dictionary<String,DocData>!
    init(coreData:CompanyCoreDataClass){
        self.coreData = coreData
        self.finDataDict = [:]
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
    var JCN:String!
    var companyNameInJP:String!
    var companyNameInENG:String!
    var EDINETCode:String!
    var secCode:String!
    var lastModified:Timestamp!
    var simpleCompanyNameInJP:String!
    init(companyCoreDataDic dict:Dictionary<String,Any>){
        self.JCN = dict["JCN"] as? String
        self.companyNameInJP = dict["companyNameInJP"] as? String
        self.companyNameInENG = dict["companyNameInENG"] as? String
        self.EDINETCode = dict["EDINETCode"] as? String
        self.secCode = dict["secCode"] as? String
        self.lastModified = dict["lastModified"] as? Timestamp
        self.simpleCompanyNameInJP = dict["simpleCompanyNameInJP"] as? String
    }
}

class DocData{
    var primaryDocID:String!
    
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
    
    init(docID:String,companyFinData dict:Dictionary<String,Any>){
        primaryDocID = docID
        
        AccountingStandard = dict["accountingStandard"] as? String
        FiscalYear = dict["fiscalYear"] as? String
        TypeOfCurrentPeriod = dict["typeOfCurrentPeriod"] as? String
        CurrentFiscalYearStartDate = dict["currentFiscalYearStartDate"] as? Timestamp
        CurrentFiscalYearEndDate = dict["currentFiscalYearEndDate"] as? Timestamp
        CurrentPeriodEndDate = dict["currentPeriodEndDate"] as? Timestamp
        IndustryCodeDEI = dict["industryCodeDEI"] as? String
        WhetherConsolidated = dict["whetherConsolidated"] as? String
        formCode = dict["formCode"] as? String
        ordinanceCode = dict["ordinanceCode"] as? String
    }
    
    
}

class CompanyBSCoreData{
    var assets:Int?//共通
    var currentAssets:Int?//共通
    var notesAndAccountsReceivableTrade:Int?//売上債権
    var inventories:Int?//棚卸資産
    var noncurrentAssets:Int?//科目名が異なる
    var propertyPlantAndEquipment:Int?//有形固定資産
    var deferredAssets:Int?//JPNのみ
    var goodwill:Int?//のれん
    var liabilities:Int?//共通
    var currentLiabilities:Int?//共通
    var notesAndAccountsPayableTrade:Int?//仕入債務
    var noncurrentLiabilities:Int?//科目名が異なる
    var netAssets:Int?//科目名が異なる
    var shareholdersEquity:Int?//株主持分
    var retainedEarnings:Int?//利益剰余金
    var treasuryStock:Int?//自己株式
    var valuationAndTranslationAdjustments:Int?//その他包括利益累計額
    var nonControllingInterests:Int?//共通
    var subscriptionRightsToShares:Int?//JPNのみ
    var BPS:Double?
    
    init(bs:Dictionary<String,Any>){
        assets = bs["assets"] as? Int
        currentAssets = bs["currentAssets"] as? Int
        notesAndAccountsReceivableTrade = bs["notesAndAccountsReceivableTrade"] as? Int
        inventories = bs["inventories"] as? Int
        noncurrentAssets = bs["noncurrentAssets"] as? Int
        propertyPlantAndEquipment = bs["propertyPlantAndEquipment"] as? Int
        deferredAssets = bs["deferredAssets"] as? Int
        goodwill = bs["goodwill"] as? Int
        liabilities = bs["liabilities"] as? Int
        currentLiabilities = bs["currentLiabilities"] as? Int
        notesAndAccountsPayableTrade = bs["notesAndAccountsPayableTrade"] as? Int
        noncurrentLiabilities = bs["noncurrentLiabilities"] as? Int
        netAssets = bs["netAssets"] as? Int
        shareholdersEquity = bs["shareholdersEquity"] as? Int
        retainedEarnings = bs["retainedEarnings"] as? Int
        treasuryStock = bs["treasuryStock"] as? Int
        valuationAndTranslationAdjustments = bs["valuationAndTranslationAdjustments"] as? Int
        nonControllingInterests = bs["nonControllingInterests"] as? Int
        subscriptionRightsToShares = bs["subscriptionRightsToShares"] as? Int
        BPS = bs["BPS"] as? Double
    }
}

class CompanyPLCoreData{
    var netSales:Int?
    var revenue:Int?
    var operatingRevenue:Int?
    var grossProfit:Int?
    var sellingGeneralAndAdministrativeExpenses:Int?
    var operatingIncome:Int?
    var operatingIncomeIFRS:Int?
    var ordinaryIncome:Int?
    var incomeBeforeIncomeTaxes:Int?
    var incomeTaxes:Int?
    var profitLoss:Int?
    var profitLossAttributableToOwnersOfParent:Int?
    
    var ordinaryIncomeBNK:Int?
    var operatingRevenueSEC:Int?
    var operatingIncomeINS:Int?
    
    var EPS:Double?
    
    init(pl:Dictionary<String,Any>){
        netSales = pl["netSales"] as? Int
        revenue = pl["revenue"] as? Int
        operatingRevenue = pl["operatingRevenue"] as? Int
        grossProfit = pl["grossProfit"] as? Int
        sellingGeneralAndAdministrativeExpenses = pl["sellingGeneralAndAdministrativeExpenses"] as? Int
        operatingIncome = pl["operatingIncome"] as? Int
        operatingIncomeIFRS = pl["operatingIncomeIFRS"] as? Int
        ordinaryIncome = pl["ordinaryIncome"] as? Int
        incomeBeforeIncomeTaxes = pl["incomeBeforeIncomeTaxes"] as? Int
        incomeTaxes = pl["incomeTaxes"] as? Int
        profitLoss = pl["profitLoss"] as? Int
        profitLossAttributableToOwnersOfParent = pl["profitLossAttributableToOwnersOfParent"] as? Int
        ordinaryIncomeBNK = pl["ordinaryIncomeBNK"] as? Int
        operatingRevenueSEC = pl["operatingRevenueSEC"] as? Int
        operatingIncomeINS = pl["operatingIncomeINS"] as? Int
        EPS = pl["EPS"] as? Double
    }
    
    func getNetSales_etcValue() -> (Int,NetSalesEtcType){
        var netSalesEtc:Array<(Int,NetSalesEtcType)> = []
        if ordinaryIncomeBNK != nil{
            return (ordinaryIncomeBNK!,.ordinaryIncomeBNK)
        }else if operatingRevenueSEC != nil{
            return (operatingRevenueSEC!,.operatingRevenueSEC)
        }else if operatingIncomeINS != nil{
            return (operatingIncomeINS!,.operatingIncomeINS)
        }else if netSales != nil{
            netSalesEtc.append((netSales!,.NetSales))
        }else if operatingRevenue != nil{
            netSalesEtc.append((operatingRevenue!,.OperatingRevenue))
        }else if revenue != nil{
            netSalesEtc.append((revenue!,.Revenue))
        }else{
            return (0,.none)
        }
        guard netSalesEtc.count != 1 else{
            return netSalesEtc[0]
        }
        return netSalesEtc.max(by: {$0.0 > $1.0})!
    }
    
    func getOperatingIncome() -> (Int,OperatingIncomeType){
        if operatingIncome == nil && operatingIncomeIFRS == nil{
            return (0,.none)
        }else if operatingIncome != nil && operatingIncomeIFRS != nil{
            return (operatingIncomeIFRS!,.OperatingIncomeIFRS)
        }else if operatingIncomeIFRS != nil{
            return (operatingIncomeIFRS!,.OperatingIncomeIFRS)
        }else{
            return (operatingIncome!,.OperatingIncome)
        }
    }
    enum NetSalesEtcType:String,Hashable{
        case NetSales = "売上高"
        case Revenue = "収益"
        case OperatingRevenue = "営業収益"
        case ordinaryIncomeBNK = "経常収益(銀行)"
        case operatingRevenueSEC = "営業収益(証券)"
        case operatingIncomeINS = "経常収益(保険)"
        case none = "(収益)"
    }
    enum OperatingIncomeType:String,Hashable{
        case OperatingIncome = "営業利益"
        case OperatingIncomeIFRS = "営業利益(IFRS)"
        case none = "(営業利益)"
    }
    
}

class CompanyCFCoreData{
    var netCashProvidedByUsedInOperatingActivities:Int?
    var netCashProvidedByUsedInInvestmentActivities:Int?
    var netCashProvidedByUsedInFinancingActivities:Int?
    var netIncreaseDecreaseInCashAndCashEquivalents:Int?
    var cashAndCashEquivalents:Int?
    var depreciationAndAmortizationOpeCF:Int?
    var amortizationOfGoodwillOpeCF:Int?
    
    init(cf:Dictionary<String,Any>){
        netCashProvidedByUsedInOperatingActivities = cf["netCashProvidedByUsedInOperatingActivities"] as? Int
        netCashProvidedByUsedInInvestmentActivities = cf["netCashProvidedByUsedInInvestmentActivities"] as? Int
        netCashProvidedByUsedInFinancingActivities = cf["netCashProvidedByUsedInFinancingActivities"] as? Int
        netIncreaseDecreaseInCashAndCashEquivalents = cf["netIncreaseDecreaseInCashAndCashEquivalents"] as? Int
        cashAndCashEquivalents = cf["cashAndCashEquivalents"] as? Int
        depreciationAndAmortizationOpeCF = cf["depreciationAndAmortizationOpeCF"] as? Int
        amortizationOfGoodwillOpeCF = cf["amortizationOfGoodwillOpeCF"] as? Int
    }
}

class CompanyOhterData{
    var numOfTotalShares:Int?
    var numOfTreasuryShare:Int?
    var dividendPaidPerShare:Double?
    var capitalExpendituresOverviewOfCapitalExpendituresEtc:Int?
    var researchAndDevelopmentExpensesResearchAndDevelopmentActivities:Int?
    var numberOfEmployees:Int?
    
    init(other:Dictionary<String,Any>){
        numOfTotalShares = other["numOfTotalShares"] as? Int
        numOfTreasuryShare = other["numOfTreasuryShare"] as? Int
        dividendPaidPerShare = other["dividendPaidPerShare"] as? Double
        capitalExpendituresOverviewOfCapitalExpendituresEtc = other["capitalExpendituresOverviewOfCapitalExpendituresEtc"] as? Int
        researchAndDevelopmentExpensesResearchAndDevelopmentActivities = other["researchAndDevelopmentExpensesResearchAndDevelopmentActivities"] as? Int
        numberOfEmployees = other["numberOfEmployees"] as? Int
    }
}

class CompanyFinIndexData{
    ///流動比率
    var currentRatio:Double?
    ///手元流動性比率
    var shortTermLiquidity:Double?
    ///固定比率
    var fixedAssetsToNetWorth:Double?
    ///固定長期適合率
    var fixedAssetToFixedLiabilityRatio:Double?
    ///自己資本比率
    var equityRatio:Double?
    ///DEレシオ
    var debtEquityRatio:Double?
    ///ネット有利子負債
    var netDebt:Double?
    ///ネットDEレシオ
    var netDebtEquityRation:Double?
    ///有利子負債依存度
    var dependedDebtRatio:Double?
    ///粗利率
    var grossProfitMargin:Double?
    ///営業利益率
    var operatingIncomeMargin:Double?
    ///経常利益率
    var ordinaryIncomeMargin:Double?
    ///純利益率
    var netProfitMargin:Double?
    ///親会社株主に帰属する当期純利益率
    var netProfitAttributeOfOwnerMargin:Double?
    ///EBITDA
    var EBITDA:Double?
    ///EBITDA有利子負債倍率
    var EBITDAInterestBearingDebtRatio:Double?
    ///実効税率
    var effectiveTaxRate:Double?
    ///総資産回転率
    var totalAssetsTurnover:Double?
    ///売上債権回転率
    var receivablesTurnover:Double?
    ///棚卸資産回転率
    var inventoryTurnover:Double?
    ///仕入債務回転率
    var payableTurnover:Double?
    ///有形固定資産回転率
    var tangibleFixedAssetTurnover:Double?
    ///キャッシュ・コンバージョン・サイクル
    var CCC:Double?
    ///売上営業CF比率
    var netSalesOperatingCFRatio:Double?
    ///自己資本営業CF比率
    var equityOperatingCFRatio:Double?
    ///CF版当座比率
    var operatingCFCurrentLiabilitiesRatio:Double?
    ///営業CF対有利子負債
    var operatingCFDebtRatio:Double?
    ///設備投資比率
    var fixedInvestmentOperatingCFRatio:Double?
    var ROIC:Double?
    var ROE:Double?
    var ROA:Double?
    
    
    init(indexData dict:Dictionary<String,Any>){
        currentRatio = dict["currentRatio"] as? Double
        shortTermLiquidity = dict["shortTermLiquidity"] as? Double
        fixedAssetsToNetWorth = dict["fixedAssetsToNetWorth"] as? Double
        fixedAssetToFixedLiabilityRatio = dict["fixedAssetToFixedLiabilityRatio"] as? Double
        equityRatio = dict["equityRatio"] as? Double
        debtEquityRatio = dict["debtEquityRatio"] as? Double
        netDebt = dict["netDebt"] as? Double
        netDebtEquityRation = dict["netDebtEquityRation"] as? Double
        dependedDebtRatio = dict["dependedDebtRatio"] as? Double
        grossProfitMargin = dict["grossProfitMargin"] as? Double
        operatingIncomeMargin = dict["operatingIncomeMargin"] as? Double
        ordinaryIncomeMargin = dict["ordinaryIncomeMargin"] as? Double
        netProfitMargin = dict["netProfitMargin"] as? Double
        netProfitAttributeOfOwnerMargin = dict["netProfitAttributeOfOwnerMargin"] as? Double
        EBITDA = dict["EBITDA"] as? Double
        EBITDAInterestBearingDebtRatio = dict["EBITDAInterestBearingDebtRatio"] as? Double
        effectiveTaxRate = dict["effectiveTaxRate"] as? Double
        totalAssetsTurnover = dict["totalAssetsTurnover"] as? Double
        receivablesTurnover = dict["receivablesTurnover"] as? Double
        inventoryTurnover = dict["inventoryTurnover"] as? Double
        payableTurnover = dict["payableTurnover"] as? Double
        tangibleFixedAssetTurnover = dict["tangibleFixedAssetTurnover"] as? Double
        CCC = dict["CCC"] as? Double
        netSalesOperatingCFRatio = dict["netSalesOperatingCFRatio"] as? Double
        equityOperatingCFRatio = dict["equityOperatingCFRatio"] as? Double
        operatingCFCurrentLiabilitiesRatio = dict["operatingCFCurrentLiabilitiesRatio"] as? Double
        operatingCFDebtRatio = dict["operatingCFDebtRatio"] as? Double
        fixedInvestmentOperatingCFRatio = dict["fixedInvestmentOperatingCFRatio"] as? Double
        ROIC = dict["ROIC"] as? Double
        ROE = dict["ROE"] as? Double
        ROA = dict["ROA"] as? Double
    }
    func fetchIndexData(tag:Tag) throws -> Double{
        var value:Double? = nil
        switch tag{
        case .currentRatio:
            value = self.currentRatio
        case .shortTermLiquidity:
            value = self.shortTermLiquidity
        case .fixedAssetsToNetWorth:
            value = self.fixedAssetsToNetWorth
        case .fixedAssetToFixedLiabilityRatio:
            value = self.fixedAssetToFixedLiabilityRatio
        case .equityRatio:
            value = self.equityRatio
        case .debtEquityRatio:
            value = self.debtEquityRatio
        case .netDebt:
            value = self.netDebt
        case .netDebtEquityRation:
            value = self.netDebtEquityRation
        case .dependedDebtRatio:
            value = self.dependedDebtRatio
        case .grossProfitMargin:
            value = self.grossProfitMargin
        case .operatingIncomeMargin:
            value = self.operatingIncomeMargin
        case .ordinaryIncomeMargin:
            value = self.ordinaryIncomeMargin
        case .netProfitMargin:
            value = self.netProfitMargin
        case .netProfitAttributeOfOwnerMargin:
            value = self.netProfitAttributeOfOwnerMargin
        case .EBITDA:
            value = self.EBITDA
        case .EBITDAInterestBearingDebtRatio:
            value = self.EBITDAInterestBearingDebtRatio
        case .effectiveTaxRate:
            value = self.effectiveTaxRate
        case .totalAssetsTurnover:
            value = self.totalAssetsTurnover
        case .receivablesTurnover:
            value = self.receivablesTurnover
        case .inventoryTurnover:
            value = self.inventoryTurnover
        case .payableTurnover:
            value = self.payableTurnover
        case .tangibleFixedAssetTurnover:
            value = self.tangibleFixedAssetTurnover
        case .CCC:
            value = self.CCC
        case .netSalesOperatingCFRatio:
            value = self.netSalesOperatingCFRatio
        case .equityOperatingCFRatio:
            value = self.equityOperatingCFRatio
        case .operatingCFCurrentLiabilitiesRatio:
            value = self.operatingCFCurrentLiabilitiesRatio
        case .operatingCFDebtRatio:
            value = self.operatingCFDebtRatio
        case .fixedInvestmentOperatingCFRatio:
            value = self.fixedInvestmentOperatingCFRatio
        case .ROIC:
            value = self.ROIC
        case .ROE:
            value = self.ROE
        case .ROA:
            value = self.ROA
        }
        guard let value = value else {
            throw CustomError.NoneValue
        }
        switch tag {
        case
                .netDebt,
                .EBITDA:
            return value
        case
                .totalAssetsTurnover,
                .receivablesTurnover,
                .inventoryTurnover,
                .payableTurnover,
                .tangibleFixedAssetTurnover,
                .CCC,
                .operatingCFDebtRatio:
            return round(value * 100) / 100
        default:
            return round(value * 10000) / 100
        }
    }
    
    enum Tag:String,Hashable,CaseIterable{
        case currentRatio = "流動比率"
        case shortTermLiquidity = "手元流動性比率"
        case fixedAssetsToNetWorth = "固定比率"
        case fixedAssetToFixedLiabilityRatio = "固定長期適合率"
        case equityRatio = "自己資本比率"
        case debtEquityRatio = "DEレシオ"
        case netDebt = "ネット有利子負債"
        case netDebtEquityRation = "ネットDEレシオ"
        case dependedDebtRatio = "有利子負債依存度"
        case grossProfitMargin = "粗利率"
        case operatingIncomeMargin = "営業利益率"
        case ordinaryIncomeMargin = "経常利益率"
        case netProfitMargin = "純利益率"
        case netProfitAttributeOfOwnerMargin = "(親)純利益率"
        case EBITDA = "EBITDA"
        case EBITDAInterestBearingDebtRatio = "EBITDA有利子負債倍率"
        case effectiveTaxRate = "実効税率"
        case totalAssetsTurnover = "総資産回転率"
        case receivablesTurnover = "売上債権回転率"
        case inventoryTurnover = "棚卸資産回転率"
        case payableTurnover = "仕入債務回転率"
        case tangibleFixedAssetTurnover = "有形固定資産回転率"
        case CCC = "CCC"
        case netSalesOperatingCFRatio = "売上営業CF比率"
        case equityOperatingCFRatio = "自己資本営業CF比率"
        case operatingCFCurrentLiabilitiesRatio = "CF版当座比率"
        case operatingCFDebtRatio = "営業CF対有利子負債"
        case fixedInvestmentOperatingCFRatio = "設備投資比率"
        case ROIC = "ROIC"
        case ROE = "ROE"
        case ROA = "ROA"
        
    }
    
}

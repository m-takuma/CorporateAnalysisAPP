//
//  CustomError.swift
//  CorporateAnalysisHubAPP
//
//  Created by M_Takuma on 2022/02/02.
//

import Foundation
import UIKit
import Charts

enum CustomError:Error{
    case NoneJCN
    case NoneSnapShot
    case NoneValue
}

enum userState: String{
    case appVersion = "appVersion"
    case isFirstBoot = "isFirstBoot"
}

class LeftAxisFormatter:NSObject, IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.groupingSeparator = ","
        numFormatter.groupingSize = 3
        if value > 100000{
            let roundV = round(round(value / 10) * 10)
            let result = numFormatter.string(from: NSNumber(value: roundV))
            return result!
        }
        let result = numFormatter.string(from: NSNumber(value: value))
        return result!
    }
}

class secCodeList{
    let n225:Array<Int>!
    let core30:Array<Int>!
    
    init(){
        n225 = [1332,1333,1605,1721,1801,1802,1803,1808,1812,1925,1928,1963,2002,2269,2282,2413,2432,2501,2502,2503,2531,2768,2801,2802,2871,2914,3086,3099,3101,3103,3289,3382,3401,3402,3405,3407,3436,3659,3861,3863,4004,4005,4021,4042,4043,4061,4063,4151,4183,4188,4208,4324,4452,4502,4503,4506,4507,4519,4523,4543,4568,4578,4631,4689,4704,4751,4755,4901,4902,4911,5019,5020,5101,5108,5201,5202,5214,5232,5233,5301,5332,5333,5401,5406,5411,5541,5631,5703,5706,5707,5711,5713,5714,5801,5802,5803,6098,6103,6113,6178,6301,6302,6305,6326,6361,6367,6471,6472,6473,6479,6501,6503,6504,6506,6645,6674,6701,6702,6703,6724,6752,6753,6758,6762,6770,6841,6857,6861,6902,6952,6954,6971,6976,6981,6988,7003,7004,7011,7012,7013,7186,7201,7202,7203,7205,7211,7261,7267,7269,7270,7272,7731,7733,7735,7751,7752,7762,7832,7911,7912,7951,7974,8001,8002,8015,8031,8035,8053,8058,8233,8252,8253,8267,8303,8304,8306,8308,8309,8316,8331,8354,8355,8411,8601,8604,8628,8630,8697,8725,8750,8766,8795,8801,8802,8804,8830,9001,9005,9007,9008,9009,9020,9021,9022,9064,9101,9104,9107,9147,9202,9301,9432,9433,9434,9501,9502,9503,9531,9532,9602,9613,9735,9766,9983,9984]
        core30 = [3382,4063,4452,4502,4503,4568,6098,6273,6367,6501,6594,6758,6861,6954,6981,7203,7267,7741,7974,8001,8031,8035,8058,8306,8316,8411,8766,9432,9433,9984]
    }
}

extension UIColor{
    static var originalWhite = UIColor(named: "originalWhite")!
}

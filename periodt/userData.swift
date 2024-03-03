//
//  userData.swift
//  periodt
//
//  Created by Praneeth Kukunuru on 3/3/24.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
class userData {
    var startDate: Date
    var cycleLen: Int
    var numPeriods = 0
    var PeriodLen: Int
    var firstTimeOnApp = true
    
    
    init(startDate: Date, cycleLen: Int, numPeriods: Int = 0, PeriodLen: Int) {
        self.startDate = startDate
        self.cycleLen = cycleLen
        self.numPeriods = numPeriods
        self.PeriodLen = PeriodLen
        
    }
}

@available(iOS 17, *)
func createData(date: Date)-> userData {
    let newData = userData(startDate: date, cycleLen: 28, numPeriods: 0, PeriodLen: 6)
    return newData
}





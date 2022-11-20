//
//  DigitValueFormatter.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/20.
//

import Foundation
import Charts

class DigitValueFormatter : NSObject, ValueFormatter {
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        let valueWithoutDecimalPart = String(format: "%.0f", value)
        return "\(valueWithoutDecimalPart)"
    }
}

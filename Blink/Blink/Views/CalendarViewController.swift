//
//  CalendarViewController.swift
//  Blink
//
//  Created by YOONJONG on 2022/11/20.
//

import UIKit
import FirebaseDatabase
import Charts

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    private var ref: DatabaseReference!
    
    override func viewDidLoad() {
        setTitleLabel()
        ref = Database.database().reference()
        initDateLabel()
        initChart()
        getData()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension CalendarViewController {
    private func setTitleLabel() {
        print("진입")
        guard let userName = UserDefaultsManager.shared.getUserDefaultsObject(forKey: "userName") as? String else { return }
        titleLabel.text = "\(userName)님의 기록"
        print(userName)
    }
    
    private func getData() {
        guard var userIdentifier = KeychainManager.shared.getToken(key: "loginToken") as? String else { return }
        userIdentifier = userIdentifier.components(separatedBy: [".", "#", "$", "[", "]"]).joined() // TODO: Keychain에 저장 시 특이 문자 제거
        
        // date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let date = dateFormatter.string(from: Date())
        
        // ref.child("users").child("\(userIdentifier)").child(date).child(minute).setValue(["count": cnt])
        ref.child("users").child(userIdentifier).child(date).getData { error, snapshot in
            guard error == nil else { return }
            guard let val = snapshot?.value as? [String: [String: Any]] else { return }
            let sortedValue = val.sorted { $0.0 < $1.0 } // 시간 순(key)대로 정렬
            
            var timeArray:[String] = []
            var countArray:[Int] = []
            for (timeValue, countValue) in sortedValue {
                let cnt = countValue["count"] as! Int
                timeArray.append(timeValue)
                countArray.append(cnt)
                self.setChart(timeArray: timeArray, countArray: countArray)
                print("시각: \(timeValue), 카운트: \(cnt)")
            }
        }
    }
    
    private func initDateLabel() {
        // date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        let date = dateFormatter.string(from: Date())
        dateLabel.text = "\(date)의 기록입니다."
    }
    
    private func initChart() {
        lineChartView.noDataText = "데이터가 없습니다."
        lineChartView.noDataFont = .boldSystemFont(ofSize: 16)
    }
    
    private func setChart(timeArray: [String], countArray: [Int]) {
        var dataEntries:[ChartDataEntry] = []
        for idx in 0..<timeArray.count {
            let dataEntry = ChartDataEntry(x: Double(idx), y: Double(countArray[idx]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(entries: dataEntries)
        
        // 차트 레이블
        lineChartView.xAxis.labelPosition = .bottom // x축 레이블 위치 밑으로 조정
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeArray) // x축 레이블 포맷 지정
        lineChartView.rightAxis.enabled = false // 오른쪽 레이블 제거
        lineChartView.xAxis.setLabelCount(6, force: false)
        lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 16)
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 11)
        lineChartView.leftAxis.granularityEnabled = true // 실수 -> 정수
        lineChartView.leftAxis.granularity = 1.0
        lineChartView.extraTopOffset = 40
        
        // 차트 속성
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.leftAxis.axisMaximum = 20
        lineChartView.legend.enabled = false
        
        // 차트 모양
        chartDataSet.mode = .cubicBezier
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 2
        chartDataSet.highlightEnabled = false // 선택 불가
        chartDataSet.valueFormatter = DigitValueFormatter()
        
        // 차트 색상
        chartDataSet.colors = [.systemMint]
        chartDataSet.fill = ColorFill(color: .systemMint)
        chartDataSet.fillAlpha = 0.5
        chartDataSet.drawFilledEnabled = true

        chartDataSet.valueFont = .boldSystemFont(ofSize: 11)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
    }
}



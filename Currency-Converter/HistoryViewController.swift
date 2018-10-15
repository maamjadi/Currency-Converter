//
//  HistoryViewController.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/11/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import UIKit
import Charts

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var chartView: LineChartView!
    
    private var chartData = [(key: String, value: Double)]() {
        didSet {
            setChartData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupChartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        RateHandler.shared.convertionForLastSevenDays { (succ, err, data) in
            print(data)
            self.chartData = data
        }
    }
    
    private func setupChartView() {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.legend.form = .line
        
        let limitLine = ChartLimitLine(limit: 0, label: "")
        limitLine.lineColor = UIColor.black.withAlphaComponent(0.3)
        limitLine.lineWidth = 1
        
        chartView.rightAxis.addLimitLine(limitLine)
        chartView.leftAxis.addLimitLine(limitLine)
        chartView.animate(xAxisDuration: 2.5)
    }
    
    private func setChartData() {
        let values = (0..<chartData.count).map { (i) -> ChartDataEntry in
            let val = chartData[i].value
            print(val)
            return ChartDataEntry(x: Double(i-1), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "Converted value history")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.white)
        set1.setCircleColor(.white)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [UIColor(named: "LightColor")?.withAlphaComponent(0.1).cgColor,
                              UIColor(named: "LightColor")?.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }

}

extension HistoryViewController: ChartViewDelegate {
    
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupChartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        RateHandler.shared.convertionForLastSevenDays { (succ, err, data) in
            if !(data.isEmpty) {
                for theData in data {
                    print(theData)
                }
            }
        }
    }
    
    private func setupChartView() {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.animate(xAxisDuration: 2.5)
    }

}

extension HistoryViewController: ChartViewDelegate {
    
}

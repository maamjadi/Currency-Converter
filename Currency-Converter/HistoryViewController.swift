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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var topGradientView: UIView!
    
    private var chartData = [(key: String, value: Double)]() {
        didSet {
            setChartData()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupGradientViewsColor(theView: topGradientView)
        setupGradientViewsColor(topView: false, theView: bottomGradientView)
        tableView.delegate = self
        tableView.dataSource = self
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
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.drawBordersEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.minOffset = 0
    }
    
    private func setupGradientViewsColor(topView: Bool = true, theView: UIView) {
        let color1 = UIColor(named: "DarkColor") ?? .clear
        var color2 = color1.withAlphaComponent(0)
        let gradientLayer = CAGradientLayer()
        
        if topView {
            color2 = color1.withAlphaComponent(0.5)
            gradientLayer.colors = [ color1.cgColor, color2.cgColor ]
        } else {
            gradientLayer.colors = [ color2.cgColor, color1.cgColor ]
        }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = theView.bounds
        theView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setChartData() {
        let values = (0..<chartData.count).map { (i) -> ChartDataEntry in
            let val = chartData[i].value
            print(val)
            return ChartDataEntry(x: Double(i+1), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 0]
        set1.highlightLineDashLengths = [5, 0]
        set1.setColor(#colorLiteral(red: 0.0706, green: 0.4784, blue: 0.7569, alpha: 1))
        set1.setCircleColor(#colorLiteral(red: 0.0706, green: 0.4784, blue: 0.7569, alpha: 1))
        set1.lineWidth = 3
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 0)
        set1.formLineDashLengths = [5, 0]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [UIColor(named: "LightColor")?.withAlphaComponent(0).cgColor,
                              UIColor(named: "LightColor")?.cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
        chartView.data?.setValueTextColor(.white)
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (chartData.count + 2)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let index = indexPath.row
        if (index == 0 || index == (chartData.count + 1)) {
            cell.textLabel?.isHidden = true
            cell.detailTextLabel?.isHidden = true
            cell.selectionStyle = .none
            return cell
        } else {
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
            //to show the array data in reverse in tableview
            let dataIndex = chartData.count - index
            let theData = chartData[dataIndex]
            cell.textLabel?.text = theData.key
            let doubleStr = String(format: "%.5f", theData.value)
            cell.detailTextLabel?.text = doubleStr
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension HistoryViewController: ChartViewDelegate {
    
}

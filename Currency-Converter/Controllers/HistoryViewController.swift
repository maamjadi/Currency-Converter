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
    
    private var cellSelected: Bool = false
    private var circleColors = [UIColor]()
    
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
        chartView.dragEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
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
        let color2 = color1.withAlphaComponent(0)
        let gradientLayer = CAGradientLayer()
        
        if topView {
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
            circleColors.append(#colorLiteral(red: 0.0706, green: 0.4784, blue: 0.7569, alpha: 1))
            return ChartDataEntry(x: Double(i+1), y: val)
        }
        
        let set1 = LineChartDataSet(values: values, label: "")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 0]
        set1.highlightLineDashLengths = [5, 0]
        set1.setColor(#colorLiteral(red: 0.0706, green: 0.4784, blue: 0.7569, alpha: 1))
        set1.circleColors = circleColors
        set1.lineWidth = 3
        set1.circleRadius = 4
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
        chartView.data?.highlightEnabled = true
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
        //showing 2 empty cells, one at the start and one at the end to make up for the gradient views
        if (index == 0 || index == (chartData.count + 1)) {
            cell.textLabel?.isHidden = true
            cell.detailTextLabel?.isHidden = true
            cell.selectionStyle = .none
            return cell
        } else {
            cell.selectionStyle = .blue
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        //to get the correct x point for the respective chart data point
        let xPoint = Double(chartData.count - indexPath.row + 1)
        chartView.highlightValue(x: xPoint, dataSetIndex: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension HistoryViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if !(cellSelected) {
            //if there is a selected cell first deselect it
            if let index = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: index, animated: false)
            }
            //to get the correct row index for the respective table view cell
            let rowIndex = abs(Int(entry.x) - chartData.count) + 1
            let theIndexPath = IndexPath(row: rowIndex, section: 0)
            //selecting the new cell by the x chart data point
            tableView.selectRow(at: theIndexPath, animated: true, scrollPosition: .middle)
            tableView(tableView, didSelectRowAt: theIndexPath)
        } else {
            cellSelected = false
        }
        
        //change the circle color of selected value point
        print("chartValueSelected : x = \(highlight.x) y = \(highlight.y)")
        
        var set1 = LineChartDataSet()
        set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        let values = set1.values
        let index = values.index(where: {$0.x == highlight.x})  // search index
        
        set1.circleColors = circleColors
        set1.circleColors[index!] = .white
        
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chartValueNothingSelected")
        
        var set1 = LineChartDataSet()
        set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
        set1.circleColors = circleColors
        
        chartView.data?.notifyDataChanged()
        chartView.notifyDataSetChanged()
    }
}

//
//  DetailedStatistics.swift
//  Scorecard
//
//  Created by Halcyon Mobile on 7/21/16.
//  Copyright © 2016 Halcyon Mobile. All rights reserved.
//

import Foundation
import UIKit
import Charts
import ChameleonFramework

class DetailedStatisticViewController : BaseViewController {
    
    let reuseIdentifier : String = "StatsDetailCell"
    let dataService = DataService.sharedInstance
    var statsDetail : StatsDetail!
    var statsTableDetail : UITableView!
    var statisticsChart : StatisticsChart!
    var currentMetric : Metric!
    var differenceAndPercent : (Int, Double)!
    var submetricArray : [Int] = []
    var timeFrame : Int!
    var colors : [UIColor]!
    var allColors : [UIColor]!
    var evolutionArray : [EvolutionSign] = []
    var highlights: [Int: ChartHighlight] = [:]
    var allHighlights: [ChartHighlight] = []
    let timeFrameView = TimeFrame()
    var originalMetric : Metric!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
    }
    
    init(originalMetric: Metric, metric: Metric, differenceAndPercent: (Int, Double), timeFrame : Int){
        super.init()
        self.originalMetric = originalMetric
        self.currentMetric = metric
        self.differenceAndPercent = differenceAndPercent
        self.timeFrame = timeFrame
        getPreviousSubmetricCount()
        for _ in 0..<currentMetric.submetrics.count {
            evolutionArray.append(.None)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI() {
        view.backgroundColor = Color.mainBackground
        title = "Statistics"
        statsDetail = StatsDetail()
        statsDetail.delegate = self
        statsDetail.translatesAutoresizingMaskIntoConstraints = false
        setupInformation()
        view.addSubview(statsDetail)
        
        timeFrameView.selectedIndex = timeFrame
        timeFrameView.delegate = self
        timeFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeFrameView)
        
        setupStatsTableDetail()
        statisticsChart = StatisticsChart()
        statisticsChart.delegate = self
        statisticsChart.translatesAutoresizingMaskIntoConstraints = false
        setChartData()
        view.addSubview(statisticsChart)
    }
    
    private func setupStatsTableDetail(){
        statsTableDetail = UITableView()
        statsTableDetail.dataSource = self
        statsTableDetail.delegate = self
        statsTableDetail.backgroundColor = Color.mainBackground
        statsTableDetail.registerClass(StatsDetailCell.self, forCellReuseIdentifier: "StatsDetailCell")
        statsTableDetail.separatorColor = UIColor.clearColor()
        statsTableDetail.translatesAutoresizingMaskIntoConstraints = false
        statsTableDetail.rowHeight = 30.0
        statsTableDetail.allowsSelection = true
        view.addSubview(statsTableDetail)
    }
    
    override func setupConstraints() {
        
        var allConstraints = [NSLayoutConstraint]()
        let dictionary = ["statsDetail": statsDetail, "timeFrameView": timeFrameView, "statsTableDetail": statsTableDetail, "statisticsChart": statisticsChart]
        var tableHeight : Int = 0
        let screenResolutionFactor = Int(screenHeight/100)-1
        
        if currentMetric.submetrics.count < screenResolutionFactor {
            tableHeight =  Int(statsTableDetail.rowHeight) * currentMetric.submetrics.count
        } else {
            tableHeight  = screenResolutionFactor * Int(statsTableDetail.rowHeight)
        }
        tableHeight += 8
        
        allConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[timeFrameView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dictionary)
        allConstraints.append(NSLayoutConstraint(item: statsTableDetail, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: CGFloat(tableHeight)))
        allConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[timeFrameView(30)][statsDetail][statsTableDetail][statisticsChart]|", options: [.AlignAllLeft, .AlignAllRight], metrics: nil, views: dictionary)
        view.addConstraints(allConstraints)
    }
    
    func getPreviousSubmetricCount() {
        switch timeFrame {
        case 0 :
            submetricArray = dataService.getSubmetricCount(currentMetric)
            break
        case 1 :
            submetricArray = dataService.getSubmetricCount(currentMetric)
            break
        case 2 :
            submetricArray = dataService.getSubmetricCount(currentMetric)
            break
        case 3:
            submetricArray = dataService.getSubmetricCount(currentMetric)
            break
        case 4:
            submetricArray = dataService.getSubmetricCount(currentMetric)
            break
        default :
            break
        }
    }
}

// MARK - UITableViewDelegate

extension DetailedStatisticViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let boolean = (statisticsChart.data?.dataSets[indexPath.row].isVisible)!
        statisticsChart.data?.dataSets[indexPath.row].visible = !boolean
        let cell : StatsDetailCell = tableView.cellForRowAtIndexPath(indexPath) as! StatsDetailCell
        cell.backgroundColor = Color.mainBackground
        let customView = UIView()
        
        if statisticsChart.data?.dataSets[indexPath.row].visible == true {
            colors[indexPath.row] = allColors[indexPath.row]
            // only if a selection has been made on the chart (there already are highlights)
            if allHighlights != [] {
                highlights[indexPath.row] = allHighlights[indexPath.row]
            }
        }
        else {
            colors[indexPath.row] = UIColor.darkGrayColor()
            highlights.removeValueForKey(indexPath.row)
        }
        
        cell.identifier.tintColor = colors[indexPath.row]
        customView.backgroundColor = colors[indexPath.row]
        cell.selectedBackgroundView = customView
        
        statisticsChart.highlightValues(Array<ChartHighlight>(highlights.values))
        statisticsChart.data?.dataSets[indexPath.row].notifyDataSetChanged()
        statisticsChart.setNeedsDisplay()
        statsTableDetail.deselectRowAtIndexPath(indexPath, animated: true)
        statsTableDetail.reloadData()
    }
}

// MARK - UITableViewDataSource

extension DetailedStatisticViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMetric.submetrics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : StatsDetailCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StatsDetailCell
        let animation: CATransition = CATransition()
        
        animation.duration = 0.3
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        cell.difference.layer.addAnimation(animation ,forKey :"layerFadeOut")
        cell.sign.layer.addAnimation(animation, forKey :"layerFadeOut")
        cell.identifier.image = UIImage(named: "Circle")
        cell.identifier.image = cell.identifier.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.identifier.tintColor = colors[indexPath.row]
        cell.typeName.text = currentMetric.submetrics[indexPath.row].name
        if statisticsChart.data?.dataSets[indexPath.row].visible == true {
            cell.difference.text = submetricArray[indexPath.row].prettyString()
            cell.sign.image = evolutionArray[indexPath.row].getSign()
        }
        else {
            cell.difference.text = "0"
            cell.sign.image = EvolutionSign.None.getSign()
        }
        return cell
    }
}

// MARK - ChartViewDelegate

extension DetailedStatisticViewController: ChartViewDelegate {
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
        let selectedIndex = entry.xIndex
        var i = 0
        
        allHighlights = []
        highlights = [:]
        
        for dataSet in (chartView.data?.dataSets)! {
            let marker = CircleMarker(color: (chartView.data?.dataSets[i].colors[0])!)
            
            marker.minimumSize = CGSizeMake(7.0 , 7.0)
            marker.offset = CGPointMake(0.0, 1.0)
            chartView.marker = marker
            let highlight = ChartHighlight(xIndex: selectedIndex, dataSetIndex: i)
            allHighlights.append(highlight)
            if dataSet.isVisible {
                let highlight = ChartHighlight(xIndex: selectedIndex, dataSetIndex: i)
                highlights[i] = highlight
            }
            submetricArray[i] = Int((dataSet.entryForXIndex(selectedIndex)?.value)!)
            if selectedIndex != 0 {
                if (dataSet.entryForXIndex(selectedIndex)?.value)! > (dataSet.entryForXIndex(selectedIndex - 1)?.value)! {
                    evolutionArray[i] = .ArrowUp
                } else if (dataSet.entryForXIndex(selectedIndex)?.value)! < (dataSet.entryForXIndex(selectedIndex - 1)?.value)! {
                    evolutionArray[i] = .ArrowDown
                } else {
                    evolutionArray[i] = .None
                }
            } else {
                evolutionArray[i] = .None
            }
            currentMetric.submetrics[i].name = dataSet.label!
            i += 1
        }
        chartView.highlightValues(Array<ChartHighlight>(highlights.values))
        statsTableDetail.reloadData()
    }
    
    func setChartData() {
        var xAxis : [String] = []
        
        // empty color arrays
        colors = []
        allColors = []
        
        var colorArray = ColorSchemeOf(.Analogous, color: getRandomColor(), isFlatScheme: true)
        
        while colorArray.count < currentMetric.submetrics.count {
            colorArray += ColorSchemeOf(.Analogous, color: colorArray[colorArray.count - 1], isFlatScheme: true)
        }
        
        switch timeFrame {
        case 0 :
            xAxis = ["01:00", "02:00", "03:00","04:00","05:00","06:00","07:00","08:00",
                     "09:00","10:00","11:00","12:00","13:00","14:00","15:00","16:00",
                     "17:00","18:00","19:00","20:00","21:00","22:00","23:00","0:00"]
            let chartData = LineChartData(xVals: xAxis)
            for i in 0..<currentMetric.submetrics.count {
                let submetricName = currentMetric.submetrics[i].name
                let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                chartDataSet.mode = .CubicBezier
                chartDataSet.drawValuesEnabled = false
                chartDataSet.drawCirclesEnabled = false
                chartDataSet.setColor(colorArray[i], alpha: 0.5)
                chartDataSet.fillColor = colorArray[i]
                chartDataSet.fillAlpha = 0.5
                chartDataSet.drawFilledEnabled = true
                chartDataSet.highlightLineWidth = 0.0
                chartData.addDataSet(chartDataSet)
                colors.append(colorArray[i])
                allColors.append(colorArray[i])
            }
            statisticsChart.data = chartData
            break
        case 1 :
            xAxis = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let chartData = LineChartData(xVals: xAxis)
            for i in 0..<currentMetric.submetrics.count {
                let submetricName = currentMetric.submetrics[i].name
                let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                chartDataSet.mode = .CubicBezier
                chartDataSet.drawValuesEnabled = false
                chartDataSet.drawCirclesEnabled = false
                chartDataSet.setColor(colorArray[i], alpha: 0.5)
                chartDataSet.fillColor = colorArray[i]
                chartDataSet.fillAlpha = 0.5
                chartDataSet.drawFilledEnabled = true
                chartDataSet.highlightLineWidth = 0.0
                chartData.addDataSet(chartDataSet)
                colors.append(colorArray[i])
                allColors.append(colorArray[i])
            }
            statisticsChart.data = chartData
            break
        case 2 :
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM"
            let currentMonth = dateFormatter.stringFromDate(NSDate()).uppercaseString
            switch currentMonth {
            case "JAN", "MAR", "MAY", "JUL", "AUG", "OCT", "DEC": //31
                xAxis = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
                         "13", "14", "15", "16", "17", "18", "19", "20", "21", "22",
                         "23", "24", "25", "26", "27", "28", "29", "30", "31"]
                let chartData = LineChartData(xVals: xAxis)
                for i in 0..<currentMetric.submetrics.count {
                    let submetricName = currentMetric.submetrics[i].name
                    let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                    let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                    chartDataSet.mode = .CubicBezier
                    chartDataSet.drawValuesEnabled = false
                    chartDataSet.drawCirclesEnabled = false
                    chartDataSet.setColor(colorArray[i], alpha: 0.5)
                    chartDataSet.fillColor = colorArray[i]
                    chartDataSet.fillAlpha = 0.5
                    chartDataSet.drawFilledEnabled = true
                    chartDataSet.highlightLineWidth = 0.0
                    chartData.addDataSet(chartDataSet)
                    colors.append(colorArray[i])
                    allColors.append(colorArray[i])
                }
                statisticsChart.data = chartData
                break
            case "FEB": // 28
                xAxis = ["1", "2", "3", "4", "5", "6", "7", "8",
                         "9", "10", "11", "12", "13", "14", "15",
                         "16", "17", "18", "19", "20", "21", "22",
                         "23", "24", "25", "26", "27", "28"]
                let chartData = LineChartData(xVals: xAxis)
                for i in 0..<currentMetric.submetrics.count {
                    let submetricName = currentMetric.submetrics[i].name
                    let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                    let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                    chartDataSet.mode = .CubicBezier
                    chartDataSet.drawValuesEnabled = false
                    chartDataSet.drawCirclesEnabled = false
                    chartDataSet.setColor(colorArray[i], alpha: 0.5)
                    chartDataSet.fillColor = colorArray[i]
                    chartDataSet.fillAlpha = 0.5
                    chartDataSet.drawFilledEnabled = true
                    chartDataSet.highlightLineWidth = 0.0
                    chartData.addDataSet(chartDataSet)
                    colors.append(colorArray[i])
                    allColors.append(colorArray[i])
                }
                statisticsChart.data = chartData
                break
            case "APR", "JUN", "SEP", "NOV": //30
                xAxis = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11",
                         "12", "13", "14", "15", "16", "17", "18", "19", "20",
                         "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
                let chartData = LineChartData(xVals: xAxis)
                for i in 0..<currentMetric.submetrics.count {
                    let submetricName = currentMetric.submetrics[i].name
                    let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                    let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                    chartDataSet.mode = .CubicBezier
                    chartDataSet.drawValuesEnabled = false
                    chartDataSet.drawCirclesEnabled = false
                    chartDataSet.setColor(colorArray[i], alpha: 0.5)
                    chartDataSet.fillColor = colorArray[i]
                    chartDataSet.fillAlpha = 0.5
                    chartDataSet.drawFilledEnabled = true
                    chartDataSet.highlightLineWidth = 0.0
                    chartData.addDataSet(chartDataSet)
                    colors.append(colorArray[i])
                    allColors.append(colorArray[i])
                }
                statisticsChart.data = chartData
                break
            default:
                break
            }
            break
        case 3:
            xAxis = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
            let chartData = LineChartData(xVals: xAxis)
            for i in 0..<currentMetric.submetrics.count {
                let submetricName = currentMetric.submetrics[i].name
                let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                chartDataSet.mode = .CubicBezier
                chartDataSet.drawValuesEnabled = false
                chartDataSet.drawCirclesEnabled = false
                chartDataSet.setColor(colorArray[i], alpha: 0.5)
                chartDataSet.fillColor = colorArray[i]
                chartDataSet.fillAlpha = 0.5
                chartDataSet.drawFilledEnabled = true
                chartDataSet.highlightLineWidth = 0.0
                chartData.addDataSet(chartDataSet)
                colors.append(colorArray[i])
                allColors.append(colorArray[i])
            }
            statisticsChart.data = chartData
            break
        case 4:
            xAxis = dataService.getYearsLimit(currentMetric)
            let chartData = LineChartData(xVals: xAxis)
            for i in 0..<currentMetric.submetrics.count {
                let submetricName = currentMetric.submetrics[i].name
                let chartEntries = dataService.getDiagramFor(currentMetric.submetrics[i].values, timeFrame: timeFrame, xAxis: xAxis)
                let chartDataSet = LineChartDataSet(yVals: chartEntries, label: submetricName)
                chartDataSet.mode = .CubicBezier
                chartDataSet.drawValuesEnabled = false
                chartDataSet.drawCirclesEnabled = false
                chartDataSet.setColor(colorArray[i], alpha: 0.5)
                chartDataSet.fillColor = colorArray[i]
                chartDataSet.fillAlpha = 0.5
                chartDataSet.drawFilledEnabled = true
                chartDataSet.highlightLineWidth = 0.0
                chartData.addDataSet(chartDataSet)
                colors.append(colorArray[i])
                allColors.append(colorArray[i])
            }
            statisticsChart.data = chartData
            break
        default :
            break
        }
    }
    
    func getRandomColor() -> UIColor {
        
        var color = RandomFlatColorWithShade(.Light)
        while [FlatBlack(), FlatBlackDark(), FlatGray(), FlatGrayDark(), FlatWhite(), FlatWhiteDark()].contains(color) {
            color = RandomFlatColorWithShade(.Light)
        }
        return color
    }
}

// MARK - StatsDetailDelegate

extension DetailedStatisticViewController: StatsDetailSetupInformationDelegate {
    func setupInformation(){
        statsDetail.typeName.text = currentMetric.name
        statsDetail.counter.text = dataService.sumMetricValues(currentMetric)
        if differenceAndPercent.0 < 0 {
            statsDetail.difference.text = "\(differenceAndPercent.0.prettyString())"
            statsDetail.difference.textColor = Color.statsFall
            statsDetail.percent.textColor = Color.statsFall
            statsDetail.percent.text = String(format: "%.2f",differenceAndPercent.1) + "%"
            statsDetail.sign.image = EvolutionSign.ArrowDown.getSign()
        }
        else if differenceAndPercent.0 == 0 {
            statsDetail.difference.text = "\(differenceAndPercent.0.prettyString())"
            statsDetail.difference.textColor = Color.textColor
            statsDetail.percent.textColor = Color.textColor
            statsDetail.percent.text = String(format: "%.2f",differenceAndPercent.1) + "%"
            statsDetail.sign.image = EvolutionSign.None.getSign()
        }
        else if differenceAndPercent.0 > 0 {
            statsDetail.difference.text = "+\(differenceAndPercent.0.prettyString())"
            statsDetail.difference.textColor = Color.statsRise
            statsDetail.percent.textColor = Color.statsRise
            statsDetail.percent.text = String(format: "+%.2f",differenceAndPercent.1) + "%"
            statsDetail.sign.image = EvolutionSign.ArrowUp.getSign()
        }
    }
}

extension DetailedStatisticViewController: TimeFrameDelegate {
    func timeFrameSelectedValue(selectedIndex: Int) {
        
        var tableHeight = 0
        var newTableHeight = 0
        let screenResolutionFactor = Int(screenHeight/100)-1
        
        if currentMetric.submetrics.count < screenResolutionFactor {
            tableHeight =  Int(statsTableDetail.rowHeight) * currentMetric.submetrics.count
        } else {
            tableHeight  = screenResolutionFactor * Int(statsTableDetail.rowHeight)
        }
        tableHeight += 8
        
        timeFrame = selectedIndex
        switch selectedIndex {
        case 0 :
            currentMetric = dataService.filterMetric(originalMetric, type: .OneDay)
            differenceAndPercent = dataService.getMetricPreviousCount(originalMetric, type: .OneDay)
            break
        case 1 :
            currentMetric = dataService.filterMetric(originalMetric, type: .OneWeek)
            differenceAndPercent = dataService.getMetricPreviousCount(originalMetric, type: .OneWeek)
            break
        case 2 :
            currentMetric = dataService.filterMetric(originalMetric, type: .OneMonth)
            differenceAndPercent = dataService.getMetricPreviousCount(originalMetric, type: .OneMonth)
            break
        case 3 :
            currentMetric = dataService.filterMetric(originalMetric, type: .OneYear)
            differenceAndPercent = dataService.getMetricPreviousCount(originalMetric, type: .OneYear)
            break
        case 4 :
            currentMetric = dataService.filterMetric(originalMetric, type: .All)
            differenceAndPercent = dataService.getMetricPreviousCount(originalMetric, type: .All)
            break
        default :
            break
        }
        getPreviousSubmetricCount()
        setChartData()
        setupInformation()
        statsTableDetail.reloadData()
        evolutionArray.removeAll()
        for _ in 0..<currentMetric.submetrics.count {
            evolutionArray.append(.None)
        }
        if currentMetric.submetrics.count < screenResolutionFactor {
            newTableHeight =  Int(statsTableDetail.rowHeight) * currentMetric.submetrics.count
        } else {
            newTableHeight  = screenResolutionFactor * Int(statsTableDetail.rowHeight)
        }
        newTableHeight += 8
        for constraint in view.constraints {
            if constraint.constant == CGFloat(tableHeight) {
                constraint.constant = CGFloat(newTableHeight)
            }
        }
        view.setNeedsLayout()
        statisticsChart.highlightValues([])
    }
}
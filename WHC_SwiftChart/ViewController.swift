//
//  ViewController.swift
//  WHC_SwiftChart
//
//  Created by 吴海超 on 15/1/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

/*
*  qq:712641411
*  qq群:460122071
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/

import UIKit

class ViewController: UIViewController {

    var btn:UIButton!;
    var lineView:WHCChartView!;
    var barView:WHCChartView!;
    var peiView:WHCChartView!;
    var  x:CGFloat = 0.0 ,y:CGFloat = 0.0;
    override func viewDidLoad() {
        super.viewDidLoad()
        let height:CGFloat = UIScreen.mainScreen().bounds.size.height / 3.0;
        barView = createWhcChart(CGRectMake(0.0, 20.0,DeveloperDetail.KSCREEN_WIDTH ,height), style: WHCChartStyle.BAR_CHART);
        self.view.addSubview(barView);
        
        lineView = createWhcChart(CGRectMake(0.0, barView.frame.origin.y + barView.frame.size.height,DeveloperDetail.KSCREEN_WIDTH ,height), style: WHCChartStyle.LINE_CHART);
        self.view.addSubview(lineView);
        
        peiView = createWhcChart(CGRectMake(0.0, lineView.frame.origin.y + lineView.frame.size.height,DeveloperDetail.KSCREEN_WIDTH ,height), style: WHCChartStyle.PIE_CHART);
        self.view.addSubview(peiView);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func createWhcChart(frame:CGRect,style:WHCChartStyle)->WHCChartView{
        var chartView:WHCChartView = WHCChartView(frame: frame, style: style);
        chartView.backgroundColor = UIColor.whiteColor();
        chartView.addTouchGesture();
        return chartView;
    }
    
    func clickBtn(sender:UIButton){
        
        x += 1.0;
        y += 1.0;
        var scaleNumbers:[NSDictionary] = [["x":5.0,"y":1.0 + y],["x":8.0,"y":40.0 - y],["x":15.0,"y":20.0 + y],["x":25.0,"y":30.0 + y],["x":27.0,"y":35.0 - y],["x":45,"y":10.0 + y]];
        lineView.setScaleNumber(scaleNumbers);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  WHCChartView.swift
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

enum WHCChartStyle{
    case BAR_CHART;
    case LINE_CHART;
    case PIE_CHART;
}
enum StringDirection{
    case TOP;
    case LEFT;
    case RIGHT;
    case BOTTOM;
}

class WHCChartView: UIView {
    var c:CGContext!;
    var chartStyle : WHCChartStyle = .BAR_CHART;
    let KPading : CGFloat = 50.0;
    let KScalePading : CGFloat = 20.0;
    let KArrowHeight : CGFloat = 5.0;
    let KScaleUnitHeight : CGFloat = 10.0;
    let KSubScaleUnitHeight : CGFloat = 5.0;
    var subUnitScaleNumber : Int = 5;
    var xScaleUnit : CGFloat = 10.0;
    var yScaleUnit : CGFloat = 5.0;
    var xMaxScale : CGFloat = 50.0;
    var yMaxScale : CGFloat = 50.0;
    var xCoorUnit : NSString = "(人数)";
    var yCoorUnit : NSString = "(万元)";
    private var xScaleWidth : CGFloat = 0.0;
    private var yScaleWidth : CGFloat = 0.0;
    private var xScaleValid : CGFloat = 0.0;
    private var yScaleValid : CGFloat = 0.0;
    var scaleNumbers:[NSDictionary] = [["x":5.0,"y":1.0],["x":8.0,"y":40.0],["x":15.0,"y":20.0],["x":25.0,"y":30.0],["x":27.0,"y":35.0],["x":45,"y":10.0]];
    var barChartNames:[NSDictionary] = [["中专":20],["大专":30],["本科":40],["研究生":20],["博士":10]];
    var pieChartVaules:[NSDictionary] = [["博士":5.0],["研究生":15.0],["中专":20.0],["大专":25.0],["本科":35.0]];
    var pieUnitColors:[UIColor] = [UIColor.redColor(),UIColor.blueColor(),UIColor.yellowColor(),UIColor.greenColor(),UIColor.magentaColor()];
    private var beginTouchPoint:CGPoint = CGPointZero;
    private var xCoorRatio:CGFloat = 0.0;
    private var yCoorRatio:CGFloat = 0.0;
    private var xMinValidCoor:CGFloat = 0.0;
    private var yMinValidCoor:CGFloat = 0.0;
    private var xMaxValidCoor:CGFloat = 0.0;
    private var yMaxValidCoor:CGFloat = 0.0;
    
    private var paths:[CGMutablePathRef] = [];
    private var animations:NSMutableArray = NSMutableArray();
    private var shapeLayers:[CAShapeLayer] = [];
    private var index:Int = 0;
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame);
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    convenience init(frame: CGRect , style: WHCChartStyle) {
        self.init(frame: frame);
        chartStyle = style;
    }
    
    // MARK: - customFunc
    
    func setScaleNumber(scales:[NSDictionary]){
        scaleNumbers = scales;
        self.setNeedsDisplay();
    }
    
    func addTouchGesture(){
        switch chartStyle{
        case .LINE_CHART:
            let longGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLineChartLongGesture:");
            longGesture.minimumPressDuration = 0.2;
            self.addGestureRecognizer(longGesture);
            break;
        case .BAR_CHART:
            let longGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleBarChartLongGesture:");
            longGesture.minimumPressDuration = 0.2;
            self.addGestureRecognizer(longGesture);
            break;
        case .PIE_CHART:
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handlePieChartTapGesture:");
            self.addGestureRecognizer(tapGesture);
            break;
        default:
            break;
        }
    }
    
    // MARK: - handleTouchGesture
    func handlePieChartTapGesture(tapGesture:UITapGestureRecognizer){
        self.setNeedsDisplay();
    }
    
    func handleLineChartLongGesture(longGesture:UILongPressGestureRecognizer){
        let point:CGPoint = longGesture.locationInView(self);
        beginTouchPoint = point;
    /*  仅限制坐标系边界
        if(point.x > KPading + xScaleValid){
            beginTouchPoint.x = KPading + xScaleValid;
        }else if(point.x < KPading){
            beginTouchPoint.x = KPading;
        }
        if(point.y < KPading + KScalePading){
            beginTouchPoint.y = KPading + KScalePading;
        }else if(point.y > self.frame.size.height - KPading){
            beginTouchPoint.y = self.frame.size.height - KPading;
        }
*/
        //仅限制最大有效坐标点边界
        if(beginTouchPoint.x < xMinValidCoor){
            beginTouchPoint.x = xMinValidCoor;
        }
        if(beginTouchPoint.x > xMaxValidCoor){
            beginTouchPoint.x = xMaxValidCoor;
        }
        if(beginTouchPoint.y < yMinValidCoor){
            beginTouchPoint.y = yMinValidCoor;
        }
        if(beginTouchPoint.y > yMaxValidCoor){
            beginTouchPoint.y = yMaxValidCoor;
        }
        switch longGesture.state{
        case .Began:
            calcValidMoveDistance();
            self.setNeedsDisplay();
            break;
        case .Changed:
            self.setNeedsDisplay();
            break;
        case .Cancelled,.Ended:
            beginTouchPoint = CGPointZero;
            self.setNeedsDisplay();
            break;
        default:
            break;
        }
    }
    
    func handleBarChartLongGesture(longGesture:UILongPressGestureRecognizer){
        let point:CGPoint = longGesture.locationInView(self);
        beginTouchPoint = point;
        if(beginTouchPoint.y < yMinValidCoor){
            beginTouchPoint.y = yMinValidCoor;
        }else if(beginTouchPoint.y > yMaxValidCoor){
            beginTouchPoint.y = yMaxValidCoor;
        }
        switch longGesture.state{
        case .Began:
            calcValidMoveDistance();
            self.setNeedsDisplay();
            break;
        case .Changed:
            self.setNeedsDisplay();
            break;
        case .Cancelled,.Ended:
            beginTouchPoint = CGPointZero;
            self.setNeedsDisplay();
            break;
        default:
            break;
        }

    }
    
    //把实际坐标点转换为屏幕坐标
    private func getScreenCoorPointWithIndex(index:Int)->CGPoint{
        var point:CGPoint = CGPointZero;
        if(index >= 0 || index < scaleNumbers.count){
            let coorDic:NSDictionary = scaleNumbers[index]
            let x:CGFloat = CGFloat((coorDic.objectForKey("x") as! NSNumber).floatValue) * xCoorRatio + KPading;
            let y:CGFloat = self.frame.size.height - KPading - CGFloat((coorDic.objectForKey("y") as! NSNumber).floatValue) * yCoorRatio;
            point.x = x;
            point.y = y;
        }
        return point;
    }
    
    //折线图：把屏幕坐标转为要显示的实际坐标
    private func getActualCoorPointWithIndex(index:Int)->CGPoint{
        var point:CGPoint = CGPointZero;
        if(index >= 0 || index < scaleNumbers.count){
            point = getScreenCoorPointWithIndex(index);
            point.x = (point.x - KPading) / xCoorRatio;
            point.y = (self.frame.size.height - point.y - KPading) / yCoorRatio;
        }
        return point;
    }
    
    //折线图：直接从数组里取实际坐标
    private func getActualCoorPointFromScaleNumbersWithIndex(index:Int)->CGPoint{
        var point:CGPoint = CGPointZero;
        if(index >= 0 || index < scaleNumbers.count){
            let coorDic:NSDictionary = scaleNumbers[index];
            point.x = CGFloat((coorDic.objectForKey("x") as! NSNumber).floatValue);
            point.y = CGFloat((coorDic.objectForKey("y") as! NSNumber).floatValue);
        }
        return point;
    }
    
    //条形图：把实际坐标转换为屏幕坐标
    private func getBarChartScreenHeightWithIndex(index:Int)->CGFloat{
        let chartDic:NSDictionary = barChartNames[index];
        let height:CGFloat = CGFloat((chartDic.objectForKey(chartDic.allKeys[0]) as! NSNumber).floatValue) * yCoorRatio;
        return height;
    }
    
    //条形图：把屏幕坐标转换为实际坐标
    private func getBarChartActualHeightWithIndex(index:Int)->CGFloat{
        let chartDic:NSDictionary = barChartNames[index];
        let height:CGFloat = CGFloat((chartDic.objectForKey(chartDic.allKeys[0]) as! NSNumber).floatValue);
        return height;
    }
    
    private func calcValidMoveDistance(){
        if(chartStyle == WHCChartStyle.LINE_CHART){
            var x:CGFloat,y:CGFloat;
            let onePoint:CGPoint = getScreenCoorPointWithIndex(0);
            xMaxValidCoor = 0.0;
            yMaxValidCoor = 0.0;
            xMinValidCoor = onePoint.x;
            yMinValidCoor = onePoint.y;
            for(var i = 0;i < scaleNumbers.count;i++){
                let tempPoint = getScreenCoorPointWithIndex(i);
                if(xMinValidCoor > tempPoint.x){
                    xMinValidCoor = tempPoint.x;
                }
                if(xMaxValidCoor < tempPoint.x){
                    xMaxValidCoor = tempPoint.x;
                }
                if(yMinValidCoor > tempPoint.y){
                    yMinValidCoor = tempPoint.y;
                }
                if(yMaxValidCoor < tempPoint.y){
                    yMaxValidCoor = tempPoint.y;
                }
            }
        }else if(chartStyle == WHCChartStyle.BAR_CHART){
            yMaxValidCoor = bounds.size.height - KPading;
            yMinValidCoor = bounds.size.height - KPading;
            for(var i = 0; i < barChartNames.count;i++){
                let barHeight:CGFloat = bounds.size.height - (getBarChartScreenHeightWithIndex(i) + KPading);
                if(yMinValidCoor > barHeight){
                    yMinValidCoor = barHeight;
                }
            }
        }
    }
    
    private func calcCoorNumberIsDrawUp(point:CGPoint , index:Int)->Bool{
        var isUp = true;
        if(index == 0){
            
        }else if(index == scaleNumbers.count - 1){
            
        }else{
            let frontPoint:CGPoint = getScreenCoorPointWithIndex(index - 1);
            let behindPoint:CGPoint = getScreenCoorPointWithIndex(index + 1);
            if(point.y > frontPoint.y && point.y > behindPoint.y){
                isUp = false;
            }else if(point.y > frontPoint.y && point.y < behindPoint.y){
                isUp = true;
            }else if(point.y < frontPoint.y && point.y < behindPoint.y){
                isUp = true;
            }else if(point.y < frontPoint.y && point.y > behindPoint.y){
                isUp = false;
            }
        }
        return isUp;
    }
    
    private func getFontAttr(fontSize:CGFloat,fontColor:UIColor)->[NSObject:AnyObject]{
        return [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: fontSize)!,
            NSForegroundColorAttributeName:fontColor];
    }
    
    // MARK: - drawRect
    private func drawSolidDot(point:CGPoint , radius:CGFloat){
        let context:CGContext = UIGraphicsGetCurrentContext();
        //画实心点
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, UIColor.blueColor().CGColor);
        CGContextAddArc(context, point.x, point.y, radius, 0.0, CGFloat(2.0 * M_PI), 1);
        CGContextFillPath(context);
        /*
        CGContextDrawPath(context, kCGPathStroke);
        CGContextStrokePath(context);
        CGContextFillPath(context);
        CGContextClip(context);
        CGContextFillEllipseInRect(context, CGRectMake(point.x - 3.0, point.y - 3.0, 6.0, 6.0));
        CGContextFillRect(context, CGRectMake(point.x - 3.0, point.y - 3.0, 6.0, 6.0));
        */
        CGContextRestoreGState(context);
    }
    
    //画xy坐标系单位
    private func drawXYCoorUnit(){
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        let fontAttrDic:[NSObject:AnyObject] = getFontAttr(10.0, fontColor: UIColor.blueColor());
        let xUnitSize:CGSize = xCoorUnit.sizeWithAttributes(fontAttrDic);
        let yUnitSize:CGSize = yCoorUnit.sizeWithAttributes(fontAttrDic);
        xCoorUnit.drawAtPoint(CGPointMake((self.frame.size.width - xUnitSize.width) / 2.0, self.frame.size.height - 2.0 * xUnitSize.height), withAttributes: fontAttrDic);
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGContextRotateCTM(context, CGFloat(0.0));
        yCoorUnit.drawAtPoint(CGPointMake(20.0, KPading - yUnitSize.height), withAttributes: fontAttrDic);
        CGContextRestoreGState(context);
    }
    
    //画实际坐标点
    private func drawCoorDotNumber(point:CGPoint , index:Int){
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        let screenCoorPoint:CGPoint = getScreenCoorPointWithIndex(index);
        let isUp:Bool = calcCoorNumberIsDrawUp(screenCoorPoint, index: index);
        var strCoorNumber:NSString = NSString(format: "(%.1f,%.1f)", Float(point.x),Float(point.y));
        let fontAttrDic:[NSObject:AnyObject] = getFontAttr(10.0, fontColor: UIColor.blueColor());
        let fontSize:CGSize = strCoorNumber.sizeWithAttributes(fontAttrDic);
        if(isUp){
            strCoorNumber.drawAtPoint(CGPointMake(screenCoorPoint.x + 1.0, screenCoorPoint.y - fontSize.height), withAttributes: fontAttrDic);
        }else{
            strCoorNumber.drawAtPoint(CGPointMake(screenCoorPoint.x + 1.0, screenCoorPoint.y ), withAttributes: fontAttrDic);
        }
        CGContextRestoreGState(context);
    }
    
    private func drawBarChartCursorLine(point:CGPoint){
        //画条形图游标线
        if(point.x == 0.0 || point.y == 0.0){return;}
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor);
        var points:[CGPoint] = [];
        points.append(CGPointMake(KPading,point.y));
        points.append(CGPointMake(self.frame.size.width - KPading,point.y));
        CGContextAddLines(context, points, Int(points.count));
        CGContextStrokePath(context);
        points.removeAll(keepCapacity: false);
        CGContextRestoreGState(context);
        
        //画游标标示
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
        let y:CGFloat = (self.frame.size.height - point.y - KPading) / yCoorRatio;
        let strYScale:NSString = NSString(format: "%.2f", Float(y));
        var fontAttrDic:[NSObject:AnyObject] = getFontAttr(16.0, fontColor: UIColor.blueColor());
        let strYScaleSize:CGSize = strYScale.sizeWithAttributes(fontAttrDic);
        strYScale.drawAtPoint(CGPointMake(KPading + xScaleValid + strYScaleSize.width / 2.0, point.y - strYScaleSize.height / 2.0), withAttributes: fontAttrDic);
        CGContextRestoreGState(context);
    }
    
    private func drawCrossLine(point:CGPoint){
        //画十字线
        if(point.y == 0.0 || point.x == 0.0) {return;}
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor);
        var points:[CGPoint] = [];
        points.append(CGPointMake(KPading, point.y));
        points.append(CGPointMake(self.frame.size.width - KPading, point.y));
        CGContextAddLines(context, points, Int(points.count));
        
        points.removeAll(keepCapacity: false);
        points.append(CGPointMake(point.x, self.frame.size.height - KPading));
        points.append(CGPointMake(point.x, KPading));
        CGContextAddLines(context, points, Int(points.count));
        CGContextDrawPath(context, kCGPathStroke);
        CGContextRestoreGState(context);
        
        if(point.x >= KPading){
            drawSolidDot(point, radius: 3.0);
            //画动态提示标示
            CGContextSaveGState(context);
            CGContextSetLineWidth(context, 1.0);
            var x:CGFloat = (point.x - KPading) / xCoorRatio;
            var y:CGFloat = (self.frame.size.height - point.y - KPading) / yCoorRatio;
            let strXScale:NSString = NSString(format: "%.2f", Float(x));
            let strYScale:NSString = NSString(format: "%.2f", Float(y));
            var fontAttrDic:[NSObject:AnyObject] = getFontAttr(16.0, fontColor: UIColor.blueColor());
            let strXScaleSize:CGSize = strXScale.sizeWithAttributes(fontAttrDic);
            strXScale.drawAtPoint(CGPointMake(point.x - strXScaleSize.width / 2.0, KPading - strXScaleSize.height), withAttributes: fontAttrDic);
            let strYScaleSize:CGSize = strYScale.sizeWithAttributes(fontAttrDic);
            strYScale.drawAtPoint(CGPointMake(KPading + xScaleValid + strYScaleSize.width / 2.0, point.y - strYScaleSize.height / 2.0), withAttributes: fontAttrDic);
            CGContextRestoreGState(context);
        }
    
    }
    
    private func drawCoordinate(rect: CGRect){
        //画坐标系
        let context:CGContext = UIGraphicsGetCurrentContext();
        c = context;
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor);
        
        CGContextMoveToPoint(context, KPading, rect.size.height - KPading);
        CGContextAddLineToPoint(context, rect.size.width - KPading, rect.size.height - KPading);
        CGContextAddLineToPoint(context, rect.size.width - KPading - KArrowHeight, rect.size.height - KPading - KArrowHeight);
        CGContextMoveToPoint(context, rect.size.width - KPading, rect.size.height - KPading);
        CGContextAddLineToPoint(context, rect.size.width - KPading - KArrowHeight, rect.size.height - KPading + KArrowHeight);
        
        CGContextMoveToPoint(context, KPading, rect.size.height - KPading);
        CGContextAddLineToPoint(context, KPading, KPading);
        CGContextAddLineToPoint(context, KPading - KArrowHeight, KPading + KArrowHeight);
        CGContextMoveToPoint(context, KPading, KPading);
        CGContextAddLineToPoint(context, KPading + KArrowHeight, KPading + KArrowHeight);
        
        
        let xScaleNumber = Int(xMaxScale / xScaleUnit);
        let yScaleNumber = Int(yMaxScale / yScaleUnit);
        xScaleValid = rect.size.width - 2 * KPading - KScalePading;
        xScaleWidth = xScaleValid / CGFloat(xScaleNumber);
        yScaleValid = rect.size.height - 2 * KPading - KScalePading;
        yScaleWidth = yScaleValid / CGFloat(yScaleNumber);
        
        xCoorRatio = xScaleWidth / CGFloat(xScaleUnit);
        yCoorRatio = yScaleWidth / CGFloat(yScaleUnit);
        
        //画单位
        drawXYCoorUnit();
        
        //画坐标系刻度
        let xSubScaleWidth:CGFloat = xScaleWidth / CGFloat(subUnitScaleNumber);
        var points:[CGPoint] = [];
        for(var i = 0;i < xScaleNumber;i++){
            if(chartStyle == WHCChartStyle.LINE_CHART){
                for (var j = 0;j < subUnitScaleNumber;j++){
                    points.removeAll(keepCapacity: false);
                    points.append(CGPointMake(xSubScaleWidth * CGFloat(j) + KPading + CGFloat(i) * xScaleWidth, rect.size.height - KPading));
                    points.append(CGPointMake(xSubScaleWidth * CGFloat(j) + KPading + CGFloat(i) * xScaleWidth, rect.size.height - KPading - KSubScaleUnitHeight));
                    CGContextAddLines(context, points, Int(points.count));
                }
            }
            points.removeAll(keepCapacity: false);
            points.append(CGPointMake(xScaleWidth * CGFloat(i + 1) + KPading, rect.size.height - KPading));
            points.append(CGPointMake(xScaleWidth * CGFloat(i + 1) + KPading, rect.size.height - KPading - KScaleUnitHeight));
            CGContextAddLines(context, points, Int(points.count));
            if(chartStyle == WHCChartStyle.LINE_CHART){
                let strScaleNumber:NSString = String((i + 1) * Int(xScaleUnit));
                var fontAttrDic:[NSObject:AnyObject] = getFontAttr(10.0, fontColor: UIColor.redColor());
                let strScaleNumberSize:CGSize = strScaleNumber.sizeWithAttributes(fontAttrDic);
                strScaleNumber.drawAtPoint(CGPointMake(xScaleWidth * CGFloat(i + 1) + KPading - strScaleNumberSize.width / 2.0, rect.size.height - KPading), withAttributes: fontAttrDic);
            }else if(chartStyle == WHCChartStyle.BAR_CHART){
                if(i < barChartNames.count){
                    let strUnitName:NSString = barChartNames[i].allKeys[0] as! NSString;
                    let fontAttrDic:[NSObject:AnyObject] = getFontAttr(10.0, fontColor: UIColor.redColor());
                    let strUnitNameSize:CGSize = strUnitName.sizeWithAttributes(fontAttrDic);
                    strUnitName.drawAtPoint(CGPointMake(xScaleWidth / 2.0  + xScaleWidth * CGFloat(i) + KPading - strUnitNameSize.width / 2.0, rect.size.height - KPading), withAttributes: fontAttrDic);
                }
            }
        }
        
        let ySubScaleHeight:CGFloat = yScaleWidth / CGFloat(subUnitScaleNumber);
        for(var i = 0;i < yScaleNumber;i++){
            for(var j = 0;j < subUnitScaleNumber;j++){
                points.removeAll(keepCapacity: false);
                points.append(CGPointMake(KPading, rect.size.height - KPading - (ySubScaleHeight * CGFloat(j) + CGFloat(i) * yScaleWidth)));
                points.append(CGPointMake(KPading + KSubScaleUnitHeight, rect.size.height - KPading - (ySubScaleHeight * CGFloat(j) + CGFloat(i) * yScaleWidth)));
                CGContextAddLines(context, points, Int(points.count));
            }
            points.removeAll(keepCapacity: false);
            points.append(CGPointMake(KPading, rect.size.height - KPading - (yScaleWidth * CGFloat(i + 1))));
            points.append(CGPointMake(KPading + KScaleUnitHeight, rect.size.height - KPading - (yScaleWidth * CGFloat(i + 1))));
            CGContextAddLines(context, points, Int(points.count));
            
            let strScaleNumber:NSString = String((i + 1) * Int(yScaleUnit));
            var fontAttrDic:[NSObject:AnyObject] = [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 10.0)!,NSForegroundColorAttributeName:UIColor.redColor()];
            let strScaleNumberSize:CGSize = strScaleNumber.sizeWithAttributes(fontAttrDic);
            strScaleNumber.drawAtPoint(CGPointMake(KPading -  strScaleNumberSize.width - 2.0, rect.size.height - KPading - (yScaleWidth * CGFloat(i + 1)) - strScaleNumberSize.height / 2.0), withAttributes: fontAttrDic);
        }
        
        CGContextDrawPath(context, kCGPathStroke);
        CGContextRestoreGState(context);
    }
    
    private func drawBarChart(rect: CGRect){
        drawCoordinate(rect);
        //画条形图
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor);
        CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor);
        CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
        CGContextScaleCTM(context, 1, -1);
        let barChartWidth:CGFloat = 20.0;
        for(var i = 0;i < barChartNames.count;i++){
            let rect:CGRect = CGRectMake((xScaleWidth - barChartWidth) / 2.0 + CGFloat(i) * xScaleWidth + KPading, KPading, barChartWidth, getBarChartScreenHeightWithIndex(i));
            CGContextFillRect(context, rect);
        }
        CGContextRestoreGState(context);
        
        //画条形图标示
        CGContextSaveGState(context);
        for(var i = 0;i < barChartNames.count;i++){
            let strScale:NSString = (barChartNames[i].objectForKey(barChartNames[i].allKeys[0]) as! NSNumber).stringValue;
            let fontAttrDic:[NSObject:AnyObject] = getFontAttr(10.0, fontColor: UIColor.redColor());
            let strScaleSize:CGSize = strScale.sizeWithAttributes(fontAttrDic);
            strScale.drawAtPoint(CGPointMake(xScaleWidth / 2.0  + xScaleWidth * CGFloat(i) + KPading - strScaleSize.width / 2.0, self.frame.size.height - KPading - getBarChartScreenHeightWithIndex(i) - strScaleSize.height), withAttributes: fontAttrDic);
        }
        CGContextRestoreGState(context);
        self.drawBarChartCursorLine(beginTouchPoint);
    }
    
    private func drawLineChart(rect: CGRect){
        drawCoordinate(rect);
        //画折线图
        let context:CGContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 1.0);
//        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor);
        var points:[CGPoint] = [];
        for(var i = 0;i < scaleNumbers.count - 1;i++){
            points.removeAll(keepCapacity: false);
            points.append(getScreenCoorPointWithIndex(i));
            points.append(getScreenCoorPointWithIndex(i + 1));
            CGContextAddLines(context, points, Int(points.count));
            CGContextDrawPath(context, kCGPathStroke);
        }
        CGContextRestoreGState(context);
        //画坐标点
        var strCoorDot:NSString = "";
        for(var i = 0;i < scaleNumbers.count;i++){
            let point:CGPoint = getScreenCoorPointWithIndex(i);
            drawSolidDot(point, radius: 3.0);
            drawCoorDotNumber(getActualCoorPointFromScaleNumbersWithIndex(i) , index:i);
        }
        drawCrossLine(beginTouchPoint);
    }
    
    private func drawRectWithColor(color:UIColor , rect:CGRect){
        let context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        CGContextRestoreGState(context);
    }
    
    //画字符串
    private func drawStringWidthString(string:NSString , fontSize:CGFloat , fontColor:UIColor , point:CGPoint , direction:StringDirection){
        let fontAttr = getFontAttr(fontSize, fontColor: fontColor);
        let strSize = string.sizeWithAttributes(fontAttr);
        var actualPoint = point;
        switch direction{
        case .TOP:
            actualPoint.y -= strSize.height;
            break;
        case .LEFT:
//            actualPoint.y -= strSize.height / 2.0;
            break;
        case .RIGHT:
            actualPoint.y -= strSize.height / 2.0;
            actualPoint.x -= strSize.width - 2.0;
            break;
        case .BOTTOM:
            break;
        default:
            break;
        }
        string.drawAtPoint(point, withAttributes: fontAttr);
    }
    
    //画扇形标示
    private func drawPieChartMark(){
        let radius:CGFloat = xScaleValid < yScaleValid ? xScaleValid / 2.0 : yScaleValid / 2.0;
        let x:CGFloat = radius * 2.0 + 2.0 * KPading;
        let yStart:CGFloat = CGRectGetHeight(self.frame) / 2.0 - radius;
        for(var i = 0;i < pieChartVaules.count;i++){
            let dic = pieChartVaules[i];
            let key:NSString = dic.allKeys[0] as! NSString;
            let value:NSNumber = dic.objectForKey(key) as! NSNumber;
            let drawString = NSString(format: "%@: %@%@", key,value,"%");
            let strSize = drawString.sizeWithAttributes(getFontAttr(12.0, fontColor: UIColor.redColor()));
            let point = CGPointMake(x, CGFloat(i) * (strSize.height + 10.0) + yStart);
            drawRectWithColor(pieUnitColors[i], rect: CGRectMake(point.x, point.y, 30.0, strSize.height));
            drawStringWidthString(drawString, fontSize: 12.0, fontColor: UIColor.redColor(), point: CGPointMake(point.x + 35.0 , point.y), direction: .LEFT);
        }
    }
    
    private func drawPieChart(rect: CGRect){
        //画饼图
        var affine:CGAffineTransform = CGAffineTransformIdentity;
        xScaleValid = rect.size.width - 2 * KPading;
        yScaleValid = rect.size.height - 2 * KPading;
        var startAngle:CGFloat = 0.0;
        var endAngle:CGFloat = 0.0;
        let radius:CGFloat = xScaleValid < yScaleValid ? xScaleValid / 2.0 : yScaleValid / 2.0;
        
        self.clipsToBounds = false;
        paths.removeAll(keepCapacity: false);
        animations.removeAllObjects();
        for layer in shapeLayers{
            layer.removeAllAnimations();
            layer.path = nil;
        }
        for(var i = 0 ;i < pieChartVaules.count;i++){
            var layer:CAShapeLayer!;
            if(shapeLayers.count - 1 < i){
                layer = createShapeLayer(pieUnitColors[i],lineWidth:radius);
                shapeLayers.append(layer);
                self.layer.addSublayer(layer);
            }else{
                layer = shapeLayers[i];
            }
            var pathRef:CGMutablePathRef = CGPathCreateMutable();
            let tempAngle:CGFloat = CGFloat((pieChartVaules[i].objectForKey(pieChartVaules[i].allKeys[0]) as! NSNumber).floatValue) / 100.0 * 360.0;
            let angle:CGFloat = tempAngle * CGFloat(M_PI) / 180.0;
            endAngle = startAngle + angle;
            CGPathAddArc(pathRef,&affine,radius + KPading, CGRectGetHeight(self.frame) / 2.0, radius, startAngle, endAngle, false);
            paths.append(pathRef);
            startAngle = endAngle;
            var animation:CABasicAnimation = creatreBaseAnimationWithDuration(tempAngle / 360.0 * 0.5);
            animations.addObject(animation);
        }
        index = -1;
        animationDidStop(nil, finished: true);
        drawPieChartMark();
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        index += 1;
        if(index < shapeLayers.count){
            shapeLayers[index].path = paths[index];
            shapeLayers[index].addAnimation(animations.objectAtIndex(index) as! CABasicAnimation, forKey: "strokeEndAnimation");
        }else{
            
        }
    }
    
    private func createShapeLayer(lineColor:UIColor , lineWidth:CGFloat)->CAShapeLayer{
        var layer:CAShapeLayer = CAShapeLayer(layer: self);
        layer.lineWidth = lineWidth;
        layer.strokeColor = lineColor.CGColor;
        layer.fillColor = nil;
        layer.strokeEnd = 1.0;
        layer.backgroundColor = UIColor.clearColor().CGColor;
        return layer;
    }
    
    private func creatreBaseAnimationWithDuration(duration:CGFloat)->CABasicAnimation{
        var basicAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd");
        basicAnimation.duration = CFTimeInterval(duration);
        basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        basicAnimation.fromValue = NSNumber(double: 0.0);
        basicAnimation.toValue = NSNumber(double: 1.0);
        basicAnimation.autoreverses = false;
        basicAnimation.fillMode = kCAFillModeForwards;
        basicAnimation.delegate = self;
        basicAnimation.repeatCount = 1;
        return basicAnimation;
    }
    
    override func drawRect(rect: CGRect) {
    switch(chartStyle){
    case .BAR_CHART:
        drawBarChart(rect);
        break;
    case .LINE_CHART:
        drawLineChart(rect);
        break;
    case .PIE_CHART:
        drawPieChart(rect);
        break;
    default:
        break;
    }
}

}

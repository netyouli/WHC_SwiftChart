//
//  DeveloperDetail.swift
//  SimpleTab
//
//  Created by 吴海超 on 15/1/5.
//  Copyright (c) 2015年 BurritoStudio. All rights reserved.
//

/*
*  qq:712641411
*  qq群:460122071
*  gitHub:https://github.com/netyouli
*  csdn:http://blog.csdn.net/windwhc/article/category/3117381
*/

import UIKit

class DeveloperDetail :NSObject{
    class var sharedSingle : DeveloperDetail{
        struct Static{
            static var instance : DeveloperDetail?;
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DeveloperDetail();
        }
        return Static.instance!;
    }
    // 获取屏幕宽度比例
    class var KRATIO_HEIGHT:CGFloat {
        return DeveloperDetail.KSCREEN_HEIGHT / 480.0;
    }
    // 获取屏幕高度比例
    class var KRATIO_WIDTH:CGFloat {
        return DeveloperDetail.KSCREEN_WIDTH / 320.0;
    }
    // 获取当前屏幕宽度
    class var KSCREEN_WIDTH : CGFloat{
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft , .LandscapeRight:
            return UIScreen.mainScreen().bounds.height;
        case .Portrait , .PortraitUpsideDown:
            return UIScreen.mainScreen().bounds.width;
        default:
            return 0.0;
        }
    }
    // 获取当前屏幕高度
    class var KSCREEN_HEIGHT : CGFloat{
        switch UIApplication.sharedApplication().statusBarOrientation {
        case .LandscapeLeft , .LandscapeRight:
            return UIScreen.mainScreen().bounds.width;
        case .Portrait , .PortraitUpsideDown:
            return UIScreen.mainScreen().bounds.height;
        default:
            return 0.0;
        }
    }
    // 获取当前屏幕方向
    class var KIsHoriScreen :Bool {
        var bMark:Bool = false;
        let orientation = UIDevice.currentDevice().orientation;
        if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
            bMark =  true;
        }else{
            bMark = false;
        }
        return bMark;
    }
    // 获取当前IOS系统版本号
    class var KSYSTEM_VERSION : Float{
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue;
    }
    
    // 获取当前应用的版本号
    class var KAPP_VERSION : Float {
        return (NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! NSString).floatValue;
    }
    
    // 获取当前系统时间
    class func getCurrTime(formatter:String = "MM-DD HH:mm:ss") -> String{
        let date = NSDate();
        let formatterDate = NSDateFormatter();
        formatterDate.dateFormat = formatter;
        return formatterDate.stringFromDate(date);
    }
}
// 开发中常见的UIButton 和 UILable快捷创建
extension UIButton{
    
}
extension UILabel{
    
}

//
//  Extensions.swift
//  Prova2
//
//  Created by Marcello Catelli on 07/06/14.
//  Copyright (c) 2014 Objective C srl. All rights reserved.
//

import UIKit
import Foundation

// NSObject
public extension NSObject{
    public class var nameOfClass : String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass : String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

// FileManager
public extension NSFileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
}

// UIView
public extension UIView {
    
    func addParallax(X horizontal:Float, Y vertical:Float) {
        
        let parallaxOnX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        parallaxOnX.minimumRelativeValue = -horizontal
        parallaxOnX.maximumRelativeValue = horizontal
        
        let parallaxOnY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        parallaxOnY.minimumRelativeValue = -vertical
        parallaxOnY.maximumRelativeValue = vertical
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [parallaxOnX, parallaxOnY]
        self.addMotionEffect(group)
    }
    
    func blurMyBackgroundDark(adjust b:Bool, white v:CGFloat, alpha a:CGFloat) {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let fxView = UIVisualEffectView(effect: blur)
        
        if b {
            fxView.contentView.backgroundColor = UIColor(white:v, alpha:a)
        }
        
        fxView.frame = self.bounds

        self.addSubview(fxView)
        self.sendSubviewToBack(fxView)
    }
    
    func blurMyBackgroundLight() {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let fxView = UIVisualEffectView(effect: blur)
        
        var rect = self.bounds
        rect.size.width = CGFloat(2500)
        
        fxView.frame = rect
        
        self.addSubview(fxView)
        
//        let viewsDictionary = ["view1":self,"view2":fxView]
//        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[view2]-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
//        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[view2]-|", options: NSLayoutFormatOptions.AlignAllLeading, metrics: nil, views: viewsDictionary)
//        
//        self.addConstraints(view_constraint_H)
//        self.addConstraints(view_constraint_V)
        
        self.sendSubviewToBack(fxView)
    }
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, UIScreen.mainScreen().scale)
        self.drawViewHierarchyInRect(self.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func convertRectCorrectly(rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.mainScreen().scale == 1 {
            return self.convertRect(rect, toView: view)
        } else if self == view {
            return rect
        } else {
            var rectInParent = self.convertRect(rect, toView: self.superview)
            rectInParent.origin.x /= UIScreen.mainScreen().scale
            rectInParent.origin.y /= UIScreen.mainScreen().scale
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
    }
  
    /**
     Redefines the height of the view
     
     :param: height The new value for the view's height
     */
    func setHeight(height: CGFloat) {
      
      var frame: CGRect = self.frame
      frame.size.height = height
      
      self.frame = frame
    }
    
    /**
     Redefines the width of the view
     
     :param: width The new value for the view's width
     */
    func setWidth(width: CGFloat) {
      
      var frame: CGRect = self.frame
      frame.size.width = width
      
      self.frame = frame
    }
    
    /**
     Redefines X position of the view
     
     :param: x The new x-coordinate of the view's origin point
     */
    func setX(x: CGFloat) {
      
      var frame: CGRect = self.frame
      frame.origin.x = x
      
      self.frame = frame
    }
    
    /**
     Redefines Y position of the view
     
     :param: y The new y-coordinate of the view's origin point
     */
    func setY(y: CGFloat) {
      
      var frame: CGRect = self.frame
      frame.origin.y = y
      
      self.frame = frame
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(CGColor: color)
        }
        set {
            layer.borderColor = newValue?.CGColor
        }
    }
}

// UIImage
public extension UIImage {
    func fromLandscapeToPortrait(rotate: Bool!) -> UIImage {
        let container : UIImageView = UIImageView(frame: CGRectMake(0, 0, 320, 568))
        container.contentMode = UIViewContentMode.ScaleAspectFill
        container.clipsToBounds = true
        container.image = self
        
        UIGraphicsBeginImageContextWithOptions(container.bounds.size, true, 0);
        container.drawViewHierarchyInRect(container.bounds, afterScreenUpdates: true)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if !rotate {
            return normalizedImage
        } else {
            let rotatedImage = UIImage(CGImage: normalizedImage.CGImage!, scale: 1.0, orientation: UIImageOrientation.Left)
            
            UIGraphicsBeginImageContextWithOptions(rotatedImage.size, true, 1);
            rotatedImage.drawInRect(CGRectMake(0, 0, rotatedImage.size.width, rotatedImage.size.height))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return normalizedImage
        }
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetBlendMode(context, .Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextClipToMask(context, rect, self.CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// UITableView
public extension UITableViewController {
    
    func createNoPaintBlur(effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: tableView.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .ScaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
    
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            tableView.backgroundView = packView
        } else {
            tableView.backgroundColor = UIColor.clearColor()
            tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clearColor()
        }

        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
    }
    
    func createBlur(effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            tableView.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            tableView.backgroundColor = UIColor.clearColor()
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clearColor()
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
    }
}

public extension UITableView {
    
    func createBlur(effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            self.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            self.backgroundColor = UIColor.clearColor()
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        self.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
    }
    
    func createNoPaintBlur(effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: self.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .ScaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
            
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            self.backgroundView = packView
        } else {
            self.backgroundColor = UIColor.clearColor()
            self.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
    }
}

// UITableViewRowAction
public extension UITableViewRowAction {
    
    class func rowAction2(title title: String?, titleBorderMargin:Int, font:UIFont, fontColor:UIColor, verticalMargin:CGFloat, image: UIImage, forCellHeight cellHeight: CGFloat,  backgroundColor: UIColor, handler: (UITableViewRowAction, NSIndexPath) -> Void) -> UITableViewRowAction {
        
        // clacolo titolo
        var largezzaTesto : Int = 1
        
        if let titleTest = title {
            largezzaTesto = titleTest.characters.count + (titleBorderMargin * 2)
        } else {
            largezzaTesto = titleBorderMargin
        }
        let titleSpaceString = "".stringByPaddingToLength(largezzaTesto, withString: "\u{3000}", startingAtIndex: 0)
        
        let rowAction = UITableViewRowAction(style: .Default, title: titleSpaceString, handler: handler)
        
        let larghezzaTestoConSpazio = titleSpaceString.boundingRectWithSize(CGSizeMake(CGFloat.max, cellHeight),
                                                                    options: .UsesLineFragmentOrigin,
                                                                 attributes: [NSFontAttributeName: font],
                                                                    context: nil).size.width + 30
        // calcolo grandezza
        let frameGuess: CGSize = CGSizeMake(larghezzaTestoConSpazio, cellHeight)
        
        let tripleFrame: CGSize = CGSizeMake(frameGuess.width * 2.0, frameGuess.height * 2.0)
        
        // trucco
        UIGraphicsBeginImageContextWithOptions(tripleFrame, false, UIScreen.mainScreen().scale)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        
        backgroundColor.setFill()
        CGContextFillRect(context, CGRectMake(0, 0, tripleFrame.width, tripleFrame.height))
        
        if let _ = title {
            image.drawAtPoint(CGPointMake((frameGuess.width / 2.0) - (image.size.width / 2.0),
                                          (frameGuess.height / 2.0) - image.size.height - (verticalMargin / 2.0) + 4.0))
        } else {
            image.drawAtPoint(CGPointMake( (frameGuess.width / 2.0) - (image.size.width / 2.0),
                                           (frameGuess.height / 2.0) - image.size.height / 2.0) )
        }
        
        if let titleTest = title {
            let drawnTextSize: CGSize = titleTest.boundingRectWithSize(CGSizeMake(CGFloat.max, cellHeight), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
            
            let direction : CGFloat = UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft ? -1 : 1
            
            titleTest.drawInRect(CGRectMake( ((frameGuess.width / 2.0) - (drawnTextSize.width / 2.0)) * direction, (frameGuess.height / 2.0) + (verticalMargin / 2.0) + 2.0, frameGuess.width, frameGuess.height), withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor])
        }

        rowAction.backgroundColor = UIColor(patternImage: UIGraphicsGetImageFromCurrentImageContext())
        UIGraphicsEndImageContext()
        
        return rowAction
    }
    
}

// NSDate
let componentFlags : NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.WeekdayOrdinal, NSCalendarUnit.Hour,NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Weekday, NSCalendarUnit.WeekdayOrdinal]

public extension NSDate {
    
    //Crea una data direttamente dai valori passati
    class func customDate(year ye:Int, month mo:Int, day da:Int, hour ho:Int, minute mi:Int, second se:Int) -> NSDate {
        let comps = NSDateComponents()
        comps.year = ye
        comps.month = mo
        comps.day = da
        comps.hour = ho
        comps.minute = mi
        comps.second = se
        let date = NSCalendar.currentCalendar().dateFromComponents(comps)
        return date!
    }
    
    class func customDateUInt(year ye:UInt, month mo:UInt, day da:UInt, hour ho:UInt, minute mi:UInt, second se:UInt) -> NSDate {
        let comps = NSDateComponents()
        comps.year = Int(ye)
        comps.month = Int(mo)
        comps.day = Int(da)
        comps.hour = Int(ho)
        comps.minute = Int(mi)
        comps.second = Int(se)
        let date = NSCalendar.currentCalendar().dateFromComponents(comps)
        return date!
    }
    
    class func dateOfMonthAgo() -> NSDate {
        return NSDate().dateByAddingTimeInterval(-24 * 30 * 60 * 60)
    }
    
    class func dateOfWeekAgo() -> NSDate {
        return NSDate().dateByAddingTimeInterval(-24 * 7 * 60 * 60)
    }
    
    func sameDate(ofDate ofDate:NSDate) -> Bool {
        let cal = NSCalendar.currentCalendar()
        let dif = cal.compareDate(self, toDate: ofDate, toUnitGranularity: NSCalendarUnit.Day)
        if dif == .OrderedSame {
            return true
        } else {
            return false
        }
    }
    
    class func currentCalendar() -> NSCalendar {
        
        return NSCalendar.autoupdatingCurrentCalendar()
    }
    
    func isEqualToDateIgnoringTime(aDate:NSDate) -> Bool {
        let components1 = NSDate.currentCalendar().components(componentFlags, fromDate: self)
        let components2 = NSDate.currentCalendar().components(componentFlags, fromDate: aDate)
        
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    public func plusSeconds(s: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusSeconds(s: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusMinutes(m: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusMinutes(m: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusHours(h: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusHours(h: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusDays(d: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func minusDays(d: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func plusWeeks(w: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    public func minusWeeks(w: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    public func plusMonths(m: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    public func minusMonths(m: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    public func plusYears(y: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    public func minusYears(y: UInt) -> NSDate {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> NSDate {
        let dc:NSDateComponents = NSDateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return NSCalendar.currentCalendar().dateByAddingComponents(dc, toDate: self, options: [])!
    }
    
    public func midnightUTCDate() -> NSDate {
        let dc:NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        dc.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        return NSCalendar.currentCalendar().dateFromComponents(dc)!
    }
    
    public class func secondsBetween(date1 d1:NSDate, date2 d2:NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Second, fromDate: d1, toDate: d2, options:[])
        return dc.second
    }
    
    public class func minutesBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: d1, toDate: d2, options: [])
        return dc.minute
    }
    
    public class func hoursBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: d1, toDate: d2, options: [])
        return dc.hour
    }
    
    public class func daysBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: d1, toDate: d2, options: [])
        return dc.day
    }
    
    public class func weeksBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.WeekOfYear, fromDate: d1, toDate: d2, options: [])
        return dc.weekOfYear
    }
    
    public class func monthsBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: d1, toDate: d2, options: [])
        return dc.month
    }
    
    public class func yearsBetween(date1 d1: NSDate, date2 d2: NSDate) -> Int {
        let dc = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: d1, toDate: d2, options: [])
        return dc.year
    }
    
    //MARK- Comparison Methods
    
    public func isGreaterThan(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedDescending)
    }
    
    public func isLessThan(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedAscending)
    }
    
    //MARK- Computed Properties
    
    public var day: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Day, fromDate: self))
    }
    
    public var month: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Month, fromDate: self))
    }
    
    public var year: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Year, fromDate: self))
    }
    
    public var hour: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Hour, fromDate: self))
    }
    
    public var minute: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Minute, fromDate: self))
    }
    
    public var second: UInt {
        return UInt(NSCalendar.currentCalendar().component(.Second, fromDate: self))
    }
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

extension NSDate: Comparable { }

public extension UIAlertController {
    override func shouldAutorotate() -> Bool {
        return false
    }
}

public extension UIImagePickerController {
    override func shouldAutorotate() -> Bool {
        return false
    }
}

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

// metodi utili
func delay(delay:Double, closure:  ()->()) {
    
    dispatch_after(
        dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)) ), dispatch_get_main_queue(), closure)
}

func loc(localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}


//
//  Extensions.swift
//  Prova2
//
//  Created by Marcello Catelli on 07/06/16.
//  Copyright (c) 2016 Objective C srl. All rights reserved.
//

import UIKit
import Foundation

// UITextField
// decomentare questa riga per disabiltare il Paste (incolla) in TUTTI i textField di TUTTA l'App
/*
public extension UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action != #selector(NSObject.paste(_:)))
    }
}
*/

// NSObject
public extension NSObject{
    public class var nameOfClass : String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass : String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

// FileManager
public extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

// UIButton - ControlState
public extension UIControlState {
    public static var Normal: UIControlState { return [] }
}

// UIView
public extension UIView {
    
    func addParallax(X horizontal:Float, Y vertical:Float) {
        
        let parallaxOnX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        parallaxOnX.minimumRelativeValue = -horizontal
        parallaxOnX.maximumRelativeValue = horizontal
        
        let parallaxOnY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
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
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let fxView = UIVisualEffectView(effect: blur)
        
        if b {
            fxView.contentView.backgroundColor = UIColor(white:v, alpha:a)
        }
        
        fxView.frame = self.bounds

        self.addSubview(fxView)
        self.sendSubview(toBack: fxView)
    }
    
    func blurMyBackgroundLight() {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.light)
        let fxView = UIVisualEffectView(effect: blur)
        
        var rect = self.bounds
        rect.size.width = CGFloat(2500)
        
        fxView.frame = rect
        
        self.addSubview(fxView)
        
        self.sendSubview(toBack: fxView)
    }
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.drawHierarchy(in: self.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func convertRectCorrectly(_ rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.main.scale == 1 {
            return self.convert(rect, to: view)
        } else if self == view {
            return rect
        } else {
            var rectInParent = self.convert(rect, to: self.superview)
            rectInParent.origin.x /= UIScreen.main.scale
            rectInParent.origin.y /= UIScreen.main.scale
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
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
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

// UIImage
public extension UIImage {
    func fromLandscapeToPortrait(_ rotate: Bool!) -> UIImage {
        let container : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        container.contentMode = UIViewContentMode.scaleAspectFill
        container.clipsToBounds = true
        container.image = self
        
        UIGraphicsBeginImageContextWithOptions(container.bounds.size, true, 0);
        container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if !rotate {
            return normalizedImage!
        } else {
            let rotatedImage = UIImage(cgImage: (normalizedImage?.cgImage!)!, scale: 1.0, orientation: UIImageOrientation.left)
            
            UIGraphicsBeginImageContextWithOptions(rotatedImage.size, true, 1);
            rotatedImage.draw(in: CGRect(x: 0, y: 0, width: rotatedImage.size.width, height: rotatedImage.size.height))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return normalizedImage!
        }
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

// UITableView
public extension UITableViewController {
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: tableView.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
    
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            tableView.backgroundView = packView
        } else {
            tableView.backgroundColor = UIColor.clear
            tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }

        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createBlur(_ effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            tableView.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            tableView.backgroundColor = UIColor.clear
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}

public extension UITableView {
    
    func createBlur(_ effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            self.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            self.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        self.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffectStyle, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: self.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
            
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            self.backgroundView = packView
        } else {
            self.backgroundColor = UIColor.clear
            self.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}

// UITableViewRowAction
public extension UITableViewRowAction {
    
    class func rowAction2(title: String?, titleBorderMargin:Int, font:UIFont, fontColor:UIColor, verticalMargin:CGFloat, image: UIImage, forCellHeight cellHeight: CGFloat,  backgroundColor: UIColor, handler: @escaping (UITableViewRowAction, IndexPath) -> Void) -> UITableViewRowAction {
        
        // clacolo titolo
        var largezzaTesto : Int = 1
        
        if let titleTest = title {
            largezzaTesto = titleTest.characters.count + (titleBorderMargin * 2)
        } else {
            largezzaTesto = titleBorderMargin
        }
        let titleSpaceString = "".padding(toLength: largezzaTesto, withPad: "\u{3000}", startingAt: 0)
        
        let rowAction = UITableViewRowAction(style: .default, title: titleSpaceString, handler: handler)
        
        let larghezzaTestoConSpazio = titleSpaceString.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: cellHeight),
                                                                    options: .usesLineFragmentOrigin,
                                                                 attributes: [NSFontAttributeName: font],
                                                                    context: nil).size.width + 30
        // calcolo grandezza
        let frameGuess: CGSize = CGSize(width: larghezzaTestoConSpazio, height: cellHeight)
        
        let tripleFrame: CGSize = CGSize(width: frameGuess.width * 2.0, height: frameGuess.height * 2.0)
        
        // trucco
        UIGraphicsBeginImageContextWithOptions(tripleFrame, false, UIScreen.main.scale)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        backgroundColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: tripleFrame.width, height: tripleFrame.height))
        
        if let _ = title {
            image.draw(at: CGPoint(x: (frameGuess.width / 2.0) - (image.size.width / 2.0),
                                          y: (frameGuess.height / 2.0) - image.size.height - (verticalMargin / 2.0) + 4.0))
        } else {
            image.draw(at: CGPoint( x: (frameGuess.width / 2.0) - (image.size.width / 2.0),
                                           y: (frameGuess.height / 2.0) - image.size.height / 2.0) )
        }
        
        if let titleTest = title {
            let drawnTextSize: CGSize = titleTest.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: cellHeight), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size
            
            let direction : CGFloat = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? -1 : 1
            
            titleTest.draw(in: CGRect( x: ((frameGuess.width / 2.0) - (drawnTextSize.width / 2.0)) * direction, y: (frameGuess.height / 2.0) + (verticalMargin / 2.0) + 2.0, width: frameGuess.width, height: frameGuess.height), withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor])
        }

        rowAction.backgroundColor = UIColor(patternImage: UIGraphicsGetImageFromCurrentImageContext()!)
        UIGraphicsEndImageContext()
        
        return rowAction
    }
    
}

// NSDate
let componentFlags : Set<Calendar.Component>= [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.hour,Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal]

public extension Date {
    
    //Crea una data direttamente dai valori passati
    static func customDate(year ye:Int, month mo:Int, day da:Int, hour ho:Int, minute mi:Int, second se:Int) -> Date {
        var comps = DateComponents()
        comps.year = ye
        comps.month = mo
        comps.day = da
        comps.hour = ho
        comps.minute = mi
        comps.second = se
        let date = Calendar.current.date(from: comps)
        return date!
    }
    
    static func customDateUInt(year ye:UInt, month mo:UInt, day da:UInt, hour ho:UInt, minute mi:UInt, second se:UInt) -> Date {
        var comps = DateComponents()
        comps.year = Int(ye)
        comps.month = Int(mo)
        comps.day = Int(da)
        comps.hour = Int(ho)
        comps.minute = Int(mi)
        comps.second = Int(se)
        let date = Calendar.current.date(from: comps)
        return date!
    }
    
    static func dateOfMonthAgo() -> Date {
        return Date().addingTimeInterval(-24 * 30 * 60 * 60)
    }
    
    static func dateOfWeekAgo() -> Date {
        return Date().addingTimeInterval(-24 * 7 * 60 * 60)
    }
    
    func sameDate(ofDate:Date) -> Bool {
        let cal = Calendar.current
        let dif = cal.compare(self, to: ofDate, toGranularity: Calendar.Component.day)
        if dif == .orderedSame {
            return true
        } else {
            return false
        }
    }
    
    static func currentCalendar() -> Calendar {
        
        return Calendar.autoupdatingCurrent
    }
    
    func isEqualToDateIgnoringTime(_ aDate:Date) -> Bool {
        let components1 = Date.currentCalendar().dateComponents(componentFlags, from: self)
        let components2 = Date.currentCalendar().dateComponents(componentFlags, from: aDate)
        
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    public func plusSeconds(_ s: UInt) -> Date {
        return self.addComponentsToDate(seconds: Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusSeconds(_ s: UInt) -> Date {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusMinutes(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusMinutes(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func minusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    public func plusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func minusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    public func plusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    public func minusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    public func plusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    public func minusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    public func plusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    public func minusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc:DateComponents = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self, wrappingComponents: false)!
    }
    
    public func midnightUTCDate() -> Date {
        var dc:DateComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        (dc as NSDateComponents).timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: dc)!
    }
    
    public static func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.second!
    }
    
    public static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.minute!
    }
    
    public static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.hour!
    }
    
    public static func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.day!
    }
    
    public static func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.weekOfYear!
    }
    
    public static func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.month!
    }
    
    public static func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.year!
    }
    
    //MARK- Comparison Methods
    
    public func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    public func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    //MARK- Computed Properties
    
    public var day: UInt {
        return UInt(Calendar.current.component(.day, from: self))
    }
    
    public var month: UInt {
        return UInt(Calendar.current.component(.month, from: self))
    }
    
    public var year: UInt {
        return UInt(Calendar.current.component(.year, from: self))
    }
    
    public var hour: UInt {
        return UInt(Calendar.current.component(.hour, from: self))
    }
    
    public var minute: UInt {
        return UInt(Calendar.current.component(.minute, from: self))
    }
    
    public var second: UInt {
        return UInt(Calendar.current.component(.second, from: self))
    }
}

public func ==(lhs: Date, rhs: Date) -> Bool {
    let b = lhs.compare(rhs) == .orderedSame
    return b
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

public func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedDescending
}

//extension Date: Comparable { }

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
func delay(_ delay:Double, closure: @escaping ()->()) {

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        closure()
    }
    
}

func loc(_ localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}


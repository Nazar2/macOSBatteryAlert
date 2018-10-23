//
//  AppDelegate.swift
//  BatteryAlert
//
//  Created by Nazar Pallaev on 12/06/2018.
//  Copyright © 2018 Nazar Pallaev. All rights reserved.
//

import Cocoa
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, BatteryAlertProtocol, NSUserNotificationCenterDelegate, AlertVCProtocol {

    @IBOutlet weak var textFieldOutlet: NSTextField!
    @IBOutlet weak var lowerThenSliderrOutlet: NSSlider!
    @IBOutlet weak var graterThenSliderOutlet: NSSlider!
    @IBOutlet weak var lowerThenLabelOutlet: NSTextField!
    @IBOutlet weak var graterThenLabelOutlet: NSTextField!
    @IBOutlet weak var customMenuItem: NSMenuItem!
    @IBOutlet weak var customViewOutlet: NSView!
    @IBOutlet weak var stausMenu: NSMenu!
    
    @IBOutlet weak var notificationViewOutlet: NSView!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let batteryAlert = BatteryAlert()
    let popOver = NSPopover()
    
    private let windowContrtoller = NSStoryboard(name: NSStoryboard.Name.init("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("WindowController")) as! NSWindowController
    
    override func awakeFromNib() {
        statusItem.image = NSImage(named: NSImage.Name("battery"))
        statusItem.menu = stausMenu
        textFieldOutlet.stringValue = "Hello"
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        customMenuItem.view = customViewOutlet
        
        batteryAlert.delegate = self
        batteryAlert.updateBatteryInfo()
        
        NSUserNotificationCenter.default.delegate = self
        graterThenSliderOutlet.intValue = Int32(batteryAlert.alertWhenCapacityGraterThen)
        graterThenLabelOutlet.stringValue = "\(graterThenSliderOutlet.intValue)%"
        lowerThenSliderrOutlet.intValue = Int32(batteryAlert.alertWhenCapacityLowerThen)
        lowerThenLabelOutlet.stringValue = "\(lowerThenSliderrOutlet.intValue)%"
        
        windowContrtoller.window?.setContentSize(NSSize(width: 313, height: 74))
        (windowContrtoller.contentViewController as! AlertVC).delegate = self
        if let screenSize = NSScreen.main?.frame.size {
            windowContrtoller.window!.setFrameOrigin(NSPoint(x: screenSize.width, y: screenSize.height - windowContrtoller.window!.frame.height))
        }
        windowContrtoller.showWindow(self)
        
//        let popOver = NSPopover()
//        popOver.contentViewController =
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func quitClicked(_ sender: Any) {
//        showAlertWindow()
        NSApp.terminate(self)
    }
    
    @IBAction func graterThenChanged(_ sender: Any) {
        let intValue = (sender as! NSSlider).intValue
        graterThenLabelOutlet.stringValue = "\(intValue)%"
        batteryAlert.setCapacity(graterThen: Int8(intValue))
    }
    
    @IBAction func lowerThenChanged(_ sender: Any) {
        let intValue = (sender as! NSSlider).intValue
        lowerThenLabelOutlet.stringValue = "\(intValue)%"
        batteryAlert.setCapacity(lowerThen: Int8(intValue))
    }
    
    // MARK: NSUserNotificationCenterDelegate
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        center.removeDeliveredNotification(notification)
    }
    
    private func showAlertWindow() {
        (windowContrtoller.contentViewController as! AlertVC).textFieldOutlet.stringValue = "1\n2"
        if let screenSize = NSScreen.main?.frame.size {
            windowContrtoller.window!.setFrame(NSRect(x: screenSize.width - windowContrtoller.window!.frame.width, y: screenSize.height - windowContrtoller.window!.frame.height, width: windowContrtoller.window!.frame.width, height: windowContrtoller.window!.frame.height), display: true, animate: true)
        }
    }
    
    // MARK: BatteryAlertProtocol
    func batteryAlertProtocolUpdated() {
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        textFieldOutlet.stringValue = "Capacity: \(batteryAlert.currentCapacity ?? 0)% "
        if !batteryAlert.health.isEmpty {
            textFieldOutlet.stringValue += ", Health: \(batteryAlert.health)"
        }
        guard let capacity = batteryAlert.currentCapacity else {
            return
        }
        switch capacity {
        case _ where capacity >= batteryAlert.alertWhenCapacityGraterThen && batteryAlert.isCharging:
            textFieldOutlet.stringValue += "\nYou may plug out power cable"
            
            let notification = NSUserNotification()
            notification.title = "Capacity reached \(batteryAlert.alertWhenCapacityGraterThen)%"
            notification.informativeText = "Now you can remove power cable"
            NSUserNotificationCenter.default.deliver(notification)
        case _ where capacity <= batteryAlert.alertWhenCapacityLowerThen && !batteryAlert.isCharging:
            textFieldOutlet.stringValue += "\nNeed to plug in power cable"
            
            let notification = NSUserNotification()
            notification.title = "Capacity is lower then \(batteryAlert.alertWhenCapacityLowerThen)%"
            notification.informativeText = "It's time to plug in power cable"
            NSUserNotificationCenter.default.deliver(notification)
        default:
            textFieldOutlet.stringValue += "\nNothing needed to be done :)"
        }
    }
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func alertVCProtocolCloseClicked() {
        if let screenSize = NSScreen.main?.frame.size {
            windowContrtoller.window!.setFrame(NSRect(x: screenSize.width, y: screenSize.height - windowContrtoller.window!.frame.height, width: windowContrtoller.window!.frame.width, height: windowContrtoller.window!.frame.height), display: true, animate: true)
        }
    }
}

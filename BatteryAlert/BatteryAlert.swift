//
//  BatteryAlert.swift
//  BatteryAlert
//
//  Created by Nazar Pallaev on 12/06/2018.
//  Copyright © 2018 Nazar Pallaev. All rights reserved.
//

import Foundation

protocol BatteryAlertProtocol:NSObjectProtocol {
    func batteryAlertProtocolUpdated()
}

class BatteryAlert {
    private (set) var currentCapacity:Int?
    private (set) var health = ""
    private (set) var isCharging = false
    private let runLoop = CFRunLoopGetCurrent()
    var source:CFRunLoopSource?
    
    var alertWhenCapacityGraterThen:Int8 {
        get {
            return Int8(UserDefaults.standard.integer(forKey: BatteryAlert.capacityGraterThenName))
        }
    }
    var alertWhenCapacityLowerThen:Int8 {
        get {
            return Int8(UserDefaults.standard.integer(forKey: BatteryAlert.capacityLowerThenName))
        }
    }
    
    deinit {
        CFRunLoopRemoveSource(runLoop, source, CFRunLoopMode.defaultMode)
    }
    
    private static let capacityGraterThenName = "capacityGraterThen"
    private static let capacityLowerThenName = "capacityLowerThen"
    weak var delegate:BatteryAlertProtocol?
    
    init() {
        source = IOPSNotificationCreateRunLoopSource({unsafeMutablePointer in
            Unmanaged<BatteryAlert>.fromOpaque(UnsafeRawPointer(unsafeMutablePointer!)).takeUnretainedValue().updateBatteryInfo()
        }, UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())).takeRetainedValue() as CFRunLoopSource
        CFRunLoopAddSource(runLoop, source, CFRunLoopMode.defaultMode)
        
        if UserDefaults.standard.integer(forKey: BatteryAlert.capacityGraterThenName) == 0 {
            setCapacity(graterThen: 80)
        }
        if UserDefaults.standard.integer(forKey: BatteryAlert.capacityLowerThenName) == 0 {
            setCapacity(lowerThen: 20)
        }
    }
    func setCapacity(graterThen:Int8) {
        UserDefaults.standard.set(graterThen, forKey: BatteryAlert.capacityGraterThenName)
        UserDefaults.standard.synchronize()
        updateBatteryInfo()
    }
    func setCapacity(lowerThen:Int8) {
        UserDefaults.standard.set(lowerThen, forKey: BatteryAlert.capacityLowerThenName)
        UserDefaults.standard.synchronize()
        updateBatteryInfo()
    }
    func updateBatteryInfo() {
        guard let dict = (IOPSCopyPowerSourcesInfo().takeRetainedValue() as? NSArray)?.firstObject as? NSDictionary else { return }
        health = dict[kIOPSBatteryHealthKey] as? String ?? ""
        isCharging = dict[kIOPSIsChargingKey] as? Bool ?? false
        currentCapacity = dict[kIOPSCurrentCapacityKey] as? Int
        delegate?.batteryAlertProtocolUpdated()
    }
}

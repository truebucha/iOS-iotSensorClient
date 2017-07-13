//
//  Settings.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 7/13/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import Foundation

fileprivate let defaultSensorPort: Int = 8090
fileprivate let defaultSensorInApMode: Bool = true
fileprivate let defaultRequestIntervalInSec: Int = 10


// MARK: - bundle keys -

fileprivate let keySensorConnectedToRouter: String = "keySensorConnectedToRouterBool"
fileprivate let keySensorIp: String =  "keySensorIpString"
fileprivate let keySensorApIp: String =  "keySensorApIpString"
fileprivate let keySensorPort: String = "keySensorPortInt"
fileprivate let keyRequestIntervalInSec: String = "keyRequestIntervalInSecInt"

// MARK: - settings -

class Settings {

  static let shared: Settings = Settings()

  var sensorConnectedToRouter : Bool {
    get {
      let result = UserDefaults.standard.bool(forKey: keySensorConnectedToRouter)
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keySensorConnectedToRouter)
    }
  }

  var sensorIp: String? {
    get {
      if (Settings.shared.sensorConnectedToRouter) {
        return userDefinedSensorIp
      }
 
      return sensorApIp
    }
  }
  
  var userDefinedSensorIp : String? {
    get {
      let result = UserDefaults.standard.object(forKey: keySensorIp) as? String
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keySensorIp)
    }
  }
  
  private(set) var sensorApIp : String? {
    get {
      let result = UserDefaults.standard.object(forKey: keySensorApIp) as? String
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keySensorApIp)
    }
  }
  
  var sensorPort : Int {
    get {
      let result = UserDefaults.standard.integer(forKey: keySensorIp)
      guard result != 0
        else { return defaultSensorPort }
      
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keySensorIp)
    }
  }
  
  var requestIntervalInSec : Int {
    get {
      let result = UserDefaults.standard.integer(forKey: keyRequestIntervalInSec)
      guard result != 0
        else { return defaultRequestIntervalInSec }
      
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keyRequestIntervalInSec)
    }
  }
  
  func updateRouterIp() {
    let ip = SCRouter.routerIP()
    guard ip != nil
      else { return }
      
    sensorApIp = ip
  }
  
}

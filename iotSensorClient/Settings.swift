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
fileprivate let defaultRequestIntervalInSec: Int = 1

fileprivate let defaultAnalogZeroLevel: Int = 0
fileprivate let defaultCoPpmCoefficient: Float = 1


// MARK: - bundle keys -

fileprivate let keySensorConnectedToRouter: String = "keySensorConnectedToRouterBool"
fileprivate let keySensorIp: String =  "keySensorIpString"
fileprivate let keySensorApIp: String =  "keySensorApIpString"
fileprivate let keySensorPort: String = "keySensorPortInt"
fileprivate let keyRequestIntervalInSec: String = "keyRequestIntervalInSecInt"

fileprivate let keyAnalogZeroLevel: String = "keyAnalogZeroLevelInt"
fileprivate let keyCoPpmCoefficient: String = "keyCoPpmCoefficientFloat"

// MARK: - settings -

class Settings {

  // MARK: - property -
  
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
  
  var dataRequestUrl : URL? {
    get {
     let ip = sensorIp
     guard ip != nil
        else { return nil}
        
      let serverURLString = "http://" + ip! + ":" + String(sensorPort)
      let result = URL(string: serverURLString)
      return result;
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
  
   var analogZeroLevel : Int {
    get {
      let result = UserDefaults.standard.integer(forKey: keyAnalogZeroLevel)
      guard result != 0
        else { return defaultAnalogZeroLevel }
      
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keyAnalogZeroLevel)
    }
  }
  
  var coPpmCoefficient : Float {
    get {
      let result = UserDefaults.standard.float(forKey: keyCoPpmCoefficient)
      guard result != 0
        else { return defaultCoPpmCoefficient }
      
      return result
    }
    
    set {
      UserDefaults.standard.set(newValue, forKey: keyCoPpmCoefficient)
    }
  }

  // MARK: - logic -
  
  func updateRouterIp() {
    let ip = SCRouter.routerIP()
    guard ip != nil
      else { return }
      
    sensorApIp = ip
  }
  
}

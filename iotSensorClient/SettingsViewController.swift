//
//  SettingsViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 7/13/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class SettingsViewController: UIViewController {
  @IBOutlet weak var contentScrollView: UIScrollView!
  
  @IBOutlet weak var composerDataRequestUrlTitleLabel: UILabel!
  @IBOutlet weak var composerUrlValueLabel: UILabel!
  
  @IBOutlet weak var sensorAddressTitleLabel: UILabel!
  @IBOutlet weak var userDefinedIpSwitch: UISwitch!
  @IBOutlet weak var userDefinedIpLabel: UILabel!
  @IBOutlet weak var ipAddressLabel: UILabel!
  @IBOutlet weak var ipAddressField: UITextField!
  @IBOutlet weak var portLabel: UILabel!
  @IBOutlet weak var portField: UITextField!
  
  @IBOutlet weak var dataRequestTitleLabel: UILabel!
  @IBOutlet weak var urlPathLabel: UILabel!
  @IBOutlet weak var urlPathField: UITextField!
  @IBOutlet weak var timeIntervalLabel: UILabel!
  @IBOutlet weak var timeIntervalField: UITextField!
  
  @IBOutlet weak var analogZeroLabel: UILabel!
  @IBOutlet weak var analogZeroField: UITextField!
  @IBOutlet weak var coefficientCoPpmLabel: UILabel!
  @IBOutlet weak var coefficientCoPpmField: UITextField!
  @IBOutlet weak var coPpmDecimalPlacesLabel: UILabel!
  @IBOutlet weak var coPpmDecimalPlacesField: UITextField!

  
  private let disposeBag = DisposeBag()
  
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.isNavigationBarHidden = false
    
    userDefinedIpSwitch.isOn = Settings.shared.sensorConnectedToRouter
    
    userDefinedIpSwitch.rx.isOn
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
            
            Settings.shared.sensorConnectedToRouter = value
    }.disposed(by: disposeBag)
    
    composerUrlValueLabel.text = Settings.shared.dataRequestUrl?.absoluteString
    
    portField.text = String(Settings.shared.sensorPort)
    portField.rx.text
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
            
            guard let validValue = value,
                let port = Int(validValue) else {
                
                return
            }
            
            Settings.shared.sensorPort = port
        }
        .disposed(by: disposeBag)
    
    ipAddressField.text = Settings.shared.userDefinedSensorIp
    ipAddressField.rx.text
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
            
            guard let validValue = value,
                validValue.split(separator: ".").count == 4 else {
                    
                return
            }
            
            Settings.shared.userDefinedSensorIp = validValue
        }
        .disposed(by: disposeBag)
    
    urlPathField.text = Settings.shared.sensorPath
    urlPathField.rx.text
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
            
            guard let validValue = value,
                  validValue.count > 0 else {
                    
                return
            }
            
            Settings.shared.sensorPath = validValue
        }
        .disposed(by: disposeBag)
    
    timeIntervalField.text = String(Settings.shared.requestIntervalInSec)
    timeIntervalField.rx.text
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
            
            guard let validValue = value,
                let timeInterval = Int(validValue) else {
                    
                    return
            }
            
            Settings.shared.requestIntervalInSec = timeInterval
        }
        .disposed(by: disposeBag)
    
    analogZeroField.text = String(Settings.shared.analogZeroLevel)
    analogZeroField.rx.text
      .throttle(1, latest: true, scheduler: MainScheduler.instance)
      .bind { (value) in

        guard let validValue = value,
            let analogZeroLevel = Double(validValue) else {
            
            return
        }
        
        Settings.shared.analogZeroLevel = analogZeroLevel
      }
      .disposed(by: disposeBag)
    
    coefficientCoPpmField.text = String(Settings.shared.coPpmCoefficient)
    coefficientCoPpmField.rx.text
      .throttle(1, latest: true, scheduler: MainScheduler.instance)
      .bind { (value) in
        guard value != nil
          else { return }
        
        let coPpmCoefficient = Float(value!)
        
        guard coPpmCoefficient != nil
          else { return }
        
        Settings.shared.coPpmCoefficient = coPpmCoefficient!
      }
      .disposed(by: disposeBag)
    
      coPpmDecimalPlacesField.text = String(Settings.shared.coPpmDecimalPlaces)
      coPpmDecimalPlacesField.rx.text
        .throttle(1, latest: true, scheduler: MainScheduler.instance)
        .bind { (value) in
        guard value != nil
        else { return }
        
        let coPpmDecimalPlaces = Int(value!)
        
        guard coPpmDecimalPlaces != nil
            else { return }
        
        Settings.shared.coPpmDecimalPlaces = coPpmDecimalPlaces!
        }
        .disposed(by: disposeBag)
}

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    subscribeToNotifications()
    
    Settings.shared.updateRouterIp()
  }
  

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  
    unsubscribeFromAllNotifications()
  }
  
  // MARK: notifications 
  
  func subscribeToNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow),
                                           name: .UIKeyboardWillShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide),
                                           name: .UIKeyboardWillHide,
                                           object: nil)
  }
  
  func unsubscribeFromAllNotifications() {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: scroll view + keyboard logic
  
  func keyboardWillShow(notification:NSNotification){
    //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
    var userInfo = notification.userInfo!
    var keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    keyboardFrame = self.view.convert(keyboardFrame, from: nil)

    var contentInset = contentScrollView.contentInset
    contentInset.bottom = keyboardFrame.size.height + 16.0
    contentScrollView.contentInset = contentInset
  }

  func keyboardWillHide(notification:NSNotification){
    let contentInset:UIEdgeInsets = UIEdgeInsets.zero
    contentScrollView.contentInset = contentInset
  }
  
}

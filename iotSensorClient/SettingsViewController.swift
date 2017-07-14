//
//  SettingsViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 7/13/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit



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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.isNavigationBarHidden = false
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

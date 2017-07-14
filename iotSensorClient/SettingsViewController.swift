//
//  SettingsViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 7/13/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController {
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
      // Do any additional setup after loading the view, typically from a nib
    self.navigationController?.isNavigationBarHidden = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Settings.shared.updateRouterIp()
  }
  

   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
  }
}

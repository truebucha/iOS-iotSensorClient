//
//  SettingsViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 7/13/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    Settings.shared.updateRouterIp()
  }

   override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)

  }
}

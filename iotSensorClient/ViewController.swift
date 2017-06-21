//
//  ViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 6/21/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var log: UITextView!
  @IBOutlet weak var coPpmValueLabel: UILabel!
  var timer: Timer?
  var processing: Bool { get {return timer != nil} }
  let dateFormatter = DateFormatter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        coPpmValueLabel.text = nil;
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // MARK: - public -
  
  
    @IBAction func toggleStartStop(_ sender: Any) {
      if (processing) {
        stopProcessing()
      } else {
        startProcessing()
      }
      
      updateUI()
    }
  
    @IBAction func clearLog(_ sender: Any) {
      log.text = nil
    }

    // MARK: - logic -
  
    func startProcessing() {
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (Timer) in
        self?.process()
      })
    }
  
    func stopProcessing() {
      guard timer != nil
        else { return }
      
      timer?.invalidate()
      timer = nil
    }
  
    func process() {
    
      let result = performRequest()
      let date = dateFormatter.string(from: Date())
      
      guard result != nil
        else {
          log.text = date + " request failed" + "\r\n" + log.text
          return
        }
      
      let ppm = result?["coPpm"] ?? 0.0
      let temp = result?["temp"] ?? 0.0
      let pressure = result?["pressure"] ?? 0.0
      let humidity = result?["humidity"] ?? 0.0
      
      var line = date
      line += " CO = \(ppm)"
      line += " Temp = \(temp)"
      line += " Pres = \(pressure)"
      line += " Humi = \(humidity)"
      
      log.text = line + "\r\n" + log.text
      
      coPpmValueLabel.text = String(ppm)
    }
  
    func performRequest() -> Dictionary<String, Float>? {
        let ip = SCRouter.routerIP()
        guard ip != nil
          else { return nil}
        
        let serverURLString = "http://" + ip! + ":8090"
        let url = URL(string: serverURLString)
        
        guard url != nil
          else { return nil}
        
        let data = try? NSData(contentsOf: url!) as Data
        
        guard data != nil
          else { return nil}
      
        let result = parseJSON(using: data!)
        return result
    }

    func parseJSON(using data: Data) -> Dictionary<String, Float>? {
        let result = try? JSONSerialization.jsonObject(with: data,
                                                       options: .mutableContainers)

        return result as? Dictionary<String, Float>
    }
  
    func updateUI() {
      if (processing) {
        startStopButton.setTitle("Stop", for: .normal)
      } else {
        startStopButton.setTitle("Start", for: .normal)
      }
    }
}


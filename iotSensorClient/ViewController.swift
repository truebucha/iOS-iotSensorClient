//
//  ViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 6/21/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit
import Charts



class ViewController: UIViewController {

  @IBOutlet weak var chartView: BarChartView!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var log: UITextView!
  @IBOutlet weak var coPpmValueLabel: UILabel!
  
  var dataEntries: [BarChartDataEntry] = []
  var dataEntriesCount: Int = 0
  
  var timer: Timer?
  var processing: Bool { get {return timer != nil} }
  let dateFormatter = DateFormatter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateUI()
        coPpmValueLabel.text = nil;
        chartView.noDataText = "No data."
        	
        chartView.descriptionText = ""
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      updateUI()
      prepareLogDateFormat()
      subscribeToNotifications()
    }
  
     override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromNotifications()
    }
  
    // MARK: - events -

    func dropboxDidCahngeState (notification: NSNotification) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let state = appDelegate.dropbox.state;
//        
//    
//        if state == .connected
//        || state == .reconnected {
//          
//       }
    }
  
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
      dataEntries = []
      updateChartUI()
    }
  
    @IBAction func exportLog(_ sender: Any) {
      
      let url = generateFileUrl()
      
      guard url != nil
       else { return }
     
      let data = log.text.data(using: .utf8)
      
      guard data != nil
        else { return }
      
      do {
        try data!.write(to: url!, options: .atomicWrite)
      } catch {
        print("error write to file: \(error)")
        return;
      }
      
      updalodToDropbox(from: url!)
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
      let currentDate = Date()
      let date = dateFormatter.string(from: currentDate)
      
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
      
      let dataEntry = BarChartDataEntry(x: Double(dataEntriesCount), y: Double(ppm))
      dataEntries.append(dataEntry)
      dataEntriesCount += 1
      if (dataEntries.count > 15) {
        dataEntries.remove(at: 0)
      }
      
      updateChartUI();
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
  
    func prepareLogDateFormat() {
      dateFormatter.dateFormat = "HH:mm:ss"
    }
  
    func prepareExportDateFormat() {
      dateFormatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
    }
  
    func generateFileUrl() -> URL? {
      prepareExportDateFormat()
      let date = dateFormatter.string(from: Date())
      prepareLogDateFormat()
      
      let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
      guard path != nil
        else { return nil }
      
      let fullPath = path! + "/" + date + ".txt"
      let result = URL(fileURLWithPath: fullPath)
      
      return result
    }
  
    func updalodToDropbox(from url: URL) {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let dropbox = appDelegate.dropbox
      
      guard dropbox.state == .connected
            || dropbox.state == .reconnected
        else { return }
      
      let path = "/" + url.lastPathComponent
      
     dropbox.upload(toPath: path, from: url) { [weak self] (error) in
        self?.showSuccedAler(message: "Uploaded to " + path)
      }
    }
  
    // MARK: notifications
  
    private func subscribeToNotifications () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.dropboxDidCahngeState(notification:)),
                                               name: NSNotification.Name(rawValue: appDelegate.dropboxStateChangedNotification),
                                               object: appDelegate)
    }
    
    private func unsubscribeFromNotifications () {
        NotificationCenter.default.removeObserver(self)
    }
  
    // MARK: show alert
  
    func showSuccedAler(message: String) {
      let alert = UIAlertController(title: "Succeed", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  
    func updateChartUI() {
      let chartDataSet = BarChartDataSet(values: dataEntries, label: "CO ppm")
      let chartData = BarChartData(dataSet: chartDataSet)
      chartView.data = chartData
    }
}


//
//  ViewController.swift
//  iotSensorClient
//
//  Created by Bucha Kanstantsin on 6/21/17.
//  Copyright © 2017 BuchaBros. All rights reserved.
//

import UIKit
import Charts


typealias responseType = Dictionary<String, Float>?

fileprivate let maxDisplayableEntriesCount: Int = 15;


class ViewController: UIViewController {

  @IBOutlet weak var chartView: BarChartView!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var log: UITextView!
  @IBOutlet weak var coPpmValueLabel: UILabel!
  
  private var dataEntries: [BarChartDataEntry] = []
  private var dataEntriesCount: Int = 0
  
  private var timer: Timer?
  private var processing: Bool { get {return timer != nil} }
  private let dateFormatter = DateFormatter()
  
  private var requestingData: Bool = false
  
    override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view, typically from a nib.
      updateUI()
      coPpmValueLabel.text = nil
      chartView.noDataText = "No data."
        
      chartView.chartDescription = nil
    
      navigationItem.title = "Session"
      
      navigationController?.isNavigationBarHidden = true
    }
  
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      updateUI()
      prepareLogDateFormat()
      subscribeToNotifications()
      
      Settings.shared.updateRouterIp()
      
      navigationController?.isNavigationBarHidden = true
    }
  
     override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromNotifications()
    }
  
    // MARK: - handle events -

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
  
    func performSettingsSegue() {
      performSegue(withIdentifier: "Settings", sender: self)
    }

    // MARK: - logic -
  
    func startProcessing() {
      let interval = TimeInterval(Settings.shared.requestIntervalInSec)
      timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] (Timer) in
        self?.requestData()
      })
      
      self.requestData()
    }
  
    func stopProcessing() {
      guard timer != nil
        else { return }
      
      timer?.invalidate()
      timer = nil
    }
  
    func requestData() {
      guard requestingData == false
        else { return }
      
      requestingData = true
      let url = Settings.shared.dataRequestUrl
      
      DispatchQueue.global(qos: .default).async { [weak self] in
        let result = self?.performRequest(url)
        DispatchQueue.main.async {
          self?.requestingData = false
          self?.processResponse(result)
        }
      }
    }
  
    func processResponse(_ response: responseType) {
      let currentDate = Date()
      let date = dateFormatter.string(from: currentDate)
      
      guard response != nil
        else {
          log.text = date + " request failed" + "\r\n" + log.text
          return
        }
      
      let ppm = response?["coPpm"] ?? 0.0
      let temp = response?["temp"] ?? 0.0
      let pressure = response?["pressure"] ?? 0.0
      let humidity = response?["humidity"] ?? 0.0
      
      var line = date
      line += " CO = \(ppm)"
      line += " Temp = \(temp)"
      line += " Pres = \(pressure)"
      line += " Humi = \(humidity)"
      
      log.text = line + "\r\n" + log.text
      
      coPpmValueLabel.text = "CO " + String(ppm) + " ppm"
      
      let dataEntry = BarChartDataEntry(x: Double(dataEntriesCount), y: Double(ppm))
      dataEntries.append(dataEntry)
      dataEntriesCount += 1
      if (dataEntries.count > maxDisplayableEntriesCount) {
        dataEntries.remove(at: 0)
      }
      
      updateChartUI();
    }
  
    func performRequest(_ url: URL?) -> responseType {
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
  
    func updalodToDropbox(from url: URL, couldRepeat: Bool = true) {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let dropbox = appDelegate.dropbox
      
      guard dropbox.state == .connected
            || dropbox.state == .reconnected
        else {
          if (couldRepeat) {
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 1.5) { [weak self] in
              self?.updalodToDropbox(from: url, couldRepeat: false)
            }
          } else {
            showFailedAler(message: "Failed upload to dropbox. No dropbox connected.")
          }
          return
        }
      
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
  
    func showFailedAler(message: String) {
      let alert = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
  
    func updateChartUI() {
      let chartDataSet = BarChartDataSet(values: dataEntries, label: "CO ppm")
      let chartData = BarChartData(dataSet: chartDataSet)
      chartView.data = chartData
    }
}


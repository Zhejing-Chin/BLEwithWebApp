//
//  ViewController.swift
//  Jaspat Online Restaurant
//
//  Created by Gogain Chin on 05/07/2020.
//  Copyright © 2020 Gogain Chin. All rights reserved.
//

import CoreBluetooth
import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIPopoverPresentationControllerDelegate {

    var website = "http://thaiphp.ganoexcel.com/index.php"
    var device: CBPeripheral!
    var characteristic: CBCharacteristic!
    var deviceReady: Bool!
    let ble = BLEPrinterService()
  
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var printerButton: UIBarButtonItem!
        
    @IBOutlet var webPage: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webPage.navigationDelegate = self
        webPage.uiDelegate = self
        
        webPage.load(URLRequest(url: URL(string: website)!))
        view.addSubview(webPage)
        backButton.isEnabled = false
        backButton.tintColor = UIColor.clear
//        printerButton.isEnabled = false
//        printerButton.tintColor = UIColor.clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "print" {
            if let view = segue.destination as? SecondViewController {
                view.popoverPresentationController?.delegate = self
                view.preferredContentSize = CGSize(width: 160, height: 100)
//                view.delegate = self
                view.deviceToConnect = device
                view.char = characteristic
            }
        }
    }
    
//    second view controller will appear as a pop over.
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK:- Button func
    @IBAction func backTapped(_ sender: Any) {
        if(self.webPage.canGoBack) {
         self.webPage.goBack()
        }
    }
    
    @IBAction func refreshTapped(_ sender: Any) {
        self.webPage.reload()
    }
    
    //MARK:- Check URL
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url!.absoluteString.range(of: "index.php") != nil
        {
            backButton.isEnabled = false
            backButton.tintColor = UIColor.clear
        }
        else {
            backButton.isEnabled = true
            backButton.tintColor = nil
        }
        
//        if webView.url!.absoluteString.range(of: "Print") != nil
//        {
//            printerButton.isEnabled = true
//            printerButton.tintColor = nil
//        }
//        else {
//            printerButton.isEnabled = false
//            printerButton.tintColor = UIColor.clear
//        }
    }
    
    //MARK:- WKUIDelegate
    //open up print preview page
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            view.addSubview(webView)
            
            printerButton.isEnabled = true
            
            let script = WKUserScript(source: "window.print = function(){ window.webkit.messageHandlers.print.postMessage('print') }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
            configuration.userContentController.removeScriptMessageHandler(forName: "print")
            configuration.userContentController.addUserScript(script)
            configuration.userContentController.add(self, name: "print")
            debugPrint(navigationAction.request)
        }
        
        return nil
    }
   
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "print" {
            debugPrint(message.name)
            printCurrentPage()
//            self.webPage.goBack()
        }
        else {
            debugPrint(message.name)
        }
    }

    //MARK:- Print
    func printCurrentPage() {
        device = BLE.sharedInstance.deviceToConnect
        characteristic = BLE.sharedInstance.char
        deviceReady = BLE.sharedInstance.deviceReady
        print("Peripheral info: \(String(describing: device))")
        printLine(line: "Jaspat Online Restaurant")
        
    }
    
    func printLine(line: String) {
        if !deviceReady {
            return
        }
        
        let lineFeed = ble.hexToNSData(string: "0A")
        let printer  = device!
        
        printer.writeValue(line.data(using: String.Encoding.utf8)!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        
        printer.writeValue(lineFeed as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }

}

//extension ViewController: PassDataDelegate {
//    func passPeripheral(_ device: CBPeripheral!) {
//        self.device = device
//    }
//
//    func passCharacteristic(_ characteristic: CBCharacteristic!) {
//        self.characteristic = characteristic
//        self.deviceReady = true
//    }
//}

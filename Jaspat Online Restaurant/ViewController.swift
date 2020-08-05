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

    static var vc: ViewController?
    var website = "http://thaiphp.ganoexcel.com/index.php"
    var centralManager: CBCentralManager!
    var deviceToConnect: CBPeripheral!
    var char: CBCharacteristic!
    var deviceReady: Bool!
  
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var printerButton: UIBarButtonItem!
        
    @IBOutlet var webPage: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.vc = self
        
        webPage.navigationDelegate = self
        webPage.uiDelegate = self
        
        webPage.load(URLRequest(url: URL(string: website)!))
        view.addSubview(webPage)
        backButton.isEnabled = false
        backButton.tintColor = UIColor.clear
//        printerButton.isEnabled = false
//        printerButton.tintColor = UIColor.clear
    }
    
    func setCB(centralManager: CBCentralManager, deviceToConnect: CBPeripheral, char: CBCharacteristic, deviceReady: Bool) {
        self.centralManager = centralManager
        self.deviceToConnect = deviceToConnect
        self.char = char
        self.deviceReady = deviceReady
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "print" {
            if let view = segue.destination as? SecondViewController {
                view.popoverPresentationController?.delegate = self
                view.preferredContentSize = CGSize(width: 160, height: 100)
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

    // MARK:- Convert Hext to NSData
    func hexToNSData(string: String) -> NSData {
        let length = string.count
        
        
        let rawData = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: length/2)
        var rawIndex = 0
        
        for index in stride(from: 0, to: length, by: 2){
            let single = NSMutableString()
            let startIndex = string.index(string.startIndex, offsetBy: index)
            let endIndex = string.index(string.startIndex, offsetBy: index+2)
            single.append(String(string[startIndex..<endIndex]))
            rawData[rawIndex] = UInt8(single as String, radix:16)!
            rawIndex+=1
        }
        
        let data:NSData = NSData(bytes: rawData, length: length/2)
        rawData.deallocate()
        
        return data
    }
    
    //MARK:- Print
    func printCurrentPage() {
        
        print("Peripheral info: \(String(describing: deviceToConnect))")
        printLine(line: "Jaspat Online Restaurant")
        self.webPage.goBack()
    }
    
    func printLine(line: String) {
        if !deviceReady {
            return
        }
        
        let lineFeed = hexToNSData(string: "0A")
        let printer  = deviceToConnect!
        
        printer.writeValue(line.data(using: String.Encoding.utf8)!, for: char, type: CBCharacteristicWriteType.withResponse)
        
        printer.writeValue(lineFeed as Data, for: char, type: CBCharacteristicWriteType.withResponse)
    }

}

//
//  BLEPrinterService.swift
//  Jaspat Online Restaurant
//
//  Created by Gogain Chin on 12/07/2020.
//  Copyright © 2020 Gogain Chin. All rights reserved.
//

import Foundation
import CoreBluetooth
//import BluetoothKit

class BLEPrinterService : BKPeripheralDelegate, BKCentralDelegate, BKAvailabilityObserver, BKRemotePeripheralDelegate, BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        // debugPrint("REMOTE DATA")
        // debugPrint(remotePeripheral)
        // debugPrint(data)
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
//        debugPrint("CONNECT")
//        debugPrint(peripheral)
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
//        debugPrint("DISCONNECT")
//        debugPrint(peripheral)
    }
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
//        debugPrint("CENTRAL")
//        debugPrint(central)
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
//        debugPrint("AVAILABLE - 1")
//        // scan auto starts on availability of the bluetooth device
//        scan()
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
//        debugPrint("AVAILABLE - 2")
//        // scan auto starts on availability of the bluetooth device
//        scan()
    }
    
    func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        // debugPrint("NAME CHANGE \(name)")
    }
    
    func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        
    }
    
 
     let peripheral = BKPeripheral()
     let central = BKCentral()

    
     // The UUID for the white lable BLE printer, obtained using LighBlue app.
     // The same may be obtained using any other Bluetooth explorer app.
        var serviceUUID = NSUUID(uuidString: "E7810A71-73AE-499D-8C15-FAA9AEF0C3fF")
        //49535343-FE7D-4AE5-8FA9-9FAFD205E455
        var characteristicUUID = NSUUID(uuidString: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
//    15120B24-6838-47C1-2FF4-F5023AEBFE9B

     var deviceReady = false
     
     var connectedDevice:BKRemotePeripheral?
     
     internal init() {
         self.initCentral()
     }

     // set a new service UUID, need to call initCentral() after this
     func setServiceUUID(suid: NSUUID) {
         self.serviceUUID = suid
     }
     
     // set a new characteristic UUID, need to call initCentral() after this
     func setCharacteristicUUID(cuid: NSUUID) {
         self.characteristicUUID = cuid
     }
     
     func isDeviceReady() -> Bool {
         return self.deviceReady
     }
     
     func initCentral() {
         do {
             central.delegate = self;
             central.addAvailabilityObserver(self)
             
            
             let configuration = BKConfiguration(dataServiceUUID: serviceUUID! as UUID, dataServiceCharacteristicUUID: characteristicUUID! as UUID)
             try central.startWithConfiguration(configuration)
         } catch let error {
             debugPrint("ERROR - initCentral")
             debugPrint(error)
         }
     }
    
    // helper function to convert a hext string to NSData
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
    
    func printLine(line: String) {
        if !self.deviceReady {
            return
        }
        
        let lineFeed = self.hexToNSData(string: "0A")
        let printer  = self.connectedDevice!.getPeripheral()!
        
        printer.writeValue(line.data(using: String.Encoding.utf8)!, for: self.connectedDevice!.getCharacteristic()!, type: CBCharacteristicWriteType.withResponse)
        
        printer.writeValue(lineFeed as Data, for: self.connectedDevice!.getCharacteristic()!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func printToBuffer(line: String) {
        if !self.deviceReady {
            return
        }
        
        let printer  = self.connectedDevice!.getPeripheral()!
        
        printer.writeValue(line.data(using: String.Encoding.utf8)!, for: self.connectedDevice!.getCharacteristic()!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func printTab() {
        if !self.deviceReady {
            return
        }
        
        let tabFeed = self.hexToNSData(string: "09")
        let printer  = self.connectedDevice!.getPeripheral()!
        
        printer.writeValue(tabFeed as Data, for: self.connectedDevice!.getCharacteristic()!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func printLineFeed() {
        if !self.deviceReady {
            return
        }
        
        let lineFeed = self.hexToNSData(string: "0A")
        let printer  = self.connectedDevice!.getPeripheral()!
        
        printer.writeValue(lineFeed as Data, for: self.connectedDevice!.getCharacteristic()!, type: CBCharacteristicWriteType.withResponse)
    }
    
    // actual scan function
    func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
                debugPrint("Discovery List")
                debugPrint(discoveries)
                // assume that the first discovery is the printer we desire to connect,
                // in ideal world this is true, but in reality you may have additional checks to make
                if let firstPrinter =  discoveries.first {
                    if (self.connectedDevice != firstPrinter.remotePeripheral)  {
                        // if we are not already connected, connect to the printer device
                        self.central.connect(30, remotePeripheral: firstPrinter.remotePeripheral) { remotePeripheral, error in
                            if error == nil {
                                self.deviceReady = false; self.connectedDevice = nil;
                                debugPrint("Connection DONE")
                                debugPrint(remotePeripheral)
                                debugPrint(error ?? "default error")
                            
                                remotePeripheral.delegate = self
                            
                                if remotePeripheral.state == BKRemotePeripheral.State.connected {
                                    debugPrint("REMOTE connected")
                                    
                                    debugPrint(remotePeripheral.identifier)
                                    debugPrint(remotePeripheral.getConfiguration() ?? "default remoteperipheral")
                                    
                                    // once connected, set appropriate flags
                                    self.deviceReady = true
                                    self.connectedDevice = firstPrinter.remotePeripheral
                                }
                            }
                        }
                    }
                } else if discoveries.count == 0 && self.connectedDevice != nil {
                    self.deviceReady = true
                    // debugPrint("WRITING")
                    // self.printLine("OneGreenDiary")
                    // debugPrint("DONE WRITING")
                }
            }, stateHandler: { newState in
                if newState == .scanning {
                    debugPrint("Scanning")
                } else if newState == .stopped {
                    debugPrint("Stopped")
                }
            }, duration: 5, inBetweenDelay: 10, errorHandler: { error in
                debugPrint("ERROR - scan")
                debugPrint(error)
            })
    }
    
    // helper functions
    var CHARS_PER_LINE = 30
    
    func centerText(text: String, spaceChar: NSString = " ") -> String {
        let nChars = text.count
        
        // debugPrint(String(format: "Item%22s%3s", " ".cStringUsingEncoding(NSASCIIStringEncoding), "Qty".cStringUsingEncoding(NSASCIIStringEncoding)))
        
        if nChars >= CHARS_PER_LINE {
            let endIndex = text.index(text.startIndex, offsetBy: CHARS_PER_LINE)
            return String(text[..<endIndex])
        } else {
            let totalSpaces = CHARS_PER_LINE - nChars
            let spacesOnEachSide = totalSpaces / 2
            let spacesString = "%\(spacesOnEachSide)s"
            
            let centeredString = String(format: spacesString + text + spacesString, spaceChar.cString(using: String.Encoding.ascii.rawValue)!, spaceChar.cString(using: String.Encoding.ascii.rawValue)!)
            
            return centeredString
        }
    }
    
    func rowText(colText: [String], colWidth: [Int], padSpace: [String], spaceChar: NSString = " ") -> String {
        let nCols = colText.count
        
        if nCols != colWidth.count {
            return ""
        }
        
        if nCols != padSpace.count {
            return ""
        }
        
        let totalColWidth = colWidth.reduce(0, +)
        
        if totalColWidth > CHARS_PER_LINE {
            return ""
        }
        
        var rowLine = ""
        
        for cidx in 0..<nCols{
            let ct = colText[cidx]
            let cw = colWidth[cidx]
            let ctw = ct.count
            
            if ctw > cw {
                // simply truncate text to fit
                let endIndex = ct.index(ct.startIndex, offsetBy: cw+1)
                let cutText = String(ct[..<endIndex])
                rowLine += cutText
            } else {
                let totalSpaces = cw - ctw + 1
                var spacesString = "%\(totalSpaces)s"
                
                // this is normally padded right, left aligned
                if padSpace[cidx] == "R" {
                    let colLineText = String(format: ct + spacesString, spaceChar.cString(using: String.Encoding.ascii.rawValue)!)
                    rowLine += colLineText
                } else if padSpace[cidx] == "L" {
                    let colLineText = String(format: spacesString + ct, spaceChar.cString(using: String.Encoding.ascii.rawValue)!)
                    rowLine += colLineText
                } else if padSpace[cidx] == "C" {
                    let spacesOnEachSide = totalSpaces / 2
                    spacesString = "%\(spacesOnEachSide)s"
                    
                    let colLineText = String(format: spacesString + ct + spacesString, spaceChar.cString(using: String.Encoding.ascii.rawValue)!, spaceChar.cString(using: String.Encoding.ascii.rawValue)!)
                    rowLine += colLineText
                }
            }
        }
        
        return rowLine
    }

}

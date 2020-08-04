//
//  CB.swift
//  Jaspat Online Restaurant
//
//  Created by Zhe Jing on 04/08/2020.
//  Copyright © 2020 Gogain Chin. All rights reserved.
//

import Foundation
import CoreBluetooth

class CB {
    static var cb: CB?
    let centralManager: CBCentralManager
    let deviceToConnect: CBPeripheral
    let char: CBCharacteristic
    let deviceReady: Bool
    
    init(centralManager: CBCentralManager, deviceToConnect: CBPeripheral, char: CBCharacteristic, deviceReady: Bool) {
        self.centralManager = centralManager
        self.deviceToConnect = deviceToConnect
        self.char = char
        self.deviceReady = deviceReady
        CB.cb = self
    }
    
    func getCM() -> CBCentralManager {
        return centralManager
    }
    
    func getDTC() -> CBPeripheral {
        return deviceToConnect
    }
    
    func getC() -> CBCharacteristic {
        return char
    }
    
    func getDR() -> Bool {
        return deviceReady
    }
}

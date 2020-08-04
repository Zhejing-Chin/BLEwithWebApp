//
//  SecondViewController.swift
//  Jaspat Online Restaurant
//
//  Created by Gogain Chin on 13/07/2020.
//  Copyright © 2020 Gogain Chin. All rights reserved.
//

import CoreBluetooth
import UIKit

class SecondViewController: UIViewController, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var peripherals = Array<CBPeripheral>()
    var deviceToConnect: CBPeripheral!
    var char: CBCharacteristic!
    var deviceReady = false
     
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }
    
    func connectToDevice () {
        centralManager?.connect(deviceToConnect!, options: nil)
    }
}
     
extension SecondViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state{
        case .poweredOn:
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
            print("Searching")

        case .poweredOff:
            print("Central State PoweredOFF")

        case .resetting:
            print("Central State Resetting")

        case .unauthorized:
            print("Central State Unauthorized")

        case .unknown:
            print("Central State Unknown")

        case .unsupported:
            print("Central State Unsupported")

        default:
            print("Central State None Of The Above")

        }
    }
     
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) && peripheral.name != nil {
            peripherals.append(peripheral)
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        print("Scan Stopped")
        print("Peripheral info: \(String(describing: deviceToConnect))")
        deviceReady = true
        
        //Discovery callback
        deviceToConnect!.delegate = self
        deviceToConnect?.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
//            2AF1 had property WriteWithoutResponse
//            BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F had properties Read+Write+Notify+Indicate
            //looks for the right characteristic
            if characteristic.uuid.isEqual(CBUUID(string: "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"))  {
                self.char = characteristic
                if let controller = ViewController.vc {
                    controller.setCB(centralManager: centralManager, deviceToConnect: deviceToConnect, char: char, deviceReady: deviceReady)
                }
                self.dismiss(animated: false, completion: nil)
                break
            }
        }
    }
}
  
extension SecondViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deviceToConnect = peripherals[indexPath.row]
        print(deviceToConnect!)
        connectToDevice()
    }
}

extension SecondViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
           let peripheral = peripherals[indexPath.row]
           cell.textLabel?.text = peripheral.name
           return cell
       }
        
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return peripherals.count
   }
}



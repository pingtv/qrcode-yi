//
//  ViewController.swift
//  qrcode-yi
//
//  Created by Andres on 7/29/19.
//  Copyright © 2019 BallerTV Dev. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var wifiSourceControl: UISegmentedControl!
    @IBOutlet weak var imageQr: UIImageView!
    @IBOutlet weak var ssidTF: UITextField!
    @IBOutlet weak var psswdTF: UITextField!
    @IBOutlet weak var streamNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ssidTF.delegate = self
        psswdTF.delegate = self
        streamNameTF.delegate = self
        
        [ssidTF, psswdTF, streamNameTF].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        WifiSourceUpdate(wifiSourceControl)
        
    }
    
    // Make sure this is in the header of the objc .h file
    func updateStreamName(streamName: String) {
        streamNameTF.text = streamName
        editingChanged(streamNameTF)
    }
    
    private func showQRCode(from ssid: String, psswd: String, streamName: String) {
        // There has to be a random/unique component to the SSID so that
        // nearby iPads don't interfere with one another.
        let streamUrl = String(format:"rtmp://52.207.170.50/baller-publish/%@", streamName)
        
        // Not sure yet if order matters or not. I don't see why it would,
        // but generating a similar string from a dictionary
        // didn't scan, so for now just using string interpolation.
//        let raw = """
//        {"ssid":"\(ssid)", "pwd":"\(psswd)", "res":"480p", "rate":"0", "dur":"0", "url":"\(streamUrl)", "ak":"0", "sign":"F5PDCUCmcE2OzrAP"}
//        """
        
//        let raw = """
//        {"ssid":"\(ssid)", "pwd":"\(psswd)", "res":"480p", "rate":"0", "dur":"0", "ak":"1", "url":"\(streamUrl)", "ak":"0", "sign":"ayAtK5sK5BnxdO31"}
//        """

//        let raw = "SJ4\nBallerTV_TEAM_WIFI\nWestbrook#0\nrtmp://52.203.134.90/baller-publish/sjcam\n\(ssid)\n\(psswd)\n\(streamName)"
        
        let raw = "SJ4\n\(ssid)\n\(psswd)\n\(streamUrl)\n2\n0\n7"
        
        NSLog(raw)
        
        imageQr.image = generateQRCode(from: raw)
        imageQr.layer.magnificationFilter = CALayerContentsFilter.nearest // Nearest neighbor scaling keeps edges sharp
    }

    /// Generates an image of a QR Code given a string to encode.
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("L", forKey: "inputCorrectionLevel") // Low(est) error correction for simpler QR codes
            let transform = CGAffineTransform(scaleX: 10, y: 10) // Scale to keep high res
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func WifiSourceUpdate(_ sender: Any) {
        switch wifiSourceControl.selectedSegmentIndex {
        case 0:
            ssidTF.text = UIDevice.current.name
            psswdTF.text = "baller123"
        case 1:
            ssidTF.text = "BallerTV_TEAM_WIFI"
            psswdTF.text = "baller123"
        default:
            return
        }
        editingChanged(ssidTF)
    }
    
    
    
    
    @objc func editingChanged(_ textField: UITextField) {
        guard
            let ssid = ssidTF.text, !ssid.isEmpty,
            let psswd = psswdTF.text, !psswd.isEmpty,
            let streamName = streamNameTF.text, !streamName.isEmpty
            else {
                return
        }
        
        showQRCode(from: ssid, psswd: psswd, streamName: streamName)
    }
    
    
    
    
    // Unfortunately, it seems like though it's possible to connect to an existing
    // network, it's impossible start a hotspot programmatically. We'll have to open
    // the settings page and have them do it manually.
    // That also means all of this is useless:
    private func initHotspot() {
        let config = NEHotspotConfiguration.init(ssid: "BallerTV Streaming", passphrase: "AndresIsTheBestIntern", isWEP: false)
        
        NEHotspotConfigurationManager.shared.apply(config) { (error) in
            if (error != nil) {
                print(error.debugDescription)
            } else {
                print("success! what did we do?")
            }
        }
    }
}


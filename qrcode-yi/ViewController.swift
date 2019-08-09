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

    @IBOutlet weak var imageQr: UIImageView!
    @IBOutlet weak var ssidTF: UITextField!
    @IBOutlet weak var psswdTF: UITextField!
    @IBOutlet weak var streamNameTF: UITextField!
    @IBOutlet weak var qrButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ssidTF.delegate = self
        psswdTF.delegate = self
        streamNameTF.delegate = self
        
        ssidTF.text = UIDevice.current.name
        
        qrButton.isEnabled = false
        [ssidTF, psswdTF, streamNameTF].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
//        initHotspot()
    }
    
    private func showQRCode(from ssid: String, psswd: String, streamName: String) {
        // There has to be a random/unique component to the SSID so that
        // nearby iPads don't interfere with one another.
        let streamUrl = String(format:"rtmp://52.203.134.90/baller-publish/%@", streamName)
        
        // Not sure yet if order matters or not. I don't see why it would,
        // but generating a similar string from a dictionary
        // didn't scan, so for now just using string interpolation.
//        let raw = """
//        {"ssid":"\(ssid)", "pwd":"\(psswd)", "res":"480p", "rate":"0", "dur":"0", "url":"\(streamUrl)", "ak":"0", "sign":"F5PDCUCmcE2OzrAP"}
//        """
        
        let raw = """
        {"ssid":"\(ssid)", "pwd":"\(psswd)", "res":"480p", "rate":"0", "dur":"0", "url":"\(streamUrl)"}
        """
        
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
    
    @objc func editingChanged(_ textField: UITextField) {
        guard
            let ssid = ssidTF.text, !ssid.isEmpty,
            let psswd = psswdTF.text, !psswd.isEmpty,
            let streamName = streamNameTF.text, !streamName.isEmpty
            else {
                qrButton.isEnabled = false
                return
        }
        qrButton.isEnabled = true
    }
    
    @IBAction func qrButtonPressed(_ sender: Any) {
        let ssid = String(ssidTF.text!)
        let psswd = String(psswdTF.text!)
        let streamName = String(streamNameTF.text!)
        showQRCode(from: ssid, psswd: psswd, streamName: streamName)
        
    }
}


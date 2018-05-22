//
//  QRViewController.swift
//  phy-browser
//
//  Created by Beat Zenerino on 9/21/17.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import AVFoundation
import Vision
import UIKit
import Foundation

class QRViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, PHYEddystoneManagerDelegate {

    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var backgroundView:UIImageView!
    @IBOutlet weak var aButton:UIButton!
    @IBOutlet weak var bButton:UIButton!
    @IBOutlet weak var cButton:UIButton!

    // highlightView draws a square around the QR code, for debugging
    // uncomment drawing of the rect in handleVisionRequestResults()
    @IBOutlet private weak var highlightView: UIView? {
        didSet {
            self.highlightView?.layer.borderColor = UIColor.red.cgColor
            self.highlightView?.layer.borderWidth = 4
            self.highlightView?.backgroundColor = .clear
        }
    }

    var phyManager = PHYEddystoneManager(apiKey: "")!
    var beaconToResolve: PHYEddystoneBeacon!
    var card: CardView!
    var currentAppIdCode: UInt32!

    let appIdA = "9241157b-801b-521c-ace8-f0c15f097927"
    let appIdB = "3f71b2bb-ec24-55b4-812b-99cbc889a823"
    let appIdC = "47bccf75-eca6-5dd7-9836-09810316495f"

    var touchpoint: Touchpoint!
    var currentCardStyle: CardStyle = .undefined
    var cardAnimatePointY: CGFloat = 0
    var cardReducedPointY: CGFloat = 0
    var cardNormalPointY: CGFloat = 0
    var cardInitialPointY: CGFloat = 0
    var cardMainPointX: CGFloat = 0
    var cardLeftPointX: CGFloat = 0
    var cardRightPointX: CGFloat = 0

    private var requests = [VNRequest]()
    var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()
    //TODO: need to calculate dynamically
    var detectionRect = CGRect(x: 80, y: 105, width: 220, height: 220)
    var oldPayload: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the red focus area on load
        self.highlightView?.frame = .zero

        setupVision()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)

        cardMainPointX = (self.view.frame.size.width * 0.5) - (CardView.defaultWidthForCardStyle(.enhanced) * 0.5)
        captureSession.startRunning()
        view.bringSubview(toFront: backgroundView)
//        view.bringSubview(toFront: messageLabel)
//        view.bringSubview(toFront: highlightView!)

        view.bringSubview(toFront: aButton!)
        view.bringSubview(toFront: bButton!)
        view.bringSubview(toFront: cButton!)

        phyManager.delegate = self

        currentCardStyle = .streamlined

        cardAnimatePointY = self.view.frame.size.height
        cardReducedPointY = ceil(self.view.frame.size.height * 0.51)
        cardNormalPointY = ceil(self.view.frame.size.height * 0.1)
        cardInitialPointY = cardReducedPointY
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (self.captureSession.isRunning == false) {
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.captureSession.isRunning == true) {
            self.captureSession.stopRunning()
        }
    }
    
    @IBAction func aButton(_ sender: Any) {
        if (currentAppIdCode != 1) {
            aButton.setImage(UIImage(named: "pai_a_selected"), for: .normal)
            currentAppIdCode = 1
        } else {
            aButton.setImage(UIImage(named: "pai_a"), for: .normal)
            currentAppIdCode = 0
        }
        bButton.setImage(UIImage(named: "pai_b"), for: .normal)
        cButton.setImage(UIImage(named: "pai_c"), for: .normal)
        if (card != nil) {
            card.removeItself()
        }
        touchpoint = nil
        oldPayload = ""
    }
    @IBAction func bButton(_ sender: Any) {
        if (currentAppIdCode != 2) {
            bButton.setImage(UIImage(named: "pai_b_selected"), for: .normal)
            currentAppIdCode = 2
        } else {
            bButton.setImage(UIImage(named: "pai_b"), for: .normal)
            currentAppIdCode = 0
        }
        aButton.setImage(UIImage(named: "pai_a"), for: .normal)
        cButton.setImage(UIImage(named: "pai_c"), for: .normal)
        if (card != nil) {
            card.removeItself()
        }
        touchpoint = nil
        oldPayload = ""
    }
    @IBAction func cButton(_ sender: Any) {
        if (currentAppIdCode != 3) {
            cButton.setImage(UIImage(named: "pai_c_selected"), for: .normal)
            currentAppIdCode = 3
        } else {
            cButton.setImage(UIImage(named: "pai_c"), for: .normal)
            currentAppIdCode = 0
        }
        aButton.setImage(UIImage(named: "pai_a"), for: .normal)
        bButton.setImage(UIImage(named: "pai_b"), for: .normal)
        if (card != nil) {
            card.removeItself()
        }
        touchpoint = nil
        oldPayload = ""
    }
    
    func touchpointCreated() {
        if (card != nil) {
            card.removeItself()
        }
        card = CardView.cardForStyle(currentCardStyle)
        card.touchpoint = touchpoint
        card.type = .qr

        // set the frame of the newest card to its animate in point before adding it as a subview
        card.moveTo(point: CGPoint(x: self.cardMainPointX, y: self.cardAnimatePointY), animate: false)
        self.view.addSubview(card)
        // animate into place
        card.moveTo(point: CGPoint(x: self.cardMainPointX, y: self.cardInitialPointY), animate: true)
    }
    
    func setupVision() {
        // create the request
        let request = VNDetectBarcodesRequest(completionHandler: self.handleQRCodes)
        self.requests = [request]
    }
    
    func handleQRCodes(_ request: VNRequest, error: Error?) {
        if request.results != nil {
            if let results = request.results as? [VNObservation] {
                // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
                DispatchQueue.main.async {
                    self.handleVisionRequestResults(results)
                }
            }
            else {
                print("QRView.handleQRCodes(): unable to downcast to [NVObservation]")
            }
        }
    }
    
    private func handleVisionRequestResults(_ results:[VNObservation]) {
        for result in results {
            
            // Cast the result to a barcode-observation
            if let barcodeOberservation = result as? VNBarcodeObservation {
                
                // check the confidence level before updating the UI
                guard barcodeOberservation.confidence >= 0.3 else {
                    self.highlightView?.frame = .zero
                    return
                }
                // calculate view rect
                var observationRect = barcodeOberservation.boundingBox
                observationRect.origin.y = 1 - observationRect.origin.y - (observationRect.width * 1.5)
                let convertedRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observationRect)
                
                if (detectionRect.contains(convertedRect)) {
                    if let payload = barcodeOberservation.payloadStringValue {
                        if payload != oldPayload {
                            scannedNewCode(qrPayload: payload)
                            oldPayload = payload
                        }
                    }
                }

                // move the highlight view
//                self.highlightView?.frame = convertedRect
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        // perform the request
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    func scannedNewCode(qrPayload: String) {
//        print("qrPayload: \(qrPayload)")
        var messageText: String
        if (qrPayload.hasPrefix("BEGIN:VCARD")) {
            messageText = "vCard"
        } else if (qrPayload.hasPrefix("SMSTO")) {
            messageText = "SMS"
        } else if (qrPayload.hasPrefix("MAILTO") || qrPayload.hasPrefix("MATMSG")) {
            messageText = "Email"
        } else {
            let pat = "[-a-zA-Z0-9@:%_\\+.~#?&//=]{2,256}\\.[a-z]{2,4}\\b(\\/[-a-zA-Z0-9@:%_\\+.~#?&//=]*)?"
            let regex = try! NSRegularExpression(pattern: pat, options: .caseInsensitive)
            let matches = regex.matches(in: qrPayload, options: [], range: NSRange(location: 0, length: qrPayload.utf16.count))
            if (matches.count == 0) {
                messageText = "Unkown"
            } else {
                var matchText = ""
                if let match = matches.first {
                    let range = match.range(at:0)
                    if let swiftRange = Range(range, in: qrPayload) {
                        matchText = String(qrPayload[swiftRange])
                    }
                }

                var scanUrl: String
                if (!matchText.hasPrefix("http")) {
                    scanUrl = "http://" + matchText
                } else {
                    scanUrl = matchText
                }
                messageText = scanUrl

                if (touchpoint == nil || touchpoint.scanUrl != scanUrl) {
                    // create basic touchpoint
                    touchpoint = Touchpoint()
                    touchpoint.scanUrl = scanUrl
                    touchpoint.headerImage = UIImage(named: "blank_header.jpg")
                    touchpoint.waitingForMetadata = true
                    DispatchQueue.main.async {
                        self.touchpointCreated()
                        self.beaconToResolve = PHYEddystoneBeacon()
                        if (self.currentAppIdCode == 1) {
                            self.beaconToResolve.scanUrl = scanUrl + "?phy_app_id=" + self.appIdA
                        } else if (self.currentAppIdCode == 2) {
                            self.beaconToResolve.scanUrl = scanUrl + "?phy_app_id=" + self.appIdB
                        } else if (self.currentAppIdCode == 3) {
                            self.beaconToResolve.scanUrl = scanUrl + "?phy_app_id=" + self.appIdC
                        } else {
                            self.beaconToResolve.scanUrl = scanUrl
                        }
                        print("QRView.scanedNewCode(): resolving metadata...? \(self.phyManager)")
                        self.phyManager.resolveBeacon(forMetadata: self.beaconToResolve)
                    }

                }
            }
        }
//        messageLabel.text = messageText
        self.backgroundView.alpha = 0.5
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 1
        })
    }
    
    @objc func phyManager(_ manager: PHYEddystoneManager!, didResolveMetadata beacon: PHYEddystoneBeacon!) {
        
//        print("QRViewController.didResolveMetadata() - beacon = \(beacon.title)")
        if (touchpoint != nil) {
            touchpoint.title = beacon.title
            touchpoint.content = beacon.desc
            touchpoint.rssi = beacon.rssi.stringValue
            touchpoint.txPower = beacon.txPowerLevel.stringValue
            touchpoint.scanUrl = beacon.scanUrl
            touchpoint.destinationUrl = beacon.destinationUrl
            touchpoint.waitingForMetadata = false
            
            DispatchQueue.main.async {
                self.card.updateContent()
            }
        }
    }
    
    @objc func phyManager(_ manager: PHYEddystoneManager!, didFetchImage beacon: PHYEddystoneBeacon) {
        
//        print("QRViewController.didFetchImage() - beacon = \(beacon.destinationUrl)")
        
        if (touchpoint != nil && card != nil) {
            if beacon.headerImage != nil {
                self.card.touchpoint.headerImage = beacon.headerImage
            }
            if beacon.faviconImage != nil {
                self.card.touchpoint.favouriteIcon = beacon.faviconImage
            }
            // do this on main thread because of UI stuff
            DispatchQueue.main.async {
                self.card.updateContent()
            }
        }
    }

}


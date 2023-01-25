//
//  OcrViewController..swift
//  @QuramMI
//

import Foundation
import UIKit

class OcrViewController: UIViewController {
    
    let ocrView: OcrSdkView = OcrSdkView()
    
    var scanResult:OcrScanResult? = nil
    
    var guideOrientation:Int = 0
    
    fileprivate var scannerType = 0 /* use 4 for Alien Card , use 11 for AC back */
    
    fileprivate var scanExpiry = true
    fileprivate var validateNumber = true
    fileprivate var validateExpiry = true
    fileprivate var scanHolderName = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(ocrView)
        
        ocrView.frame = view.bounds
        
        ocrView.sdkViewDelegate = self
        
        // set Single-Take-mode 20210323
        ocrView.setIDScanMode(scanMode: 1)
        
        ocrView.setScannerType(scannerType)
        ocrView.setOptions(scanExpiry: true, validateNumber: true, validateExpiry: true, scanHolderName: scanHolderName)
        ocrView.setIDOptions(scanIssuingDate: true, scanIssuingRegion: true, scanLicenseNumber: true, scanLicenseType: true, scanLisenseSerial: true)
        
        if( scannerType == 0 ) {
            let button_w = Int(self.view.bounds.size.width)
            let button_h = 40
            let button_y = Int(self.view.bounds.size.height) - 150
            
            print("button position = \(button_w), \(button_y)")
            
            let button = UIButton(frame: CGRect(x: 0, y: button_y, width: button_w, height: button_h))
            button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
            //button.backgroundColor = .green
            button.setTitle("Rotate", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

            self.view.addSubview(button)
        }
        
        if( scannerType != 11 ) {
            ocrView.setGuideRect(horizontalOffset: 0.5, vericalOffset: 0.5, scale: 1.0, orientation: 0)
        }
        else {
            ocrView.setGuideRect(horizontalOffset: 0.5, vericalOffset: 0.5, scale: 1.0, orientation: 1)
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        guideOrientation = (guideOrientation + 1) % 2
        ocrView.changeGuideRect(horizontalOffset: 0.5, vericalOffset: 0.5, scale: 1.0, orientation: guideOrientation)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if( self.scanResult == nil ) {
            return
        }

        if( segue.identifier == "CreditCardResult" ) {
            let controller = segue.destination as! CreditCardResultViewController
            controller.setResultInfo(scanResult: self.scanResult!)
        }
        else if( segue.identifier == "KorIdCardResult" ) {
            let controller = segue.destination as! KorIDResultViewController
            controller.setResultInfo(scanResult: self.scanResult!)
        }
        else if( segue.identifier == "AlienCardResult" ) {
            let controller = segue.destination as! AlienResultViewController
            controller.setResultInfo(scanResult: self.scanResult!)
        }
        else if( segue.identifier == "AlienCardBacksideResult" ) {
            let controller = segue.destination as! AlienBacksideResultViewController
            controller.setResultInfo(scanResult: self.scanResult!)
        }
        else if( segue.identifier == "PassportResult" ) {
            let controller = segue.destination as! PassportResultViewController
            controller.setResultInfo(scanResult: self.scanResult!)
        }
    }
}

extension OcrViewController {
    func setScannerType(_ tabIndex: Int) {
        // UI tab Index --> 0 : creditCard, 1 : kor_id
        switch(tabIndex)
        {
        // scannerType
        // - 0 : CreditCard
        // - 1 : Kor IDCard
        // - 4 : Alien Card
        // - 5 : Passport
        // - 11 : Alien Card Backside
            case 0:
                self.scannerType = 0
                break
            case 1:
                self.scannerType = 1
                break
            case 2:
                self.scannerType = 4
                break
            case 3:
                self.scannerType = 11
                break
            case 4:
                self.scannerType = 5
                break
            default:
                break
        }
    }
    
    func setPrepareData(scanExpiry: Bool, validateNumber: Bool, validateExpiry: Bool, scanHolderName: Bool) {
        
        self.scanExpiry = scanExpiry;
        self.validateNumber = validateNumber;
        self.validateExpiry = validateExpiry;
        self.scanHolderName = scanHolderName;
    }
}

extension OcrViewController: OcrSdkViewDelegate {
    func detectedState(_ state: Bool) {
        
    }

    func ocrSDKView(_: OcrSdkView, didScanCard: OcrScanResult) {
        self.scanResult = didScanCard
        
        /*
        if (self.scannerType == 0) {
            let view = OcrResultview(frame: self.view.frame)
            view.setCardScanInfo(image: didScanCard.cardImage!, number: didScanCard.cardNumber, expiry: didScanCard.expirtyDate)
            view.resultViewDelegate = self
            self.view.addSubview(view)
        }
        */
        if(self.scanResult?.result == 10) { // time out

            let w:CGFloat = 300
            let h:CGFloat = 50
            
            let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - w)/2, y: (self.view.frame.size.height - h)/2, width: w, height: h))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            //toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = "인식에 실패했습니다. 다시 시도해 주세요."
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
        else {
            if( self.scannerType == 0 ) {
                performSegue(withIdentifier: "CreditCardResult", sender: self)
            }
            else if(self.scannerType == 1) {
                performSegue(withIdentifier: "KorIdCardResult", sender: self)
            }
            else if(self.scannerType == 4) {
                performSegue(withIdentifier: "AlienCardResult", sender: self)
            }
            else if(self.scannerType == 5) {
                performSegue(withIdentifier: "PassportResult", sender: self)
            }
            else if(self.scannerType == 11) {
                performSegue(withIdentifier: "AlienCardBacksideResult", sender: self)
            }
        }
    }
    
    /*
    func sendResult (scanResult: OcrScanResult) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        print("sendResult")
        let resultVC = storyBoard.instantiateViewController(identifier: "KorIdCardResult") as! KorIDResultViewController
        resultVC.setResultInfo(scanResult: scanResult)
        self.present(resultVC, animated: true, completion: nil)
    }
     */
}

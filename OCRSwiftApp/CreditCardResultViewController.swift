//
//  KorIDResultViewController.swift
//  @QuramMI
//


import Foundation
import UIKit

class CreditCardResultViewController: UIViewController {
    
    @IBOutlet var resultTitle: UILabel!
    @IBOutlet var buttonOK: UIButton!
    @IBOutlet var cardImage: UIImageView!
    
    // CreditCard
    @IBOutlet var labelNumber: UILabel!
    @IBOutlet var labelExpiry: UILabel!
    @IBOutlet var labelHolderName: UILabel!
    
    var result: OcrScanResult? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showResultInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    @IBAction func btnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    public func setResultInfo(scanResult:OcrScanResult){
        self.result = scanResult
    }
    
    private func showResultInfo() {
        self.labelNumber.text            = self.result?.cardNumber as String?
        self.labelExpiry.text            = self.result?.expirtyDate as String?
        self.labelHolderName.text        = self.result?.holderName as String?
        
        self.cardImage.image            = self.result?.cardImage
        
        self.result?.resetPersonalData()
    }
}

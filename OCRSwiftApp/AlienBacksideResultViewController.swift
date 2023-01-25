//
//  AlienResultViewController.swift
//  OCRSwift
//

import Foundation
import UIKit

class AlienBacksideResultViewController: UIViewController {
    
    @IBOutlet var resultTitle: UILabel!
    @IBOutlet var buttonOK: UIButton!
    @IBOutlet var cardImage: UIImageView!

    // Alien
    @IBOutlet var labelSerial: UILabel!
    
    @IBOutlet var labelPermission_0: UILabel!
    @IBOutlet var labelExpiry_0: UILabel!
    @IBOutlet var labelConfirm_0: UILabel!
    
    @IBOutlet var labelPermission_1: UILabel!
    @IBOutlet var labelExpiry_1: UILabel!
    @IBOutlet var labelConfirm_1: UILabel!
    
    @IBOutlet var labelPermission_2: UILabel!
    @IBOutlet var labelExpiry_2: UILabel!
    @IBOutlet var labelConfirm_2: UILabel!
    
    @IBOutlet var labelPermission_3: UILabel!
    @IBOutlet var labelExpiry_3: UILabel!
    @IBOutlet var labelConfirm_3: UILabel!
    
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
        self.cardImage.image            = self.result?.cardImage
        
        self.labelSerial.text           = self.result?.alienSerial as String?
        
        self.labelPermission_0.text     = self.result?.alienPermissionDate0 as String?
        self.labelExpiry_0.text         = self.result?.alienExpiryDate0 as String?
        self.labelConfirm_0.text        = self.result?.alienConfirmation0 as String?
        
        self.labelPermission_1.text     = self.result?.alienPermissionDate1 as String?
        self.labelExpiry_1.text         = self.result?.alienExpiryDate1 as String?
        self.labelConfirm_1.text        = self.result?.alienConfirmation1 as String?
        
        self.labelPermission_2.text     = self.result?.alienPermissionDate2 as String?
        self.labelExpiry_2.text         = self.result?.alienExpiryDate2 as String?
        self.labelConfirm_2.text        = self.result?.alienConfirmation2 as String?
        
        self.labelPermission_3.text     = self.result?.alienPermissionDate3 as String?
        self.labelExpiry_3.text         = self.result?.alienExpiryDate3 as String?
        self.labelConfirm_3.text        = self.result?.alienConfirmation3 as String?
        
        self.result?.resetPersonalData()
    }
    
    
}

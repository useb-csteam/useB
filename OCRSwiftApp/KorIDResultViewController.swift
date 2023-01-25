//
//  KorIDResultViewController.swift
//  @QuramMI
//

import Foundation
import UIKit

class KorIDResultViewController: UIViewController {
    
    @IBOutlet var resultTitle: UILabel!
    @IBOutlet var buttonOK: UIButton!
    @IBOutlet var cardImage: UIImageView!

    // Kor ID
    @IBOutlet var labelLicenseType: UILabel!
    @IBOutlet var labelIssuingDate: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelKorIdNum: UILabel!
    @IBOutlet var labelLicenseNo: UILabel!
    @IBOutlet var labelLicenseNoMask: UILabel!
    @IBOutlet var labelIssuingRegion: UILabel!
    @IBOutlet var labelLicenseSerial: UILabel!
    @IBOutlet var labelOverseasResident: UILabel!
    @IBOutlet var labelValidate: UILabel!
    @IBOutlet var labelColorTest: UILabel!
    @IBOutlet var labelFaceScore: UILabel!
    @IBOutlet var labelSpentTime: UILabel!
    
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
        self.labelLicenseType.text      = self.result?.licenseType as String?
        self.labelIssuingDate.text      = self.result?.issuingDate as String?
        self.labelName.text             = self.result?.name as String?
        self.labelKorIdNum.text         = self.result?.korIDNum as String?
        self.labelLicenseNo.text        = self.result?.licenseNo as String?
        self.labelLicenseNoMask.text    = self.result?.licenseNo_masking as String?
        self.labelIssuingRegion.text    = self.result?.issuingRegion as String?
        self.labelLicenseSerial.text    = self.result?.licenseSerial as String?
        self.labelOverseasResident.text = String(self.result!.overseasResident)
        self.labelValidate.text         = String(self.result!.validate)
        self.labelColorTest.text        = String(self.result!.color_test)
        self.labelFaceScore.text        = String(format:"%1.3f", self.result!.face_score) + " / " + String(format:"%1.3f", self.result!.specular_ratio)
        self.labelSpentTime.text        = String(self.result!.end_time - self.result!.start_time)
        
        //self.cardImage.image            = self.result?.maskingCardImage
        self.cardImage.image            = self.result?.frameImage
        
        self.result?.resetPersonalData()
    }
    
    
}

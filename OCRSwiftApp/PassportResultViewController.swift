//
//  PassportResultView.swift
//  @QuramMI
//


import Foundation
import UIKit

class PassportResultViewController: UIViewController {
    
    @IBOutlet var buttonOK: UIButton!
    @IBOutlet var cardImage: UIImageView!

    @IBOutlet var labelNameKor: UILabel!
    @IBOutlet var labelKorIDNum: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelSurName: UILabel!
    @IBOutlet var labelGivenName: UILabel!
    @IBOutlet var labelPassportType: UILabel!
    @IBOutlet var labelIssuingCountry: UILabel!
    @IBOutlet var labelPassportNumber: UILabel!
    @IBOutlet var labelNationality: UILabel!
    @IBOutlet var labelBirthDay: UILabel!
    @IBOutlet var labelSex: UILabel!
    @IBOutlet var labelExpiryDate: UILabel!
    @IBOutlet var labelPersonalNumber: UILabel!
    @IBOutlet var labelIssuingDate: UILabel!
    @IBOutlet var labelFaceScore: UILabel!
    @IBOutlet var labelMRZ1: UILabel!
    @IBOutlet var labelMRZ2: UILabel!
    @IBOutlet var labelValidation: UILabel!
    
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
        self.labelNameKor.text          = self.result?.nameKor as String?
        self.labelKorIDNum.text         = self.result?.korIDNum as String?
        self.labelName.text             = self.result?.name as String?
        self.labelSurName.text          = self.result?.surName as String?
        self.labelGivenName.text        = self.result?.givenName as String?
        self.labelPassportType.text     = self.result?.passportType as String?
        self.labelIssuingCountry.text   = self.result?.issuingCountry as String?
        self.labelPassportNumber.text   = self.result?.passportNo as String?
        self.labelNationality.text      = self.result?.nationality as String?
        self.labelBirthDay.text         = self.result?.dateOfBirth as String?
        self.labelSex.text              = self.result?.sex as String?
        self.labelExpiryDate.text       = self.result?.expirtyDate as String?
        self.labelPersonalNumber.text   = self.result?.personalNo as String?
        self.labelIssuingDate.text      = self.result?.issuingDate as String?
        self.labelFaceScore.text        = String(format:"%1.3f", self.result!.face_score) + " / " + String(format:"%1.3f", self.result!.specular_ratio)
        
        //self.cardImage.image            = self.result?.maskingCardImage
        self.cardImage.image            = self.result?.maskingCardImage
        self.labelMRZ1.text             = self.result?.mrz1 as String?
        self.labelMRZ2.text             = self.result?.mrz2 as String?
        
        self.labelValidation.text       = String(self.result!.validate)
        
        self.result?.resetPersonalData()
    }
    
    
}

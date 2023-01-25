//
//  AlienResultViewController.swift
//  @QuramMI
//

import Foundation
import UIKit

class AlienResultViewController: UIViewController {
    
    @IBOutlet var resultTitle: UILabel!
    @IBOutlet var buttonOK: UIButton!
    @IBOutlet var cardImage: UIImageView!

    // Alien
    @IBOutlet var labelIssuingDate: UILabel!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelAlienNum: UILabel!
    //@IBOutlet var labelColorTest: UILabel!
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
        self.labelIssuingDate.text      = self.result?.issuingDate as String?
        self.labelName.text             = self.result?.name as String?
        self.labelAlienNum.text         = self.result?.korIDNum as String?
        //self.labelColorTest.text        = String(self.result!.color_test)
        self.labelFaceScore.text        = String(format:"%1.3f", self.result!.face_score) + " / " + String(format:"%1.3f", self.result!.specular_ratio)
        self.labelSpentTime.text        = String(self.result!.end_time - self.result!.start_time)
        
        self.cardImage.image            = self.result?.maskingCardImage
        
        self.result?.resetPersonalData()
    }
    
    
}

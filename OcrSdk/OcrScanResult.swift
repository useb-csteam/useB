//
//  OcrScanResult.swift
//  @MachineEyeSDK
//


import UIKit

class OcrScanResult {
    //credit card
    var idType: String = ""
    var cardNumber: NSMutableString = ""
    var expirtyDate: NSMutableString = ""
    var holderName: NSMutableString = ""

    var cardImage: UIImage?
    var cardOrgImage: UIImage?
    var idPhotoImage: UIImage?
    var maskingCardImage: UIImage?
    var frameImage: UIImage?
    var maskingFrameImage: UIImage?
    var result: Int = 0
    
    var name: NSMutableString?
    var korIDNum: NSMutableString?

    // kor id
    
    var licenseType: NSMutableString?
    var licenseNo: NSMutableString?
    var licenseNo_masking: NSMutableString?
    var issuingDate: NSMutableString?
    var issuingRegion: NSMutableString?
    var licenseSerial: NSMutableString?

    var overseasResident: Bool = false
    
    var color_test: Bool = false

    var face_score: Double = 0
    var specular_ratio: Double = 0
    
    //passport
    var passportType: NSMutableString?
    var issuingCountry: NSMutableString?
    var nameKor: NSMutableString?
    var passportNo: NSMutableString?
    var nationality: NSMutableString?
    var dateOfBirth: NSMutableString?
    var sex: NSMutableString?
    var dateOfIssue: NSMutableString?
    var personalNo: NSMutableString?
    var surName: NSMutableString?
    var givenName: NSMutableString?
    
    var mrz1: NSMutableString?
    var mrz2: NSMutableString?

    var validate: Bool = false
    
    // alien back
    var alienSerial: NSMutableString?
    var alienPermissionDate0: NSMutableString?
    var alienPermissionDate1: NSMutableString?
    var alienPermissionDate2: NSMutableString?
    var alienPermissionDate3: NSMutableString?
    
    var alienExpiryDate0: NSMutableString?
    var alienExpiryDate1: NSMutableString?
    var alienExpiryDate2: NSMutableString?
    var alienExpiryDate3: NSMutableString?
    
    var alienConfirmation0: NSMutableString?
    var alienConfirmation1: NSMutableString?
    var alienConfirmation2: NSMutableString?
    var alienConfirmation3: NSMutableString?
    
    
    var start_time: Int = 0
    var end_time: Int = 0
    
    //var scanFrameList: [Data] = []
    //var scanFrameList: [AnyHashable] = []
    var scanFrameList: Array<UIImage>?
    
    private func resetData(string:NSMutableString) {
        var range:NSRange = NSRange()
        range.location = 0
        range.length = 1
      
        let count = string.length
        for i in stride(from:count-1, to:0, by:-1) {
            range.location = i;
            string.deleteCharacters(in: range)
        }
    }
    
    public func resetPersonalData() {
        resetData(string:self.cardNumber)
        resetData(string:self.expirtyDate)
        resetData(string:self.name ?? "")
        resetData(string:self.korIDNum ?? "")
        resetData(string:self.licenseNo ?? "")
        resetData(string:self.licenseNo_masking ?? "")
        resetData(string:self.licenseSerial ?? "")
        resetData(string:self.issuingDate ?? "")
        resetData(string:self.issuingRegion ?? "")
        resetData(string:self.nameKor ?? "")
        resetData(string:self.surName ?? "")
        resetData(string:self.givenName ?? "")
        resetData(string:self.passportNo ?? "")
        resetData(string:self.dateOfBirth ?? "")
        resetData(string:self.alienSerial ?? "")
        
        resetData(string:self.passportType ?? "")
        resetData(string:self.issuingCountry ?? "")
        resetData(string:self.nameKor ?? "")
        resetData(string:self.passportNo ?? "")
        resetData(string:self.nationality ?? "")
        resetData(string:self.dateOfBirth ?? "")
        resetData(string:self.sex ?? "")
        resetData(string:self.dateOfIssue ?? "")
        resetData(string:self.personalNo ?? "")
        resetData(string:self.surName ?? "")
        resetData(string:self.givenName ?? "")
        
        resetData(string:self.mrz1 ?? "")
        resetData(string:self.mrz2 ?? "")
    }
}

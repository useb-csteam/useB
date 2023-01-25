//
//  OcrSdkView.swift
//  @MachineEyeSDK
//


import UIKit
import MachineEyeSDK

protocol OcrSdkViewDelegate: class {
    func ocrSDKView(_: OcrSdkView, didScanCard: OcrScanResult)
    func detectedState(_ state: Bool)
}

final class OcrSdkView: UIView {
    weak var sdkViewDelegate: OcrSdkViewDelegate?
    
    var horizontalOffset: Float = 0.0
    var vericalOffset: Float = 0.0
    var scale: Float = 0.0
    var orientation: Int = 0
    
    let IDSCAN_DEFAULT_MODE:Int     = 0
    let IDSCAN_SINGLE_TAKE_MODE:Int = 1
    
    fileprivate var preview: OcrCameraPreview?
    fileprivate var guideLayer: OcrGuideLayer?
    fileprivate var config: OcrSdkConfig?
    
    fileprivate var debugView: UIImageView?
    
    fileprivate var scanExpiry: Bool = false
    fileprivate var validateNumber: Bool = false
    fileprivate var validateExpiry: Bool = false
    fileprivate var scanHolderName: Bool = false
    
    fileprivate var scanIssuingDate: Bool = false
    fileprivate var scanIssuingRegion: Bool = false
    fileprivate var scanLicenseNumber: Bool = false
    fileprivate var scanLicenseType: Bool = false
    fileprivate var scanLisenseSerial: Bool = false
    
    fileprivate var scanMode: Int = 0
    
    fileprivate var cardType: Int = 0 // creditCard : 0, kor_id : 1, alien : 4, passport : 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension OcrSdkView {
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil  {
            implicitStop()
        }
        super.willMove(toWindow: newWindow)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        implicitStart()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preview?.preview.frame = bounds
        guideLayer?.layerLayout(rect: bounds)
        guideLayer?.changeGuideLayerState(state: 0)
        
        if let guideRect: CGRect = preview?.guideRect {
            guideLayer?.configureGuideLayer(guideRect: guideRect)
        }
    }
    

}

extension OcrSdkView {
    
    func setOptions(scanExpiry: Bool, validateNumber: Bool, validateExpiry: Bool, scanHolderName: Bool) {
        self.scanExpiry = scanExpiry
        self.validateNumber = validateNumber
        self.validateExpiry = validateExpiry
        self.scanHolderName = scanHolderName
    }
    
    func setIDOptions(scanIssuingDate: Bool,  scanIssuingRegion:Bool, scanLicenseNumber: Bool, scanLicenseType:Bool, scanLisenseSerial: Bool) {
        self.scanIssuingDate = scanIssuingDate
        self.scanIssuingRegion = scanIssuingRegion
        self.scanLicenseNumber = scanLicenseNumber
        self.scanLicenseType = scanLicenseType
        self.scanLisenseSerial = scanLisenseSerial
    }
    
    // set Single-Take-mode 20210323
    func setIDScanMode(scanMode: Int) {
        self.scanMode = scanMode
    }
    
    func setScannerType(_ scannerType: Int) {
        cardType = scannerType
    }
    
    func setGuideRect(horizontalOffset: Float, vericalOffset: Float, scale: Float, orientation: Int) {
        self.horizontalOffset = horizontalOffset
        self.vericalOffset = vericalOffset
        self.scale = scale
        self.orientation = orientation
    }
    
    func changeGuideRect(horizontalOffset: Float, vericalOffset: Float, scale: Float, orientation: Int) {
        guard preview != nil else { return }
        setGuideRect(horizontalOffset: horizontalOffset, vericalOffset: vericalOffset, scale: scale, orientation: orientation)
        
        preview?.changeGuideRect(horizontalOffset: horizontalOffset, verticalOffset: vericalOffset, scale: scale, orientation: orientation)
        
        if let guideRect: CGRect = preview?.guideRect {
            guideLayer?.configureGuideLayer(guideRect: guideRect)
        }
    }
    
    func restartPreview() {
        self.implicitStop()
        self.implicitStart()
    }
    
    fileprivate func implicitStart() {
        if( self.config == nil ) {
            self.config = OcrSdkConfig()
        }
        
        preview = OcrCameraPreview()
        guideLayer = OcrGuideLayer()
        
        // set Single-Take-mode 20210323
        preview?.setIDScannerMode(mode: scanMode)
        preview?.setOcrScannerType(cardType)
        preview?.setScanOption(scanexpiry: scanExpiry, validateNumber: validateNumber, validateEpiry: validateExpiry, scanHolderName: scanHolderName)
        preview?.setScanIDOption(scanIssuingDate: scanIssuingDate, scanIssuingRegion: scanIssuingRegion, scanLicenseNumber: scanLicenseNumber, scanLicenseType: scanLicenseType, scanLicenseSerial: scanLisenseSerial)
        
        preview?.setGuideRect(horizontalOffset: horizontalOffset, verticalOffset: 0.5, scale: 1.0, orientation: self.orientation)
        
        if let cameraPreview = preview?.preview {
            layer.addSublayer(cameraPreview)
            guideLayer?.addLayer(layer: layer)
        }
        
        preview?.videoFrameDelegate = self
        preview?.startSession()
    }
    
    fileprivate func implicitStop() {
        preview?.stopSession()
    }
}

extension OcrSdkView: OcrCameraPreviewDelegate {
    func scanResult(_ result: OcrScanResult) {
        
        if result.result == 0 {
            guideLayer?.changeGuideLayerState(state: 0)
            self.sdkViewDelegate?.detectedState(false)
        } else {
            guideLayer?.changeGuideLayerState(state: 1)
            self.sdkViewDelegate?.detectedState(true)
        }
        
        if (result.result == 3) || (result.result == OCR_CARD_SCAN_STATE_TIME_OUT) {

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Send result to view controller
                self.sdkViewDelegate?.ocrSDKView(self, didScanCard: result)
            }
            
            if(result.result == OCR_CARD_SCAN_STATE_TIME_OUT) {
                preview?.startSession()
            }
        }
    }
}

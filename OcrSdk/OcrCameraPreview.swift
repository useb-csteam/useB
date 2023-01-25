//
//  OcrCameraPreview.swift
//  @MachineEyeSDK
//


import UIKit
import AVFoundation
import MachineEyeSDK

class OcrCameraPreview: NSObject {
    let preview: AVCaptureVideoPreviewLayer
    
    private var ocrScanner: OcrSdkCardScanner? = nil
    private var config: OcrSdkConfig? = nil
    
    private let camera: AVCaptureDevice?
    private let captureSession: AVCaptureSession
    private let cameraConfigurationSemaphore: DispatchSemaphore
    
    private var cameraInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewOnGoing: Bool = false
    
    var horizontalOffset: Float = 0
    var verticalOffset: Float = 0
    var scale: Float = 0
    var orientation: Int = 0
    
    var ocrScannerType: Int32 = 0
    
    var timeInterval: Int64 = 0
    
    private var currentlyAdjustingFocus: Bool = false
    private var currentlyAdjustingExposure: Bool = false
    
    private var scanExpiry: Bool = false
    private var validateNumber: Bool = false
    private var validateExpiry: Bool = false
    private var scanHolderName: Bool = false
    
    private var scanIssuingDate: Bool = false
    private var scanIssuingRegion: Bool = false
    private var scanLicenseNumber: Bool = false
    private var scanLicenseType: Bool = false
    private var scanLisenseSerial: Bool = false
    
    private var idScannerMode: Int = 0
    
    weak var videoFrameDelegate: OcrCameraPreviewDelegate?
    
    static let videoQueueName = "ocr.sdk.ios.videostream"
    
    override init() {
        captureSession = AVCaptureSession()
        camera = AVCaptureDevice.default(for: .video)
        preview = AVCaptureVideoPreviewLayer.init(session: captureSession)
        
        preview.needsDisplayOnBoundsChange = true
        preview.contentsGravity = .resizeAspectFill
        preview.videoGravity = .resizeAspectFill
        preview.backgroundColor = UIColor.gray.cgColor
        
        cameraConfigurationSemaphore = DispatchSemaphore(value: 1)
    }
    
    func setGuideRect(horizontalOffset: Float, verticalOffset: Float, scale: Float, orientation: Int) {
        self.horizontalOffset = horizontalOffset
        self.verticalOffset = verticalOffset
        self.scale = scale
        self.orientation = orientation
    }
    
    func changeGuideRect(horizontalOffset: Float, verticalOffset: Float, scale: Float, orientation: Int) {
         guard ocrScanner != nil else { return }
        
        self.horizontalOffset = horizontalOffset
        self.verticalOffset = verticalOffset
        self.scale = scale
        self.orientation = orientation
        
        ocrScanner?.changeGuideRect(config,
                                    horizontal: horizontalOffset,
                                    vertical: verticalOffset,
                                    scale: scale,
                                    orientation: Int32(orientation))
    }
    
    func startSession() {
        guard previewOnGoing == false else { return }
        
        ocrScanner = OcrSdkCardScanner(ocrScannerType)
        if( config == nil ) {
            config = OcrSdkConfig()
        }
        
        config?.licenseKeyFile = "quram_mi_demo_license.flk"
        config?.licenseKeyBuffer = ""
        
        config?.guideRectOrientation = 0
        config?.idScannerMode = Int32(self.idScannerMode)
        
        config?.timeOutIntervalSec = 3 //sec
        
        ocrScanner?.configureScanner(ocrScannerType, config: config)
        
        _ = ocrScanner?.changeGuideRect(config,
                                              horizontal: horizontalOffset,
                                              vertical: verticalOffset,
                                              scale: scale,
                                              orientation: Int32(orientation))

        switch ocrScannerType {
        case 0:
            ocrScanner?
                .setScanOption(config,
                               scanExpiry: scanExpiry,
                               validateNumber: validateNumber,
                               validateExpiry: validateExpiry,
                               scanHolderName: scanHolderName)
        case 1:
            ocrScanner?
                .setScanIDOption(config,
                                 scanIssuingDate: scanIssuingDate,
                                 scanIssuingRegion: scanIssuingDate,
                                 scanLicenseNumber: scanIssuingRegion,
                                 scanLicenseType: scanLicenseType,
                                 scanLisenseSerial: scanLisenseSerial)
        case 4: break
        case 5: break
        default: break
        }

        guard addInputAndOutput() else { return }
            
        camera?.addObserver(self, forKeyPath: "adjustingFocus", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial ], context: nil)
        camera?.addObserver(self, forKeyPath: "adjustingExposure", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial ], context: nil)
        
        captureSession.startRunning()
        _ = changeCameraConfigration { [weak self] in
            guard let camera = self?.camera else { return }
            if camera.responds(to: #selector(getter: AVCaptureDevice.isAutoFocusRangeRestrictionSupported)),
                camera.isAutoFocusRangeRestrictionSupported{
                camera.autoFocusRangeRestriction = .near
            }
            if camera.responds(to: #selector(getter: AVCaptureDevice.isFocusPointOfInterestSupported)),
                camera.isFocusPointOfInterestSupported {
                camera.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            camera.setExposureTargetBias(0.25, completionHandler: nil)
        }
        previewOnGoing = true
    }
    
    func stopSession() {
        guard previewOnGoing == true else { return }
        previewOnGoing = false
        
        _ = changeCameraConfigration { [weak self] in
            guard let camera = self?.camera else { return }
            if camera.responds(to: #selector(getter: AVCaptureDevice.isAutoFocusRangeRestrictionSupported)),
                camera.isAutoFocusRangeRestrictionSupported{
                camera.autoFocusRangeRestriction = .none
            }
        }
        
        _ = cameraConfigurationSemaphore.wait(timeout: .distantFuture)
        
        camera?.removeObserver(self, forKeyPath: "adjustingExposure")
        camera?.removeObserver(self, forKeyPath: "adjustingFocus")
        captureSession.stopRunning()
        removeInputAndOutput()
        cameraConfigurationSemaphore.signal()
        ocrScanner?.destroy(ocrScannerType, config: config)
    }
    
    func addInputAndOutput() -> Bool {
        
        if camera == nil {
            print("OcrSdk camera input error on Simulator")
            return false
        }
        do {
            cameraInput = try AVCaptureDeviceInput(device: camera!)
        }
        catch {
            print("OcrSdk camera input error : \(error)")
            return false
        }
        
        captureSession.addInput(cameraInput!)
        
        if captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        } else {
            captureSession.sessionPreset = .vga640x480
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        
        if OcrSdkDevice.shouldSetPixelFormat {
            let videoOutputSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
            videoOutput?.videoSettings = videoOutputSettings
        }
        
        videoOutput!.alwaysDiscardsLateVideoFrames = true
        
        // NB: DO NOT USE minFrameDuration. minFrameDuration causes focusing to
        // slow down dramatically, which causes significant ux pain.
        let queue = DispatchQueue(label: OcrCameraPreview.videoQueueName)
        
        videoOutput?.setSampleBufferDelegate(self, queue: queue)
        captureSession.addOutput(videoOutput!)
        
        return true
    }
    
    func removeInputAndOutput() {
        captureSession.removeInput(cameraInput!)
        videoOutput?.setSampleBufferDelegate(nil, queue: nil)
        captureSession.removeOutput(videoOutput!)
    }
    
    func changeCameraConfigration(changeClosure: () -> Void) -> Bool {
        _ = cameraConfigurationSemaphore.wait(timeout: .distantFuture)
        
        var success = false
        var lockError: Error?
        captureSession.beginConfiguration()
        do {
            try camera?.lockForConfiguration()
        } catch {
            lockError = error
        }
        if lockError == nil {
            changeClosure()
            camera?.unlockForConfiguration()
            success = true
        }
        
        captureSession.commitConfiguration()
        cameraConfigurationSemaphore.signal()
        
        return success
    }

    func setScanOption(scanexpiry: Bool, validateNumber: Bool, validateEpiry: Bool, scanHolderName: Bool) {
        self.scanExpiry = scanexpiry;
        self.validateNumber = validateNumber
        self.validateExpiry = validateEpiry
        self.scanHolderName = scanHolderName
    }
    
    func setScanIDOption(scanIssuingDate: Bool, scanIssuingRegion:Bool, scanLicenseNumber: Bool, scanLicenseType: Bool, scanLicenseSerial: Bool) {
        self.scanIssuingDate = scanIssuingDate
        self.scanIssuingRegion = scanIssuingRegion
        self.scanLicenseNumber = scanLicenseNumber
        self.scanLicenseType = scanLicenseType
        self.scanLisenseSerial = scanLicenseSerial
    }
    
    func setOcrScannerType(_ type: Int) {
        ocrScannerType = Int32(type)
    }
    
    func setIDScannerMode(mode:Int) {
        self.idScannerMode = mode
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        let value = (change[NSKeyValueChangeKey.newKey] as? NSNumber)?.boolValue ?? false
        if keyPath == "adjustingFocus" {
            currentlyAdjustingFocus = value
        } else if keyPath == "adjustingExposure" {
            currentlyAdjustingExposure = value
        }
    }
}

extension Date {
    
    var Date_To_MilliSeconds: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(MilliSeconds_To_Date: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(MilliSeconds_To_Date) / 1000)
    }
}

extension OcrCameraPreview: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        autoreleasepool {
            guard previewOnGoing == true else  {
                return
            }
            
            guard let conf = config else { return }
            
            if (conf.timeOutIntervalSec > 0)  {
                if( timeInterval == 0 ) {
                    timeInterval = Date().Date_To_MilliSeconds
                }
                else {
                    var elapsed = (Date().Date_To_MilliSeconds - timeInterval) / 1000;

                    if( elapsed >= conf.timeOutIntervalSec ) {
                        
                        timeInterval = Date().Date_To_MilliSeconds
                        
                        print("time out!\n");
                        let result = OcrScanResult()
                        result.result = Int(OCR_CARD_SCAN_STATE_TIME_OUT)
                        DispatchQueue.main.async { [weak self] in
                            self?.sendFrameToDelegte(result)
                        }
                        //return
                    }
                }
            }
            
            let result = OcrScanResult()
            let frame = OcrSdkVideoFrame(sampleBuffer: sampleBuffer)
            var ret: Int32 = 0
            switch ocrScannerType {
            case 0:
                ret = ocrScanner?.scanFrame(frame, config: config) ?? 0

                guard let config = config else { return }
                result.cardNumber = config.cardNumber ?? ""
                if config.expiryYear < 0 || config.expiryMonth < 0 {
                    result.expirtyDate = "No Expiry"
                } else {
                    result.expirtyDate = NSMutableString(format: "%02d / %04d", config.expiryMonth, config.expiryYear)
                }
                
                result.holderName = config.holderName ?? ""
                
                result.cardImage = config.cardImage
                break
            case 1:
                ret = ocrScanner?.scanKorIDFrame(frame, config: config) ?? 0
                guard let config = config else { return }
                // test auto release
                if (ret == 3 && (config.specular_ratio > 0.0001 || config.face_score < 0.7)) {
                    debugPrint("specular_ratio = \(config.specular_ratio)")
                    debugPrint("face_score = \(config.face_score)")
                    ocrScanner?.resetScanner(config.scannerType, config: config)
                    ret = 0;
                    
                    // todo
                    // add control messge here
                    break;
                }
                
                if config.id_card_type == 1 {
                    result.idType = String("주민등록증")
                } else if config.id_card_type == 2 {
                    result.idType = String("운전면허증")
                } else {
                    result.idType = String("NotDetected")
                }
                result.cardImage = config.markedCardImage
                result.cardOrgImage = config.cardImage
                result.idPhotoImage = config.photoImage
                result.maskingCardImage = config.markedCardImage
                result.maskingFrameImage = config.markedFrameImage
                result.frameImage = config.frameImage
                
                result.name = config.name ?? ""
                result.korIDNum = config.kor_id_num ?? ""
                result.licenseType = config.license_type ?? ""
                result.licenseNo = config.license_no ?? ""
                result.licenseNo_masking = config.license_no_masking ?? ""
                result.licenseSerial = config.license_serial ?? ""
                result.issuingDate = config.issuing_date ?? ""
                result.issuingRegion = config.issuing_region ?? ""
                result.overseasResident = config.overseas_resident
                result.validate = config.validate
                result.color_test = config.colorTest
                result.face_score = config.face_score
                result.specular_ratio = config.specular_ratio
                result.start_time = config.start_time
                result.end_time = config.end_time
                result.scanFrameList = config.scanFrameList as? Array<UIImage>

                if( ret == 3 ) {
                    debugPrint(result.name, result.korIDNum,
                               result.licenseType, result.licenseNo, result.licenseSerial,
                               result.issuingDate, result.issuingRegion, result.overseasResident,
                               config.id_card_type, result.scanFrameList?.count,
                               separator:" / ")
                    debugPrint(ret)
                }

            case 4:
                ret = ocrScanner?.scanAlienFrame(frame, config: config) ?? 0
                guard let config = config else { return }
                
                if( ret == 3 ) {
                    result.cardImage = config.cardImage
                    result.cardOrgImage = config.cardImage
                    result.idPhotoImage = config.photoImage
                    result.maskingCardImage = config.markedCardImage
                    result.maskingFrameImage = config.markedFrameImage
                    
                    result.face_score = config.face_score
                    result.specular_ratio = config.specular_ratio
                    
                    result.name = config.name ?? ""
                    result.korIDNum = config.kor_id_num ?? ""
                    result.issuingDate = config.issuing_date ?? ""
                    
                    print("Alien Card Scan Result : ")
                    print(String(format:"\tname : %@", result.name ?? "nil"))
                    print(String(format:"\tid-number : %@", result.korIDNum ?? "nil"))
                    print(String(format:"\tissuing date : %@", result.issuingDate ?? "nil"))
                    debugPrint(ret)
                }
            case 5:
                ret = ocrScanner?.scanPassportFrame(frame, config: config) ?? 0
                guard let config = config else { return }

                if( ret == 3 ) {
                    result.idPhotoImage = config.photoImage
                    result.cardImage = config.cardImage
                    result.maskingCardImage = config.markedCardImage
                    result.maskingFrameImage = config.markedFrameImage
                    
                    result.passportType = config.passport_type ?? ""
                    result.name = config.name
                    result.surName = config.surName
                    result.givenName = config.givenName
                    result.nameKor = config.name_kor
                    result.korIDNum = config.kor_id_num
                    result.issuingCountry = config.issuing_country
                    result.passportNo = config.passport_no
                    result.nationality = config.nationality
                    result.dateOfBirth = config.date_of_birth
                    result.sex = config.sex
                    result.expirtyDate = config.date_of_issue
                    result.personalNo = config.personal_no
                    result.issuingDate = config.issuing_date
                    result.mrz1 = config.mrz1
                    result.mrz2 = config.mrz2
                    result.validate = config.validate
                    
                    result.face_score = config.face_score
                    result.specular_ratio = config.specular_ratio
                    
                    result.scanFrameList = config.scanFrameList as? Array<UIImage>
                    
                    print("Alien Card Scan Result : ")
                    print(String(format:"\tname : %@", result.name ?? "nil"))
                    print(String(format:"\tpassport-number : %@", result.passportNo ?? "nil"))
                    print("\tframeCount : \(result.scanFrameList?.count)")
                    debugPrint(ret)
                }
                break
            case 11:
                ret = ocrScanner?.scanAlienBack(frame, config: config) ?? 0
                guard let config = config else { return }
                
                result.cardImage = config.cardImage;
                result.alienSerial = config.alienSerial ?? ""
                result.alienPermissionDate0 = config.alienPermissionDate0 ?? ""
                result.alienPermissionDate1 = config.alienPermissionDate1 ?? ""
                result.alienPermissionDate2 = config.alienPermissionDate2 ?? ""
                result.alienPermissionDate3 = config.alienPermissionDate3 ?? ""
                
                result.alienExpiryDate0 = config.alienExpiryDate0 ?? ""
                result.alienExpiryDate1 = config.alienExpiryDate1 ?? ""
                result.alienExpiryDate2 = config.alienExpiryDate2 ?? ""
                result.alienExpiryDate3 = config.alienExpiryDate3 ?? ""
                
                result.alienConfirmation0 = config.alienConfirmation0 ?? ""
                result.alienConfirmation1 = config.alienConfirmation1 ?? ""
                result.alienConfirmation2 = config.alienConfirmation2 ?? ""
                result.alienConfirmation3 = config.alienConfirmation3 ?? ""
                
                if( ret == 3 ) {
                    print("Alien Card Backside Scan Result : ")
                    print(String(format:"\talienSerial : %@", result.alienSerial ?? "nil"))
                    print(String(format:"\talienPermissionDate #0 : %@ to %@, %@",
                                 result.alienPermissionDate0 ?? "nil",
                                 result.alienExpiryDate0 ?? "nil",
                                 result.alienConfirmation0 ?? "nil"))
                    print(String(format:"\talienPermissionDate #1 : %@ to %@, %@",
                                 result.alienPermissionDate1 ?? "nil",
                                 result.alienExpiryDate1 ?? "nil",
                                 result.alienConfirmation1 ?? "nil"))
                    print(String(format:"\talienPermissionDate #2 : %@ to %@, %@",
                                 result.alienPermissionDate2 ?? "nil",
                                 result.alienExpiryDate2 ?? "nil",
                                 result.alienConfirmation2 ?? "nil"))
                    print(String(format:"\talienPermissionDate #3 : %@ to %@, %@",
                                 result.alienPermissionDate3 ?? "nil",
                                 result.alienExpiryDate3 ?? "nil",
                                 result.alienConfirmation3 ?? "nil"))
                    print(String(format:"\t scanner result : %d", ret))
                }
                break
            default: break
            }
            
            result.result = Int(ret)
            DispatchQueue.main.async { [weak self] in
                self?.sendFrameToDelegte(result)
            }
        }
    }
}

extension OcrCameraPreview {
    func sendFrameToDelegte(_ result: OcrScanResult) {
        guard previewOnGoing == true else { return }
        if let delegate = videoFrameDelegate {
            delegate.scanResult(result)
        }
    }
    
    var guideRect: CGRect {
        guard let config = config else { return CGRect.zero }
        guard let ocrScanner = ocrScanner else { return CGRect.zero }
        ocrScanner.getGuideFrameRect(config, width: Int32(preview.frame.size.width), height: Int32(preview.frame.size.height))
        return config.guideRect
    }
}

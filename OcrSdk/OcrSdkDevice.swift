//
//  OcrSdkDevice.swift
//  @MachineEyeSDK
//


import MachineEyeSDK
import UIKit
import MobileCoreServices

class OcrSdkDevice {
    private static func getSysInfoByName(infoSpecifier: String) -> String {
        var size = 0
        sysctlbyname(infoSpecifier, nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: size)
        sysctlbyname(infoSpecifier, &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    private static var is3GS: Bool {
        let platformName = self.platform
        let is3GS: Bool = platformName.hasPrefix("iPhone2")
        return is3GS
    }
    
    
    private static var platform: String {
        return OcrSdkDevice.getSysInfoByName(infoSpecifier: "hw.machine")
    }
    
    static var hasVideoCamera: Bool {
        guard UIImagePickerController
            .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true else { return false }
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera)
        let supportsVideo: Bool = availableMediaTypes?.contains((kUTTypeMovie as String)) ?? false
        return supportsVideo
    }
    
    static var shouldSetPixelFormat: Bool {
        return !self.is3GS
    }
    
}

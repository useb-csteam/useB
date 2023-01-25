//
//  OcrCameraPreviewDelegate.swift
//  @MachineEyeSDK
//


import Foundation

protocol OcrCameraPreviewDelegate: class {
    func scanResult(_ result: OcrScanResult)
}

//
//  ViewController.swift
//  SmartResnet50
//
//  Created by linwei on 2019/8/19.
//  Copyright © 2019 linwei. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
   
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        
        //
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{
            return
        }
        
        guard let input = try?AVCaptureDeviceInput(device: captureDevice)else{
            return
        }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.view.layer.addSublayer(previewLayer)
        self.topView.layer.addSublayer(previewLayer)
        
//        previewLayer.frame = self.view.frame
        previewLayer.frame = self.topView.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.zlinwei.videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("did output ",Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return
        }
        
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model)else{
            
            return
        }
        let request  = VNCoreMLRequest(model: model) { (finishedReq, err) in
        
            guard let results = finishedReq.results as?
            [VNClassificationObservation] else{
                return
            }
            
            guard let firstObservation = results.first else{
                return
            }
            
            print(firstObservation.identifier,firstObservation.confidence)
            
            
            DispatchQueue.main.async {
                self.label.text = "  " + firstObservation.identifier + ":" + String(firstObservation.confidence)
                
            }
            
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
    
//    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//
//        print("did drop",Date())
//
//
//    }


}


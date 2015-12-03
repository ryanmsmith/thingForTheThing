//
//  ViewController.swift
//  ThingForTheThing
//
//  Created by Ryan Smith on 12/3/15.
//  Copyright © 2015 indiePixel. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    let audioSession = AVAudioSession()
    let audioDataOutput = AVCaptureAudioDataOutput()
    let audioCaptureSession = AVCaptureSession()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch _ {
        }
        do {
            try audioSession.setMode(AVAudioSessionModeMeasurement)
        } catch _ {
        }
        do {
            try audioSession.setActive(true)
        } catch _ {
        }
        do {
            try audioSession.setPreferredSampleRate(48000)
        } catch _ {
        }
        
        let myDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        let audioCaptureInput = try? AVCaptureDeviceInput(device: myDevice)
        
        audioCaptureSession.addInput(audioCaptureInput)
        
        audioDataOutput.setSampleBufferDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
        
        audioCaptureSession.addOutput(audioDataOutput)
        
        audioCaptureSession.startRunning()
        
        view.addSubview(powerCircle)
        powerCircle.backgroundColor = UIColor.blueColor()
    }
    
    
    let powerCircle = UIView()
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        for channel in connection.audioChannels as! [AVCaptureAudioChannel] {
            
            
            let pLevel = CGFloat((channel.averagePowerLevel + 50) * 2)
            
            if channel.averagePowerLevel > -10 {
                
                //blow bubble
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    
                    let bubble = UIView(frame: CGRectMake(0, 0, 50, 50))
                    
                    let hue = CGFloat(arc4random_uniform(285)) / 255
                    bubble.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 3, alpha: 0.4)
                    bubble.layer.cornerRadius = 24
                    bubble.alpha = 0.5
                    bubble.center = CGPointMake(self.view.center.x, self.view.frame.height)
                    self.view.addSubview(bubble)
                    
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        let x = arc4random_uniform(UInt32(self.view.frame.width))
                        let y = self.view.frame.height - pLevel * 6
                        bubble.center = CGPointMake(CGFloat(x), y)
                        //bubble.center = self.view.center
                        
                        }, completion: { (success) -> Void in
                            
                            //bubble.removeFromSuperview()
                            
                    })
                    
                    
                })
                
            }
            
            
            
            
            print("Audio Power Level = \(channel.averagePowerLevel) & Peak Hold Level = \(channel.peakHoldLevel)")
        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesBegan(touches!, withEvent: event)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



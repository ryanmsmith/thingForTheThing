//
//  ViewController.swift
//  ThingForTheThing
//
//  Created by Ryan Smith on 12/3/15.
//  Copyright © 2015 indiePixel. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, BubbleDelegate {
    
    let audioSession = AVAudioSession()
    let audioDataOutput = AVCaptureAudioDataOutput()
    let audioCaptureSession = AVCaptureSession()
    
    var animator: UIDynamicAnimator?
    let bubbleBehavior: UIDynamicItemBehavior = UIDynamicItemBehavior()
    let collisionBehavior: UICollisionBehavior = UICollisionBehavior()
    
    var bubbles: [Bubble] = []
    
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
        
        bubbleBehavior.elasticity = 0.5
        bubbleBehavior.friction = 0.5
        bubbleBehavior.resistance = 0.5
        
        
        animator = UIDynamicAnimator(referenceView: view)
        animator?.addBehavior(collisionBehavior)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(bubbleBehavior)
        

    }
    
    
    let powerCircle = UIView()
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        for channel in connection.audioChannels as! [AVCaptureAudioChannel] {
            if channel.averagePowerLevel > -20 {
                
                //blow bubble
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let pLevel = CGFloat(((400 - (channel.averagePowerLevel) * (channel.averagePowerLevel)) / 10.0))//CGFloat(channel.averagePowerLevel + 40)
                    
                    let bubble = Bubble(frame: CGRectMake(0, 0, pLevel, pLevel))
                    bubble.delegate = self
                    
                    let hue = CGFloat(arc4random_uniform(285)) / 255
                    bubble.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 3, alpha: 0.4)
                    bubble.layer.cornerRadius = bubble.bounds.size.width / 2.0
                    bubble.alpha = 0.5
                    bubble.center = CGPointMake(self.view.center.x, self.view.frame.height)
                    self.view.addSubview(bubble)
                    self.bubbles.append(bubble) 
                    
                    self.collisionBehavior.addItem(bubble)
                    self.bubbleBehavior.addItem(bubble)
                    
                    let push = UIPushBehavior(items: [bubble], mode: UIPushBehaviorMode.Instantaneous)
//                    push.pushDirection = CGVectorMake(CGFloat((Double(arc4random()) / 0x100000000) * (1.0 - -1.0) + -1.0), CGFloat(channel.averagePowerLevel / Float(50.0)))
                    let angle = CGFloat((Double(arc4random()) / 0x100000000) * (3 * M_PI_4 - M_PI_4) + M_PI_4)
                    let force = CGFloat(((400 - (channel.averagePowerLevel) * (channel.averagePowerLevel)) / 400.0))
                    NSLog("force: \(force) | angle: \(angle)")
                    push.angle = angle
                    push.magnitude = force
                    self.animator?.addBehavior(push)
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesBegan(touches!, withEvent: event)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeBubble(bubble: Bubble) {
        bubbles.removeAtIndex(bubbles.indexOf(bubble)!)
        collisionBehavior.removeItem(bubble)
        bubbleBehavior.removeItem(bubble)
        bubble.removeFromSuperview()
    }
    
}



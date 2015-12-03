//
//  ViewController.swift
//  ThingForTheThing
//
//  Created by Ryan Smith on 12/3/15.
//  Copyright © 2015 indiePixel. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, BubbleDelegate {
    
    let audioSession = AVAudioSession()
    let audioDataOutput = AVCaptureAudioDataOutput()
    let audioCaptureSession = AVCaptureSession()
    var snappers = [UIView: UISnapBehavior]()
    var animator: UIDynamicAnimator?
    let bubbleBehavior: UIDynamicItemBehavior = UIDynamicItemBehavior()
    let collisionBehavior: UICollisionBehavior = UICollisionBehavior()
    var bgColor = UIColor(hue: 1, saturation: 0.5, brightness: 0.9, alpha: 1.0)
    var frameTime = 0.0
    
    let motionManager = CMMotionManager()
    
    var bubbles: [Bubble] = []

    override func viewDidLoad() {
        super.viewDidLoad()
       
        NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "changeColor", userInfo: nil, repeats: true)

        
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
        
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { (motion: CMDeviceMotion?, error: NSError?) -> Void in
            
        }
        
    }
    
    
    func changeColor() {
        // How much time has passed since the last frame?
        let dt = CACurrentMediaTime() - frameTime
        
        var hue = CGFloat(0.0)
        var saturation = CGFloat(0.0)
        var brightness = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        if(bgColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)) {
            hue -= CGFloat(dt*0.1)
            bgColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            self.view.backgroundColor = bgColor
        }
        frameTime = CACurrentMediaTime()
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
//                    bubble.layer.borderWidth = 0.5
//                    bubble.layer.borderColor = bubble.backgroundColor?.colorWithAlphaComponent(1.0).CGColor
                    bubble.alpha = 1.0
                    bubble.center = CGPointMake(self.view.center.x, self.view.frame.height)
                    self.view.addSubview(bubble)

                    
                    bubble.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDrag:"))

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

  print("Audio Power Level = \(channel.averagePowerLevel) & Peak Hold Level = \(channel.peakHoldLevel)")

        }
    }
   func onDrag(recognizer: UIPanGestureRecognizer) {
        if let bubView = recognizer.view {
     
            if let snapper = snappers[bubView] {
                animator!.removeBehavior(snapper)
                snappers[view] = nil
            }
      
            if recognizer.state == .Changed {
                let snapper = UISnapBehavior(
                    item: bubView,
                    snapToPoint: recognizer.locationInView(self.view)
                )
                
                // Save the snapping behaviour in the dictionary so we can remove it when the finger moves next time.
                snappers[bubView] = snapper
                snapper.damping = 3
                animator!.addBehavior(snapper)
            }
        }
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



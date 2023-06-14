//
//  ViewController.swift
//  VoiceAnimator
//
//  Created by Ted Barnett on 6/14/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var timer: Timer?
    var circles: [UIView] = []
    
    @IBOutlet weak var myButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup audio recorder
        setupAudioRecorder()

        // Start updating
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateAmplitude), userInfo: nil, repeats: true)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure the button is not transparent and has a border
        myButton.alpha = 1.0
        myButton.layer.borderWidth = 2  // Set the border width
        myButton.layer.borderColor = UIColor.white.cgColor  // Set the border color
        myButton.layer.cornerRadius = 10  // Set the corner radius
        myButton.backgroundColor = .black  // Set the interior color
        myButton.setTitleColor(.cyan, for: .normal)  // Set the text color
    }

    
    func setupAudioRecorder() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
    }
    

    @objc func updateAmplitude() {
        audioRecorder.updateMeters()
        
        // Get average amplitude
        let decibels = audioRecorder.averagePower(forChannel: 0)
        let linear = pow(10.0, decibels / 20.0)
        
        // Update circle size
        let minSize: CGFloat = 50.0
        let maxSize: CGFloat = 400.0
        let size = minSize + (maxSize - minSize) * CGFloat(linear)
        
        // Define the minimum sound threshold
        let minSound: Float = 0.1  // Change this to increase/decrease the threshold
        
        // Create a new circle at the bottom 20% of the screen only if the volume is above minSound
        if linear > minSound {
            let circleView = UIView(frame: CGRect(x: view.center.x - size/2, y: view.bounds.height * 0.8 - size/2, width: size, height: size))
            circleView.backgroundColor = .clear  // make the background clear
            circleView.layer.borderWidth = 3    // set the border width
            circleView.layer.borderColor = UIColor.red.cgColor  // set the border color
            circleView.layer.cornerRadius = size / 2
            view.insertSubview(circleView, belowSubview: myButton)
            circles.append(circleView)
        }
        
        // Drift older circles upwards and fade them out
        let driftSpeed: CGFloat = 1  // Change this to increase/decrease speed
        let fadeSpeed: CGFloat = 0.01  // Change this to increase/decrease fade speed
        for circle in circles {
            circle.center.y -= driftSpeed
            circle.alpha -= fadeSpeed
        }
        
        // Optional: remove circles that have drifted off the screen or become fully transparent
        circles = circles.filter { $0.frame.intersects(view.frame) && $0.alpha > 0 }
    }
}


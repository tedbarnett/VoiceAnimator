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
    var circleView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Draw initial circle
        let circleSize: CGFloat = 50.0
        circleView = UIView(frame: CGRect(x: view.center.x - circleSize/2, y: view.center.y - circleSize/2, width: circleSize, height: circleSize))
        circleView.backgroundColor = .clear  // make the background clear
        circleView.layer.borderWidth = 3    // set the border width
        circleView.layer.borderColor = UIColor.red.cgColor  // set the border color
        circleView.layer.cornerRadius = circleSize / 2
        view.addSubview(circleView)

        
        // Setup audio recorder
        setupAudioRecorder()
        
        // Start updating
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateAmplitude), userInfo: nil, repeats: true)
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
        let maxSize: CGFloat = 400.0  // Doubled the maximum size
        let size = minSize + (maxSize - minSize) * CGFloat(linear)
        circleView.frame = CGRect(x: view.center.x - size/2, y: view.center.y - size/2, width: size, height: size)
        circleView.layer.cornerRadius = size / 2
    }

}

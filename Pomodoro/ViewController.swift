//
//  ViewController.swift
//  Pomodoro
//
//  Created by Yujean Cho on 2022/06/13.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
    // default 25 minutes (1500 seconds)
    var duration = 1500
    
    var timerStatus: TimerStatus = .end
    
    var timer: DispatchSourceTimer?
    
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerLabel.text = "25:00" // TODO: Settings value 로 수정하기
        self.setToggleButton()
    }
    
    func setToggleButton() {
        self.toggleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.toggleButton.setTitle("Start", for: .normal)
        self.toggleButton.setTitle("Pause", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            
            self.timer?.schedule(deadline: .now(), repeating: 1)
            
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let minutes = (self.currentSeconds % 3600) / 60
                let secondes = (self.currentSeconds % 3600) % 60
                
                self.timerLabel.text = String(format: "%02d:%02d", minutes, secondes)
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.timerLabel.text = "25:00" // TODO: Settings value 로 수정하기
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            
            self.toggleButton.isSelected = true
            self.startTimer()
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
        }
    }
}

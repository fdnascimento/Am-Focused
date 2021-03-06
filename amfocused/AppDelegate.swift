//
//  AppDelegate.swift
//  amfocused
//
//  Created by Denis Nascimento on 25/01/17.
//  Copyright © 2017 Denis Nascimento. All rights reserved.
//

import Cocoa
import AudioToolbox
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var boxView: NSBox!
    
    
    let statusItem = NSStatusBar.system.statusItem(withLength: -2)
    let popover = NSPopover()
    var timer = Timer()
    
    var player: AVAudioPlayer?
    
    let urlClockTicking = Bundle.main.url(forResource: "clock-ticking-2", withExtension: "wav")!
    
    var minutesDefault = 25*60
    var counterDefault = 25*60
    var counter = 0
    var enabledSound = false
    var stringTime = String()
    
    
    
    @IBOutlet weak var labelClock: NSTextField!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
            button.action = #selector(togglePopover(sender:))
        }
        
        popover.contentViewController = MainViewController(nibName: NSNib.Name(rawValue: "MainViewController"), bundle: nil)
        
        NSApp.activate(ignoringOtherApps: false)
        //[self.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
        
        
        window.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        
        window.setFrame(NSMakeRect(0, (NSScreen.main!.frame.height-60),NSScreen.main!.frame.width, 60), display: true)
        window.ignoresMouseEvents = true
        window.setIsVisible(false)
        
        
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func colorChange() -> Void {
        print("colorChange")
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    func showPopover(sender: AnyObject?) {
        
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    @objc func togglePopover(sender: AnyObject?) {
        print("togglePopover")
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func startInterval(){
        startClock(green: true)
    }
    
    func startPomodore() {
        startClock(green: false)
    }
    
    func startClock(green: Bool) {
        
        if timer.isValid {
            timer.invalidate()
        } else {
            timer  = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            togglePopover(sender: nil)
            window.setIsVisible(true)
            setupView(green: green)
        }
    }
    
    @objc func updateCounter() {
        
        if counter == counterDefault {
            stopTime()
            return
        }
        
        counter += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: counterDefault-counter)
        stringTime = "0\(h):\(m):\(s)"
        labelClock.stringValue = stringTime
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    func stopTime() {
        
        timer.invalidate()
        counter = 0
        window.setIsVisible(false)
        setupView(green: true)
        labelClock.stringValue = "00:00:00"
        playSound()
    }
    
    func setupView(green: Bool) -> Void {
        
        if green {
            window.backgroundColor = NSColor.init(calibratedRed: 0.385, green: 0.637, blue: 0.341, alpha: 1.00)
        }else{
            window.backgroundColor = NSColor.red
        }
        window.alphaValue = 0.6
    }
    
    
    func playSound() {

        if ( player != nil && (player?.isPlaying)!) {
            player?.pause()
        } else{
            do {
                player = try AVAudioPlayer(contentsOf: urlClockTicking)
                player?.numberOfLoops = -1
                player?.prepareToPlay()
                if enabledSound {
                    player?.play()
                }
            } catch let error as NSError {
                print(error.description)
            }
        }
        
    }
    
    
}


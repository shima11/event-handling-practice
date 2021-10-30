//
//  event_handling_practiceApp.swift
//  event-handling-practice
//
//  Created by Jinsei Shima on 2021/10/23.
//

import SwiftUI
import AVFoundation

// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_route_changes
// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions
// https://qiita.com/_daisuke0802/items/d6f68f3c5cc021bba7c5#4-%E3%83%98%E3%83%83%E3%83%89%E3%83%95%E3%82%A9%E3%83%B3%E3%81%AE%E6%8A%9C%E3%81%8D%E5%B7%AE%E3%81%97
// https://nackpan.net/blog/2015/09/29/ios-swift-phone-call-and-route-change/

@main
struct event_handling_practiceApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView(store: appDelegate.store)
    }
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

  let store = DefaultsStore()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    let session = AVAudioSession.sharedInstance()
    try! session.setActive(true, options: .notifyOthersOnDeactivation)

    let center = NotificationCenter.default

    // MARK: AVAudioSession

    center.addObserver(self, selector: #selector(interruptionNotification(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    center.addObserver(self, selector: #selector(routeChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    center.addObserver(self, selector: #selector(mediaServicesWereLostNotification(_:)), name: AVAudioSession.mediaServicesWereLostNotification, object: nil)
    center.addObserver(self, selector: #selector(mediaServicesWereResetNotification(_:)), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
    center.addObserver(self, selector: #selector(silenceSecondaryAudioHintNotification(_:)), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil)
    center.addObserver(self, selector: #selector(spatialPlaybackCapabilitiesChangedNotification(_:)), name: AVAudioSession.spatialPlaybackCapabilitiesChangedNotification, object: nil)

    return true
  }

  @objc func interruptionNotification(_ notification: NSNotification) {
    guard
      let userInfo = notification.userInfo,
      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
        return
      }

    if type == .began {
      // interruptionが開始した時(電話がかかってきたなど)
      store.handleInterruptionText = "handle interruption: began"
    }
    else if type == .ended {
      // interruptionが終了した時の処理
      if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
        if options.contains(.shouldResume) {
          // Interruption Ended - playback should resume
          store.handleInterruptionText = "handle interruption: ended should resume"
        } else {
          // Interruption Ended - playback should NOT resume
          store.handleInterruptionText = "handle interruption: ended should not resume"
        }
      }
    }
  }

  @objc func routeChangeNotification(_ notification: NSNotification) {
    guard
      let userInfo = notification.userInfo,
      let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
      let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
        return
      }

    switch reason {
    case .newDeviceAvailable:
      store.audioSessionRouteChangedText = "audio session route changed: newDeviceAvailable"
      let currentRoute = AVAudioSession.sharedInstance().currentRoute
      for output in currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
        // ヘッドフォンがつながった
        store.audioSessionRouteChangedText = "audio session route changed: available headphones"
        break
      }
    case .oldDeviceUnavailable:
      print("audio session route changed: oldDeviceUnavailable")
      if let previousRoute =
          userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
        for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
          // ヘッドフォンが外れた
          store.audioSessionRouteChangedText = "audio session route changed: unavailable headphones"
          break
        }
      }
    case .unknown:
      store.audioSessionRouteChangedText = "audio session route changed: unknown"
    case .categoryChange:
      store.audioSessionRouteChangedText = "audio session route changed: categoryChanged"
    case .override:
      store.audioSessionRouteChangedText = "audio session route changed: override"
    case .wakeFromSleep:
      store.audioSessionRouteChangedText = "audio session route changed: wakeFromSleep"
    case .noSuitableRouteForCategory:
      store.audioSessionRouteChangedText = "audio session route changed: noSuitableRouteForCategory"
    case .routeConfigurationChange:
      store.audioSessionRouteChangedText = "audio session route changed: routeConfigurationChanged"
    @unknown default:
      break
    }
  }

  @objc func mediaServicesWereLostNotification(_ notification: NSNotification) {

  }
  @objc func mediaServicesWereResetNotification(_ notification: NSNotification) {

  }
  @objc func silenceSecondaryAudioHintNotification(_ notification: NSNotification) {

  }
  @objc func spatialPlaybackCapabilitiesChangedNotification(_ notification: NSNotification) {

  }

}

class DefaultsStore: ObservableObject {

  @Published var audioSessionRouteChangedText: String = "none"
  @Published var handleInterruptionText: String = "none"

  init() {

  }
}

//
//  event_handling_practiceApp.swift
//  event-handling-practice
//
//  Created by Jinsei Shima on 2021/10/23.
//

import SwiftUI
import AVFoundation

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

    center.addObserver(
      self,
      selector: #selector(handleInterruption(_:)),
      name: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance
    )

    center.addObserver(
      self,
      selector: #selector(audioSessionRouteChanged(_:)),
      name: AVAudioSession.routeChangeNotification,
      object: nil
    )

    return true
  }

  @objc
  func handleInterruption(_ notification: NSNotification) {
    print("handleInterruption:", notification)
//    store.handleInterruptionText = 
  }

  @objc
  func audioSessionRouteChanged(_ notification: NSNotification) {

    print("audio session route changed:")

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

}

class DefaultsStore: ObservableObject {

  @Published var audioSessionRouteChangedText: String = "none"
  @Published var handleInterruptionText: String = "none"

  init() {

  }
}

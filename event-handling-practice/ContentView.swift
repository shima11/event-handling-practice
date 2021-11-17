//
//  ContentView.swift
//  event-handling-practice
//
//  Created by Jinsei Shima on 2021/10/23.
//

import SwiftUI

struct ContentView: View {

  @ObservedObject var store: DefaultsStore

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Text("audio session route changed:\n").bold() + Text(store.audioSessionRouteChangedText)
            Spacer()
          }
          HStack {
            Text("interruption:\n").bold() + Text(store.handleInterruptionText)
            Spacer()
          }
          Button("Open Settings") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
        }
        .padding()
      }
      .navigationTitle(Text("Event Handling Practice"))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: .init())
  }
}

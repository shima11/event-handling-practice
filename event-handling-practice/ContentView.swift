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
    VStack {
      Text("Event Handling Practice")
        .font(.title)
      Text(store.audioSessionRouteChangedText)
      Text(store.handleInterruptionText)
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: .init())
  }
}

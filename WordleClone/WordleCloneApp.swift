//
//  WordleCloneApp.swift
//  WordleClone
//
//  Created by JD Bartee on 1/17/22.
//

import SwiftUI

@main
struct WordleCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(WordleStore())
        }
    }
}

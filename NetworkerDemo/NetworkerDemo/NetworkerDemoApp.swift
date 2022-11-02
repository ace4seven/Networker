//
//  NetworkerDemoApp.swift
//  NetworkerDemo
//
//  Created by Juraj Macák on 01/11/2022.
//

import SwiftUI
import Networker

@main
struct NetworkerDemoApp: App {

    init() {
        NetworkerConfiguration.logLevel = .verbose
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

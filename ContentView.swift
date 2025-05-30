//
//  ContentView.swift
//  mdsync
//
//  Created by zeparchan on 30/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainView()
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isLoggedIn)
    }
}

#Preview {
    ContentView()
}

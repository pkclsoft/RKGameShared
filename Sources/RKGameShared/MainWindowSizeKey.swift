//
//  MainWindowSizeKey.swift
//  RKGameShared
//
//  Created by Peter Easdown on 4/8/2025.
//

// from: https://stackoverflow.com/a/71970454/880807
import SwiftUI

struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

public extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
}

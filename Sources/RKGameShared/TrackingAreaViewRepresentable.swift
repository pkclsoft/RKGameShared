//
//  TrackingAreaViewRepresentable.swift
//  SKGameShared
//
//  Created by Peter Easdown on 25/8/2025.
//
// from: https://levelup.gitconnected.com/swiftui-macos-nstrackingview-for-mouse-enter-and-mouse-exit-91cb3d688e3b
//
#if os(macOS)
import SwiftUI

public struct TrackingAreaViewRepresentable: NSViewRepresentable {

    public func updateNSView(_ nsView: TrackingView, context: Context) {}

    public func makeNSView(context: Context) -> TrackingView {
        let view = TrackingView()
        
        return view
    }
}
#endif

//
//  TrackingView.swift
//  RKGameShared
//
//  Created by Peter Easdown on 25/8/2025.
//
// from: https://levelup.gitconnected.com/swiftui-macos-nstrackingview-for-mouse-enter-and-mouse-exit-91cb3d688e3b
//
#if os(macOS)
import SwiftUI

public class TrackingView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.addTrackingArea(NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .mouseMoved],
            owner: self, userInfo: nil)
        )
    }
}
#endif

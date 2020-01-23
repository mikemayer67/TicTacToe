//
//  ConfigView.swift
//
//  Created by Mike Mayer on 1/17/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Cocoa

class ConfigView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

      NSColor(calibratedWhite: 0.25, alpha: 0.75).setFill()
      self.bounds.fill()
      NSColor.black.setStroke()
      NSBezierPath(rect:bounds).stroke()
      for i : CGFloat in [0.125, 0.25, 0.375, 0.50, 0.625, 0.75, 0.875]
      {
        NSColor(calibratedWhite: i, alpha: 1.0).setStroke()
        NSBezierPath(rect:bounds.insetBy(dx: 8*i, dy:8*i)).stroke()
      }
    }
    
}

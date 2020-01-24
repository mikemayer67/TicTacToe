//
//  ConfigView.swift
//  iTicTacToe
//
//  Created by Mike Mayer on 1/23/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class ConfigView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)

      UIColor.black.setStroke()
      UIBezierPath(rect:bounds).stroke()
    }

}

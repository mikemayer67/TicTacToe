//
//  BoardView.swift
//  iTicTacToe
//
//  Created by Mike Mayer on 1/23/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

let gridPad  : CGFloat = 0.05
let gridSize : CGFloat = 1.0 - 2 * gridPad
let cellPad  : CGFloat = 0.05
let cellSize : CGFloat = gridSize / 3
let markSize : CGFloat = cellSize - 2 * cellPad

class BoardView: UIView
{
  var board : Board?
  {
    didSet { setNeedsDisplay(bounds) }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let xo = gridPad * frame.width
    let yo = gridPad * frame.height
    let cellWidth = cellSize * frame.width
    let cellHeight = cellSize * frame.height
    let mxo = xo + cellPad * frame.width
    let myo = yo + cellPad * frame.height
    let markWidth = markSize * frame.width
    let markHeight = markSize * frame.height
    
    var bgColor = UIColor.white
    var fgColor = UIColor.black
    
    if let state = board?.state {
      switch state
      {
      case .PreGame:
        fgColor = UIColor(white: 0.5, alpha: 1.0)
      case .TieGame:
        bgColor = UIColor.black
        fgColor = UIColor.white
      case .Winner(let winner as Player):
        bgColor = UIColor.black
        switch winner.type {
        case .Human  : fgColor = UIColor.green
        case .Robot  : fgColor = UIColor.red
        case .Remote : fgColor = UIColor.yellow
        }
      default:
        break;
      }
    }
        
    let bgPath = UIBezierPath(rect: frame)
    bgColor.set()
    bgPath.fill()
    
    let fgPath = UIBezierPath()
    fgPath.move   (to: CGPoint(x:xo              , y:yo +   cellHeight))
    fgPath.addLine(to: CGPoint(x:xo + 3*cellWidth, y:yo +   cellHeight))
    fgPath.move   (to: CGPoint(x:xo              , y:yo + 2*cellHeight))
    fgPath.addLine(to: CGPoint(x:xo + 3*cellWidth, y:yo + 2*cellHeight))
    fgPath.move   (to: CGPoint(x:xo +   cellWidth, y:yo               ))
    fgPath.addLine(to: CGPoint(x:xo +   cellWidth, y:yo + 3*cellHeight))
    fgPath.move   (to: CGPoint(x:xo + 2*cellWidth, y:yo               ))
    fgPath.addLine(to: CGPoint(x:xo + 2*cellWidth, y:yo + 3*cellHeight))
    fgPath.lineWidth=3
    fgColor.set()
    fgPath.stroke()
    
    for i in 0...1
    {
      if let mark = board?.players[i].mark, let marks = board?.marks[i]
      {
        for cell in Grid.Cell.allCases
        {
          if marks & cell.rawValue == cell.rawValue
          {
            let (row,col) = cell.coord

            let x = mxo + CGFloat(col) * cellWidth
            let y = myo + CGFloat(row) * cellHeight
            
            let path = UIBezierPath()
            
            switch mark {
            case .X:
              path.move   (to: CGPoint(x:x,           y:y            ))
              path.addLine(to: CGPoint(x:x+markWidth, y:y+markHeight ))
              path.move   (to: CGPoint(x:x,           y:y+markHeight ))
              path.addLine(to: CGPoint(x:x+markWidth, y:y            ))
            case .O:
              path.append(UIBezierPath(ovalIn: CGRect(x:x, y:y, width:markWidth, height:markHeight)))
            }
            
            fgColor.set()
            path.stroke()
          }
        }
      }
    }
  }
  
  func cell(at touch:CGPoint) -> Grid.Cell?
  {
    let col = Int( ( touch.x/frame.width  - gridPad ) / cellSize )
    let row = Int( ( touch.y/frame.height - gridPad ) / cellSize )
    
    if col >= 0, col < 3, row >= 0, row < 3 {
      return Grid.cell(coord:(row,col))
    }
    
    return nil
  }
}

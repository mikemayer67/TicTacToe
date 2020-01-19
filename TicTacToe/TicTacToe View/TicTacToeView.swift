//
//  GridView.swift
//  TicTacToe
//
//  Created by Mike Mayer on 1/4/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Cocoa
import GameplayKit

let gridPad  : CGFloat = 0.05
let gridSize : CGFloat = 1.0 - 2 * gridPad
let cellPad  : CGFloat = 0.05
let cellSize : CGFloat = gridSize / 3
let markSize : CGFloat = cellSize - 2 * cellPad

class TicTacToeView: NSView
{
  private(set) var marks : [TicTacToePlayer.Mark?] = Array(repeating: nil, count: 9)
  
  private(set) var bgColor = NSColor.white
  private(set) var fgColor = NSColor.black
  
  func setState(_ state : AIGameState)
  {
    switch state
    {
    case .PreGame:
      bgColor = NSColor.white
      fgColor = NSColor(calibratedWhite: 0.5, alpha: 1.0)
    case .PlayerTurn:
      bgColor = NSColor.white
      fgColor = NSColor.black
    case .TieGame:
      bgColor = NSColor.black
      fgColor = NSColor.white
    case .Winner(let winner as TicTacToePlayer):
      bgColor = NSColor.black
      fgColor = ( winner.isAIGameBot ? NSColor.red : NSColor.green )
    case .Winner(_):
      fatalError("Non TicTacToe player won the game...")
    }
    
    self.setNeedsDisplay(frame)
  }
  
  func setMark(_ mark:TicTacToePlayer.Mark, at cell:TicTacToeGrid.Cell)
  {
    let (row,col) = cell.coord
    marks[3*row+col] = mark
    
    self.setNeedsDisplay(frame)
  }
  
  func clearMark(at cell:TicTacToeGrid.Cell)
  {
    let (row,col) = cell.coord
    marks[3*row+col] = nil
    
    self.setNeedsDisplay(frame)
  }
  
  func reset()
  {
    setState(.PreGame)
    for r in 0...2 {
      for c in 0...2 {
        marks[3*r+c] = nil
      }
    }
    self.setNeedsDisplay(frame)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let xo = gridPad * frame.width
    let yo = gridPad * frame.height
    let cellWidth = cellSize * frame.width
    let cellHeight = cellSize * frame.height
    let mxo = xo + cellPad * frame.width
    let myo = yo + cellPad * frame.height
    let markWidth = markSize * frame.width
    let markHeight = markSize * frame.height
        
    let bgPath = NSBezierPath(rect: frame)
    bgColor.set()
    bgPath.fill()
    
    let fgPath = NSBezierPath()
    fgPath.move(to: NSPoint(x:xo              , y:yo +   cellHeight))
    fgPath.line(to: NSPoint(x:xo + 3*cellWidth, y:yo +   cellHeight))
    fgPath.move(to: NSPoint(x:xo              , y:yo + 2*cellHeight))
    fgPath.line(to: NSPoint(x:xo + 3*cellWidth, y:yo + 2*cellHeight))
    fgPath.move(to: NSPoint(x:xo +   cellWidth, y:yo               ))
    fgPath.line(to: NSPoint(x:xo +   cellWidth, y:yo + 3*cellHeight))
    fgPath.move(to: NSPoint(x:xo + 2*cellWidth, y:yo               ))
    fgPath.line(to: NSPoint(x:xo + 2*cellWidth, y:yo + 3*cellHeight))
    fgPath.lineWidth=3
    fgColor.set()
    fgPath.stroke()
    
    for row in 0...2 {
      for col in 0...2 {
        if let mark = marks[3*row+col] {
          let x = mxo + CGFloat(col) * cellWidth
          let y = myo + CGFloat(row) * cellHeight
          
          let path = NSBezierPath()
          switch mark {
          case .X:
            path.move(to: NSPoint(x:x,           y:y            ))
            path.line(to: NSPoint(x:x+markWidth, y:y+markHeight ))
            path.move(to: NSPoint(x:x,           y:y+markHeight ))
            path.line(to: NSPoint(x:x+markWidth, y:y            ))
          case .O:
            path.append(NSBezierPath(ovalIn: CGRect(x:x, y:y, width:markWidth, height:markHeight)))
          }
          
          fgColor.set()
          path.stroke()
        }
      }
    }
  }
  
  func cell(at touch:NSPoint) -> TicTacToeGrid.Cell?
  {
    let col = Int( ( touch.x/frame.width  - gridPad ) / cellSize )
    let row = Int( ( touch.y/frame.height - gridPad ) / cellSize )
    
    if col >= 0, col < 3, row >= 0, row < 3 {
      return TicTacToeGrid.cell(coord:(row,col))
    }
    
    return nil
  }
  
}

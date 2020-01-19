//
//  Grid.swift
//
//  Created by Mike Mayer on 1/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class Grid
{
  typealias Coord = (Int,Int)
  
  enum Cell : UInt16, CaseIterable, VMGameBotMove
  {
    case NW =   1
    case N  =   2
    case NE =   4
    case W  =   8
    case X  =  16
    case E  =  32
    case SW =  64
    case S  = 128
    case SE = 256
    
    var string : String {
      switch self
      {
      case .NW: return "NW"
      case .N:  return "N"
      case .NE: return "NE"
      case .W:  return "W"
      case .X:  return "center"
      case .E:  return "E"
      case .SW: return "SW"
      case .S:  return "S"
      case .SE: return "SE"
      }
    }
    
    var coord : Coord {
      switch self
      {
      case .NW: return (2,0)
      case .N:  return (2,1)
      case .NE: return (2,2)
      case .W:  return (1,0)
      case .X:  return (1,1)
      case .E:  return (1,2)
      case .SW: return (0,0)
      case .S:  return (0,1)
      case .SE: return (0,2)
      }
    }
  }

  static func mask(_ cells : Cell...) -> UInt16
  {
    return cells.reduce(0) { (mask,cell) in mask | cell.rawValue }
  }
  
  static let winMasks = [
    mask(.NW,.N,.NE),
    mask(.W,.X,.E),
    mask(.SW,.S,.SE),
    mask(.NW,.W,.SW),
    mask(.N,.X,.S),
    mask(.NE,.E,.SE),
    mask(.NW,.X,.SE),
    mask(.NE,.X,.SW)
  ]
  
  static let tieMask = mask(.NW,.N,.NE,.W,.X,.E,.SW,.S,.SE)
  
  static func cell(coord : Coord?) -> Cell?
  {
    if coord != nil
    {
      switch coord!
      {
      case (2,0): return .NW
      case (2,1): return .N
      case (2,2): return .NE
      case (1,0): return .W
      case (1,1): return .X
      case (1,2): return .E
      case (0,0): return .SW
      case (0,1): return .S
      case (0,2): return .SE
      default: break
      }
    }
    return nil
  }
}

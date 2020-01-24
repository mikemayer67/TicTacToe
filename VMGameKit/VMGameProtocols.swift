//
//  VMGameProtocols.swift
//
//  The protocols used by games compliant with the VMGameKit
//
//  Created by Mike Mayer on 1/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum VMGamePlayerType
{
  case Human
  case Robot
  case Remote
}

class VMGamePlayer : Equatable
{
  static func == (lhs: VMGamePlayer, rhs: VMGamePlayer) -> Bool {
    return lhs.id == rhs.id
  }
  
  let id : Int
  let type : VMGamePlayerType
  
  static var nextId : Indexer = 0
  
  init(as type:VMGamePlayerType = .Human)
  {
    self.id = VMGamePlayer.nextId.next()
    self.type = type
  }
}

enum VMGameState
{
  case PreGame
  case PlayerTurn(VMGamePlayer)
  case Winner(VMGamePlayer)
  case TieGame
  
  var done : Bool
  {
    switch self
    {
    case .Winner, .TieGame: return true
    default:                return false
    }
  }
}

protocol VMGameModel
{
  var state : VMGameState { get }
  
  // player whose turn it is
  var currentPlayer : VMGamePlayer? { get }
}

// This is an empty protocol.  It is up to the game model to create a class that
//  implements it and adds useful propertys and/or methods.

protocol VMGameBotMove
{
}

// The class used by the VMGameBot to model the game state must conform to
//   the AIGameModel protocol.

protocol AIGameModel : AnyObject, NSCopying, VMGameModel
{
  // available moves for the specified player (nil if no moves possible)
  var availableMoves : [VMGameBotMove]? { get }
  
  // The reset method should be used to update the state of the game model match the specified state
  //   This includes all dynamic properties that result from a given sequence of moves between start and latest move
  //   This does not include any static game play parameters (players, turn order, etc)
  func reset(to game:AIGameModel)
  
  // The apply method advances the game state by the specified move for the current player
  //  The method must return an integer value that reflects the value FOR THE PLAYER MAKING THE MOVE
  //  The absolute value of the returned value should be less than Int.max
  @discardableResult
  func apply(_ move:VMGameBotMove) -> Int
}

// Any NSView or UIView that is used to render the game board must conform
//   to this protocol in order form the game bot to update it

// Any NSViewController or UIViewController that is used to control the
// game board view must conform to this protocol for the game bot to
// interact with the view
protocol AIGameViewCotroller
{
  func handleGameCompletion()
  func updateView()
}

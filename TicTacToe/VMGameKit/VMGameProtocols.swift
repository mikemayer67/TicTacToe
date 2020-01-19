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

protocol VMGamePlayer
{
  var type : VMGamePlayerType { get }
}

enum VMGameState
{
  case PreGame
  case PlayerTurn(VMGamePlayer)
  case Winner(VMGamePlayer)
  case TieGame
}

protocol VMGameModel
{
  var gameState : VMGameState { get }
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
  func availableMoves(for player : VMGamePlayer) -> [VMGameBotMove]?
  
  // The reset method should be used to update the state of the game model match the specified state
  //   This includes all dynamic properties that result from a given sequence of moves between start and latest move
  //   This does not include any static game play parameters (players, turn order, etc)
  func reset(to game:AIGameModel)
  
  // The apply method advances the game state the specified move made by the specified player
  //  The method must return an integer value that reflects the value FOR THE PLAYER MAKING THE MOVE
  //  The returned value of Int.max should only be used in case of a win for the player
  //  The returned value of Int.min should only be used in case of a loss for the player
  func apply(_ move:VMGameBotMove, for player:VMGamePlayer) -> Int
}

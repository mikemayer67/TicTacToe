//
//  AIGameBotProtocols.swift
//
//  The protocols used by the AIGameBot and any game model that wouuld
//    be playable by the AIGameBot
//
//  Created by Mike Mayer on 1/12/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

enum AIGamePlayerType
{
  case Human
  case Robot
  case Remote
}

protocol AIGamePlayer
{
  var aiPlayerType : AIGamePlayerType {get}
}

enum AIGameState
{
  case PreGame
  case PlayerTurn(AIGamePlayer)
  case Winner(AIGamePlayer)
  case TieGame
}

// The class used by the AIGameBot to define a move made by a player must conform
//   to the AIGameMove protoccol.  This protocol requires a single variable (aiGameValue)
//   which is used internally by the gamebot.  The value should not be modified by
//   anything other than the gamebot. The game model will dictate what additional
//   methods and attributes the move class should have in order to progress the game
//   state.

protocol AIGameMove : AnyObject
{
  var aiGameValue : Int { get set }
}


// The class used by the AIGameBot to model the game state must conform to
//   the AIGameModel protocol.  Unlike the AIGamePlayer and AIGameMove protocols,
//   the gamebot requires a number of methods and properties to be defined by the
//   game model.

protocol AIGameModel : AnyObject, NSCopying
{
  var gameState      : AIGameState    { get }   // .Human1, .Human2, or .Robot
  var availableMoves : [AIGameMove]?  { get }   // available moves for the current player (nil if no moves possible)
  
  // The reset method should be used to update the state of the game model match the specified state
  //   This includes all dynamic properties that result from a given sequence of moves between start and latest move
  //   This does not include any static game play parameters (players, turn order, etc)
  func reset(to game:AIGameModel)
  
  // The apply method advances the game state the specified move made by the specified player
  //  The method should return a tuple that reflects if the outcome of the move:
  //  - the cone attribute indicates whether the move completes the game (win or tie)
  //  - the value attribute reflects the value of the move FOR THE PLAYER MAKING THE MOVE
  //  The returned value of Int.max should only be used in case of a win for the player
  //  The returned value of Int.min should only be used in case of a loss for the player
  func apply(_ move:AIGameMove, for player:AIGamePlayer) -> (done:Bool, value:Int)
}


//
//  Board.swift
//
//  Created by Mike Mayer on 1/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class Board : AIGameModel
{  
  // Each game board instance is given a unique board index.
  //  This is used for debugging purposes (it has no bearing on game play)
  
  // Each game board constructed from scratch (constructor with 2 players specified) is given a unqique "table" index.
  //   All boards cloned from this game (or cloned from a clone) will have the same table index.
  //   This is used to ensure that a game can only be reset to match a game with identical static paramters.
  //     (Yes, this could be done in a less draconian fashion... but it works and is simple)
    
  private static var boardIndexer : Indexer = 0
  private static var tableIndexer : Indexer = 0
  
  let boardId : Int
  let rootId : Int

  private(set) var marks : [UInt16]
  
  // AIGameBot support
  private(set) var state: VMGameState = .PreGame
    
  // Tic-Tac-Toe game play details
  private(set) var depth : Int
  
  let players       : [Player]
  var playerSeats   : [Int:Int]
  
  var currentPlayer : VMGamePlayer?
  {
    guard case VMGameState.PlayerTurn(let player) = state else { return nil }
    return player
  }
  
  init(_ player1: Player, _ player2 : Player )
  {
    guard player1.mark != player2.mark else { fatalError("oops... players using the same mark") }
    
    boardId = Board.boardIndexer.next()
    rootId = Board.tableIndexer.next()
    
    players       = [player1,player2]
    playerSeats   = [player1.id:0, player2.id:1]
    marks         = [0,0]
    state         = .PlayerTurn(player1)
    depth         = 0
  }
  
  init(_ other : Board)
  {
    boardId = Board.boardIndexer.next()
    rootId = other.rootId

    players      = other.players
    playerSeats  = other.playerSeats
    marks        = other.marks
    state        = other.state
    depth        = other.depth
  }
  
  func restart()
  {
    marks  = [0,0]
    state  = .PlayerTurn(players[0])
    depth  = 0
  }
  
  func reset(to other: AIGameModel) {
    guard let other = other as? Board else { fatalError("Unknown Game Model") }
    guard other.rootId == self.rootId else { fatalError("oops... Can only reset to a clone of current board") }

    self.marks  = other.marks
    self.state  = other.state
    self.depth  = other.depth
  }
  
  var availableMoves : [VMGameBotMove]?
  {
    guard case VMGameState.PlayerTurn = state else { return nil }
    
    if depth == 0 {
      let cand = Grid.Cell.allCases
      let move = cand.randomElement()
      return [ move! ]
    }
    
    var rval = [Grid.Cell]()
    
    let state = marks[0] | marks[1]
    
    for cell in Grid.Cell.allCases
    {
      if cell.rawValue & state == 0 {
        rval.append( cell )
      }
    }
    
    if rval.isEmpty { return nil }
    
    return rval
  }
  
  func apply(_ move:VMGameBotMove) -> Int
  {
    guard let cell   = move as? Grid.Cell        else { fatalError("oops... invalid move type") }
    guard let player = currentPlayer as? Player  else { fatalError("oops... invalid or missing player") }

    mark(cell, for:player)
    
    if case VMGameState.TieGame = state {
      return 0
    }
    
    if case VMGameState.Winner( let winner as Player ) = state
    {
      return (winner.id == player.id ? Int.max : Int.min)
    }
    
    var candidateWins = [0,0]
    
    for mask in Grid.winMasks
    {
      if mask & marks[0] == 0 { candidateWins[1] = candidateWins[1] + 1 }
      if mask & marks[1] == 0 { candidateWins[0] = candidateWins[0] + 1 }
    }
    
    guard let seat = playerSeats[player.id] else { fatalError("oops... player isn't in this game") }
    let score = 10 * ( candidateWins[seat] - candidateWins[1-seat] )
    return score
  }
  
  func open(at cell:Grid.Cell) -> Bool
  {
    let mask = cell.rawValue
    let marks = self.marks[0] | self.marks[1]
    
    return (mask & marks) == 0
  }
  
  func mark(_ cell:Grid.Cell, for player:Player)
  {
    guard case VMGameState.PlayerTurn = state else { fatalError("oops... invalid game state to apply move") }
    guard let seat = playerSeats[player.id]   else { fatalError("oops... player isn't in this game") }
    
    let mask = cell.rawValue
    
    guard marks[seat] & mask == 0 else { fatalError("oops... attempt to play in occupied space") }
    
    marks[seat] = marks[seat] | mask
    depth = depth + 1
    
    for mask in Grid.winMasks {
      if mask & marks[seat] == mask {
        state = .Winner(player)
        return
      }
    }
    
    if depth == 9  // current player didn't win (would have returned above), so must be a tie
    {
      state = .TieGame
      return
    }
    
    // Not tied and no winner... other player's turn
    state = .PlayerTurn( players[1-seat] )
  }
  
  func copy(with zone: NSZone? = nil) -> Any
  {
    return Board(self)
  }
  
}

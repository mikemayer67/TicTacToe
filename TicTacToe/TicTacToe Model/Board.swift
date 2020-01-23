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
  let tableId : Int

  private(set) var marks : [UInt16]
  
  // AIGameBot support
  private(set) var gameState: VMGameState = .PreGame
    
  // Tic-Tac-Toe game play details
  private(set) var depth : Int
  
  let players       : [Player]
  var playerSeats   : [Int:Int]
  
  var currentPlayer : VMGamePlayer?
  {
    guard case VMGameState.PlayerTurn(let player) = gameState else { return nil }
    return player
  }
    
  var done : Bool
  {
    switch gameState {
    case .PreGame:    return false
    case .PlayerTurn: return false
    case .Winner:     return true
    case .TieGame:    return true
    }
  }
  
  var prefix : String  // used for debug logging
  {
    return String(repeating:" ",count:depth)
  }
  
  init(_ player1: Player, _ player2 : Player )
  {
    guard player1.mark != player2.mark else { fatalError("oops... players using the same mark") }
    
    boardId = Board.boardIndexer.next()
    tableId = Board.tableIndexer.next()
    
    players       = [player1,player2]
    playerSeats   = [player1.id:0, player2.id:1]
    marks         = [0,0]
    gameState     = .PlayerTurn(player1)
    depth         = 0
  }
  
  init(_ other : Board)
  {
    boardId = Board.boardIndexer.next()
    tableId = other.tableId

    players       = other.players
    playerSeats   = other.playerSeats
    marks         = other.marks
    gameState     = other.gameState
    depth         = other.depth
  }
  
  func restart()
  {
    marks         = [0,0]
    gameState     = .PlayerTurn(players[0])
    depth         = 0
  }
  
  func reset(to other: AIGameModel) {
    guard let other = other as? Board else { fatalError("Unknown Game Model") }

    self.marks          = other.marks
    self.gameState      = other.gameState
    self.depth          = other.depth
  }
  
  var availableMoves : [VMGameBotMove]?
  {
    guard case VMGameState.PlayerTurn(let player as Player) = gameState else { return nil }
    
    var rval = [Grid.Cell]()
    
    let state = marks[0] | marks[1]
    
    for cell in Grid.Cell.allCases
    {
      if cell.rawValue & state == 0 {
        rval.append( cell )
      }
    }
    
    if rval.isEmpty { return nil }
    
    let moves = rval.reduce("  ") { r,e in String(format:"%@ %@",r,e.string) }
    print(prefix,"Moves for ",player.mark,"=",moves)

    return rval
  }
  
  @discardableResult
  func apply(_ move:VMGameBotMove) -> Int
  {
    guard let cell   = move as? Grid.Cell        else { fatalError("oops... invalid move type") }
    guard let player = currentPlayer as? Player  else { fatalError("oops... invalid or missing player") }

    mark(cell, for:player)
    
    if case VMGameState.TieGame = gameState {
      print(prefix,"tie")
      return 0
    }
    
    if case VMGameState.Winner( let winner as Player ) = gameState
    {
      print(prefix,winner.mark,"wins")
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
    print(prefix,"score for",player.mark,"=",score)
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
    guard case VMGameState.PlayerTurn = gameState else { fatalError("oops... invalid game state to apply move") }
    guard let seat = playerSeats[player.id]       else { fatalError("oops... player isn't in this game") }
    
    let mask = cell.rawValue
    
    marks[seat] = marks[seat] | mask
    depth = depth + 1
    
    print(prefix,depth, "apply",player.mark,"at",cell.string,"   (", boardId,")")
    display()
    
    for mask in Grid.winMasks {
      if mask & marks[seat] == mask {
        print( prefix,player.mark, "won!")
        gameState = .Winner(player)
        return
      }
    }
    
    if depth == 9  // current player didn't win (would have returned above), so must be a tie
    {
      print(prefix,"--tied--")
      gameState = .TieGame
      return
    }
    
    // Not tied and no winner... other player's turn
    gameState = .PlayerTurn( players[1-seat] )
  }
  
  func copy(with zone: NSZone? = nil) -> Any
  {
    return Board(self)
  }
  
  func display()
  {
    var line = ""
    for cell : Grid.Cell in [ .NW, .N, .NE, .W, .X, .E, .SW, .S, .SE ]
    {
      let mask = cell.rawValue
      if      marks[0] & mask == mask { line.append(players[0].mark.rawValue) }
      else if marks[1] & mask == mask { line.append(players[1].mark.rawValue) }
      else                            { line.append(" ") }
      
      switch cell
      {
      case .SW, .S, .W, .X, .NW, .N:
        line.append("|")
      case .NE, .E:
        print(prefix,line);
        print(prefix,"-+-+-")
        line = ""
      case .SE:
        print(prefix,line)
      }
    }
  }
  
}

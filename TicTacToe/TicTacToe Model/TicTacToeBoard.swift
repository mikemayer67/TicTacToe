//
//  TicTacToeBoard.swift
//
//  Created by Mike Mayer on 1/7/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class TicTacToeBoard : AIGameModel
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
  private(set) var gameState: AIGameState = .PreGame
    
  // Tic-Tac-Toe game play details
  private(set) var depth : Int
  
  let players       : [TicTacToePlayer]
  var playerSeats   : [Int:Int]
  
  var currentPlayer : TicTacToePlayer?
  {
    guard case AIGameState.PlayerTurn(let player as TicTacToePlayer) = gameState else { return nil }
    return player
  }
    
  var prefix : String  // used for debug logging
  {
    return String(repeating:" ",count:depth)
  }
  
  init(_ player1: TicTacToePlayer, _ player2 : TicTacToePlayer )
  {
    guard player1.mark != player2.mark else { fatalError("oops... players using the same mark") }
    
    boardId = TicTacToeBoard.boardIndexer.next()
    tableId = TicTacToeBoard.tableIndexer.next()
    
    players       = [player1,player2]
    playerSeats   = [player1.id:0, player2.id:1]
    marks         = [0,0]
    gameState     = .PlayerTurn(player1)
    depth         = 0
  }
  
  init(_ other : TicTacToeBoard)
  {
    boardId = TicTacToeBoard.boardIndexer.next()
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
    guard let other = other as? TicTacToeBoard else { fatalError("Unknown Game Model") }

    self.marks          = other.marks
    self.gameState      = other.gameState
    self.depth          = other.depth
  }
  
  var availableMoves : [AIGameMove]?
  {
    guard case AIGameState.PlayerTurn(let player as TicTacToePlayer) = gameState else { return nil }
    
    var rval = [TicTacToeUpdate]()
    
    let state = marks[0] | marks[1]
    
    for cell in TicTacToeGrid.Cell.allCases
    {
      if cell.rawValue & state == 0 {
        rval.append( TicTacToeUpdate(cell, for: player, depth:depth) )
      }
    }
    
    if rval.isEmpty { return nil }
    
    let moves = rval.reduce("  ") { r,e in String(format:"%@ %@",r,e.cell.string) }
    print(prefix,"Moves for ",player.mark,"=",moves)

    return rval
  }
  
  @discardableResult
  func apply(_ move:AIGameMove, for player:AIGamePlayer) -> (done:Bool, value:Int)
  {
    guard case AIGameState.PlayerTurn = gameState else { fatalError("oops... invalid game state to apply move") }
    guard let player = currentPlayer              else { fatalError("oops... no current player set") }
    guard let move = move as? TicTacToeUpdate     else { fatalError("oops... invalid move type") }
    
    guard let seat = playerSeats[player.id]       else { fatalError("oops... player isn't in this game") }
    let cell = move.cell.rawValue
    
    marks[seat] = marks[seat] | cell
    depth = depth + 1
    
    print(prefix,depth, "apply",player.mark,"at",move.cell.string,"   (", boardId,")")
    display()
    
    for mask in TicTacToeGrid.winMasks {
      if mask & marks[seat] == mask {
        print( prefix,player.mark, "won!")
        gameState = .Winner(player)
        return (true,Int.max)
      }
    }
    
    if depth == 9  // current player didn't win (would have returned above), so must be a tie
    {
      print(prefix,"--tied--")
      gameState = .TieGame
      return (true,0)
    }
      
    let playerMask = marks[seat]
    let opponentMask = marks[1-seat]
    
    var numPlayerPotentialWins = 0
    var numOpponentPotentialWins = 0
    
    for mask in TicTacToeGrid.winMasks
    {
      if mask & opponentMask == 0 { numPlayerPotentialWins   = numPlayerPotentialWins   + 1 }
      if mask & playerMask   == 0 { numOpponentPotentialWins = numOpponentPotentialWins + 1 }
    }
    
    gameState = .PlayerTurn( players[1-seat] )
    
    return (false, 10 * (numPlayerPotentialWins - numOpponentPotentialWins) )
  }
  
  func copy(with zone: NSZone? = nil) -> Any { return TicTacToeBoard(self) }
  
  var string : String
  {
    var rval = "["
    
    for cell : TicTacToeGrid.Cell in [ .SW, .S, .SE, .W, .X, .E, .NW, .N, .NE ]
    {
      let mask = cell.rawValue
      if      marks[0] & mask == mask { rval.append(players[0].mark.rawValue) }
      else if marks[1] & mask == mask { rval.append(players[1].mark.rawValue) }
      else                            { rval.append(" ") }
      
      if cell == .E || cell == .SE { rval.append("][") }
    }
    rval.append("]")
    
    return rval
  }
  
  
  func display()
  {
    var line = ""
    for cell : TicTacToeGrid.Cell in [ .NW, .N, .NE, .W, .X, .E, .SW, .S, .SE ]
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

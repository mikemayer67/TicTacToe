//
//  GameUpdate.swift
//
//  Created by Mike Mayer on 1/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

class TicTacToeUpdate : AIGameMove
{
  var aiGameValue: Int = 0
  {
    didSet {
      print(String(repeating:" ",count:depth), depth,
            "value for", player.mark,
            "at", cell.string,
            "=", aiGameValue)
    }
  }
  
  let cell   : TicTacToeGrid.Cell
  
  let player : TicTacToePlayer
  let depth  : Int
  
  init(_ cell:TicTacToeGrid.Cell, for player:TicTacToePlayer, depth:Int)
  {
    self.cell   = cell
    self.player = player
    self.depth  = depth+1
  }
}

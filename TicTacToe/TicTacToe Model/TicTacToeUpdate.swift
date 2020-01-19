//
//  GameUpdate.swift
//
//  Created by Mike Mayer on 1/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

class TicTacToeUpdate : AIGameMove
{
  var aiGameValue : Int
  let cell        : TicTacToeGrid.Cell
  
  init(_ cell:TicTacToeGrid.Cell)
  {
    self.cell = cell
    self.aiGameValue = 0
  }
}

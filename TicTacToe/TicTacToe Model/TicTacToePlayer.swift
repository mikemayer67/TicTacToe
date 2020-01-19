//
//  TicTacToePlayer.swift
//  TicTacToe
//
//  Created by Mike Mayer on 1/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import GameplayKit

class TicTacToePlayer : AIGamePlayer
{
  let isAIGameBot: Bool
  
  enum Mark : String {
    case X = "X"
    case O = "O"
  }
  
  static var idIndexer : Indexer = 0
  
  let id : Int
  let mark : Mark
    
  convenience init(_ mark: Mark)
  {
    self.init(mark, isAIGameBot:false)
  }
  
  init(_ mark:Mark, isAIGameBot:Bool)
  {
    self.id = TicTacToePlayer.idIndexer.next()
    self.mark = mark
    self.isAIGameBot = isAIGameBot
  }
}


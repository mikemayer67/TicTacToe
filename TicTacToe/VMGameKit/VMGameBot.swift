//
// VMGameBot.swift
//
// The protocols used to support the VMGameKit bot player (VMGameBot)
//
//  Created by Mike Mayer on 1/18/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

class VMGameBot
{
  let game : AIGameModel
    
  var maxSearchDepth = 5
  
  init(play game:AIGameModel)
  {
    self.game = game
  }
  
  func selectMove() -> VMGameBotMove?
  {
    if let (move,_) = selectMove(game,1) { return move }
 
    return nil
  }
  
  private func selectMove(_ game:AIGameModel,_ depth:Int) -> (VMGameBotMove,Int)?
  {
    guard let availableMoves = game.availableMoves else { return nil }
    if availableMoves.isEmpty { return nil }
    
    if availableMoves.count == 1 { return (availableMoves.first!,0) }
    
    let currentPlayer = game.currentPlayer
    
    var bestScore = Int.min
    var bestMoves = Array<VMGameBotMove>()
    
    let trial = game.copy() as! AIGameModel
    
    for move in availableMoves
    {
      trial.reset(to: game)
      
      var score = trial.apply(move)
      
      switch trial.gameState
      {
      case .PreGame:
        fatalError("oops... robot made a pregame move")
        
      case .PlayerTurn:
        if depth < maxSearchDepth
        {
          if let (_,childScore) = selectMove(trial,depth+1)
          {
            score = -childScore
          }
        }
        
      case .Winner(let winner):
        // note that Int.min is 1 less than -Int.max
        //   we use -Int.max so that we can negate the score
        score = ( winner == currentPlayer ? Int.max : -Int.max )
        
      case .TieGame:
        break;
      }
      
      if score > bestScore
      {
        bestMoves = [move]
        bestScore = score
      }
      else if score == bestScore
      {
        bestMoves.append(move)
      }
    }
    
    if bestMoves.isEmpty { return nil }
    
    return (bestMoves.first!, bestScore)
  }
  
}

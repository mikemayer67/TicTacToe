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
    
    let currentPlayer = game.currentPlayer
    
    var bestScore = Int.min
    var bestMoves = Array<VMGameBotMove>()
    
    for move in availableMoves
    {
      let trial = game.copy() as! AIGameModel
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
        if let g = trial as? Board, let m = move as? Grid.Cell, let p = currentPlayer as? Player {
          print(g.prefix,"New best score for",p.mark,"at",m.string)
        }
        bestMoves = [move]
        bestScore = score
      }
      else if score == bestScore
      {
        if let g = trial as? Board, let m = move as? Grid.Cell, let p = currentPlayer as? Player {
          print(g.prefix,"Equivalent moves for",p.mark,"at",
                bestMoves.reduce("  ") { r,e in String(format:"%@ %@",r,(e as! Grid.Cell).string) } )
        }
        bestMoves.append(move)
      }
    }
    
    if bestMoves.isEmpty { return nil }
    
    return (bestMoves.first!, bestScore)
  }
  
}

//
//  TicTacToeViewController.swift
//  TicTacToe
//
//  Created by Mike Mayer on 1/4/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Cocoa

class TicTacToeViewController: NSViewController
{
  private(set) var touchCell : TicTacToeGrid.Cell?
  private(set) var board     : TicTacToeBoard?
  private(set) var player1   : TicTacToePlayer?
  private(set) var player2   : TicTacToePlayer?
  
  @IBOutlet weak var boardView : TicTacToeView!
  @IBOutlet weak var configView : TicTacToeConfigView!
  @IBOutlet weak var replayButton : NSButton!
  
  @objc dynamic var playerOneIsRobot = false
  @objc dynamic var playerTwoIsRobot = false
  @objc dynamic var playerOneIsX     = true
  
  @IBAction func watchPlayerOne(_ sender: NSButton) {
    if playerOneIsRobot, playerTwoIsRobot { playerTwoIsRobot = false }
  }
  
  @IBAction func watchPlayerTwo(_ sender: NSButton) {
    if playerOneIsRobot, playerTwoIsRobot { playerOneIsRobot = false }
  }
  
  @IBAction func handlePlayButton(_ sender: NSButton) {
    configView.isHidden = true
    
    player1 = TicTacToePlayer(playerOneIsX ? .X : .O, as: playerOneIsRobot ? .Robot : .Human)
    player2 = TicTacToePlayer(playerOneIsX ? .O : .X, as: playerTwoIsRobot ? .Robot : .Human)

    board = TicTacToeBoard(player1!, player2!)
    
    if playerOneIsRobot {
      print ("ROBOT plays first")
    }
  }
  
  @IBAction func handleReplayButton(_ sender: NSButton) {
    boardView.reset()
    
    (player1,player2) = (player2,player1)
    board = TicTacToeBoard(player1!, player2!)
    if playerOneIsRobot {
      print ("ROBOT plays first")
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    boardView.reset()
  }

  override func mouseDown(with event: NSEvent)
  {
    touchCell = nil
    
    guard let  board = self.board else { return }
    guard case AIGameState.PlayerTurn(let player) = board.gameState else { return }
    guard case AIGamePlayerType.Human = player.aiPlayerType else { return }
    
    touchCell = boardView.cell(at:event.locationInWindow)
  }
  
  override func mouseUp(with event: NSEvent)
  {
    guard touchCell != nil else { return }
    
    guard let  board = self.board else { return }
    guard case AIGameState.PlayerTurn(let player as TicTacToePlayer) = board.gameState else { return }
    guard case AIGamePlayerType.Human = player.aiPlayerType else { return }

    guard let upCell = boardView.cell(at:event.locationInWindow) else { return }
    
    if upCell == touchCell
    {
      print( player.mark.rawValue, " plays at: ", upCell.string )
      
      let(done,score) =
        board.apply( TicTacToeUpdate(upCell, for: player, depth: board.depth), for: player )
      
      print("Score:",score)
      if(done)
      {
        replayButton.isHidden = false
      }
    
      boardView.setState(board.gameState)
      boardView.setMark(player.mark, at: upCell)
    }

    touchCell = nil
    
    if let player = board.currentPlayer, case AIGamePlayerType.Robot = player.aiPlayerType {
      print("Handle Robot TURN")
    }
  }
}
      
//      if game.winner == nil
//      {
//        DispatchQueue.global(qos: .background).async {
//
//          print("==================================================================")
//
//          if let move = self.ai.bestMoveForActivePlayer() as? GameUpdate
//          {
//            DispatchQueue.main.async {
//              print( (move.player as! Player).name, " plays at: ", move.cell.string )
//
//              print("O plays at: ", move.cell.string)
//              self.game.apply( move )
//              self.gameView.setNeedsDisplay(self.gameView.frame)
//            }
//          }
//          else
//          {
//            print("No move for O")
//          }
//        }
//      }
//    }
//
//    touchCell = nil
//  }



//
//  BoardViewController.swift
//
//  Created by Mike Mayer on 1/4/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController
{
  private(set) var touchCell : Grid.Cell?
  private(set) var board     : Board?
  private(set) var player1   : Player?
  private(set) var player2   : Player?
  
  @IBOutlet weak var boardView : BoardView!
  @IBOutlet weak var configView : ConfigView!
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
    
    player1 = Player(playerOneIsX ? .X : .O, as: playerOneIsRobot ? .Robot : .Human)
    player2 = Player(playerOneIsX ? .O : .X, as: playerTwoIsRobot ? .Robot : .Human)

    board = Board(player1!, player2!)
  }
  
  @IBAction func handleReplayButton(_ sender: NSButton) {
    boardView.reset()
    
    (player1,player2) = (player2,player1)
    board = Board(player1!, player2!)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    boardView.reset()
  }

  override func mouseDown(with event: NSEvent)
  {
    touchCell = nil
    
    guard let  board = self.board else { return }
    guard case VMGameState.PlayerTurn(let player) = board.gameState else { return }
    guard case VMGamePlayerType.Human = player.type else { return }
    
    touchCell = boardView.cell(at:event.locationInWindow)
  }
  
  override func mouseUp(with event: NSEvent)
  {
    guard touchCell != nil else { return }
    
    guard let  board = self.board else { return }
    guard case VMGameState.PlayerTurn(let player as Player) = board.gameState else { return }
    guard case VMGamePlayerType.Human = player.type else { return }

    guard let upCell = boardView.cell(at:event.locationInWindow) else { return }
    
    if upCell == touchCell
    {
      print( player.mark.rawValue, " plays at: ", upCell.string )
      
      board.mark(upCell, for: player )
      
      if(board.done)
      {
        replayButton.isHidden = false
      }
    
      boardView.setState(board.gameState)
      boardView.setMark(player.mark, at: upCell)
    }

    touchCell = nil
    
    if let player = board.currentPlayer, case VMGamePlayerType.Robot = player.type {
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



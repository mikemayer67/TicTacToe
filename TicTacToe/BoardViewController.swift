//
//  BoardViewController.swift
//
//  Created by Mike Mayer on 1/4/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Cocoa

class BoardViewController: NSViewController, AIGameViewCotroller
{
  private(set) var touchCell : Grid.Cell?
  private(set) var board     : Board?
  private(set) var player1   : Player!
  private(set) var player2   : Player!
  
  @IBOutlet weak var boardView    : BoardView!
  @IBOutlet weak var configView   : ConfigView!
  @IBOutlet weak var replayButton : NSButton!
  
  @objc dynamic var playerOneIsRobot = false
  @objc dynamic var playerTwoIsRobot = false
  @objc dynamic var playerOneIsX     = true
  
  @objc dynamic var robotLookAhead : Int = 4
  
  var gameBot : VMGameBot?
  
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
    
    setupNewGame()
  }
  
  @IBAction func handleReplayButton(_ sender: NSButton)
  {
    (player1,player2) = (player2,player1)
    setupNewGame()
  }
  
  func setupNewGame()
  {
    board = Board(player1, player2)
    boardView.board = board
    
    gameBot = nil
    if playerOneIsRobot || playerTwoIsRobot
    {
      gameBot = VMGameBot(play: board!)
      gameBot?.maxSearchDepth = robotLookAhead
    }
    
    touchCell = nil
    
    if case VMGamePlayerType.Robot = player1.type
    {
      gameBot?.takeTurn(self)
    }
  }
  
  func handleGameCompletion()
  {
    replayButton.isHidden = false
  }
  
  func updateView()
  {
    boardView.setNeedsDisplay(boardView.bounds)
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    boardView.setNeedsDisplay(boardView.bounds)
  }

  override func mouseDown(with event: NSEvent)
  {
    touchCell = nil
    
    guard let  board = self.board else { return }
    guard case VMGameState.PlayerTurn(let player) = board.state else { return }
    guard case VMGamePlayerType.Human = player.type else { return }
    
    touchCell = boardView.cell(at:event.locationInWindow)
  }
  
  override func mouseUp(with event: NSEvent)
  {
    guard touchCell != nil else { return }
    
    guard let  board = self.board else { return }
    guard case VMGameState.PlayerTurn(let player as Player) = board.state else { return }
    guard case VMGamePlayerType.Human = player.type else { return }

    guard let upCell = boardView.cell(at:event.locationInWindow) else { return }
    
    if upCell == touchCell, board.open(at: upCell)
    {
      board.mark(upCell, for: player)
      boardView.setNeedsDisplay(boardView.bounds)
      if board.state.done { replayButton.isHidden = false }
    }

    touchCell = nil
    
    // would not have gotten here if current player is a game bot
    // if a game bot is in the game, it must therefore now be its turn
    gameBot?.takeTurn(self)
  }
}

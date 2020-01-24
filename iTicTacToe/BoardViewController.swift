//
//  BoardViewController.swift
//  iTicTacToe
//
//  Created by Mike Mayer on 1/23/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, AIGameViewCotroller
{
  private(set) var board     : Board!
  private(set) var player1   : Player!
  private(set) var player2   : Player!
  
  @IBOutlet weak var boardView     : BoardView!
  @IBOutlet weak var configView    : ConfigView!
  @IBOutlet weak var replayButton  : UIButton!
  @IBOutlet weak var newGameButton : UIButton!
  
  @IBOutlet weak var firstPlayerSelector  : UISegmentedControl!
  @IBOutlet weak var robotSelector        : UISegmentedControl!
  @IBOutlet weak var robotLookAheadSlider : UISlider!
  @IBOutlet weak var robotLookAheadText   : UILabel!
  @IBOutlet weak var robotLookAheadLabel  : UILabel!
  @IBOutlet weak var nextPlayerSelector   : UISegmentedControl!
  
  var playerOneIsX : Bool = true
  var robotPlayer  : Int = 1
  var robotLookAhead = 3
  
  var gameBot : VMGameBot?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    firstPlayerSelector.selectedSegmentIndex = (playerOneIsX ? 0 : 1)
    robotSelector.selectedSegmentIndex = robotPlayer
    robotLookAheadSlider.value = Float(robotLookAhead)
    robotLookAheadText.text = robotLookAhead.description
  }
  
  @IBAction func handleRobotSelector(_ sender : UISegmentedControl)
  {
    if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 1
    {
      robotLookAheadSlider.isEnabled = true
      robotLookAheadLabel.isEnabled = true
      robotLookAheadText.isHidden = false
    }
    else
    {
      robotLookAheadSlider.isEnabled = false
      robotLookAheadLabel.isEnabled = false
      robotLookAheadText.isHidden = true
    }
  }
  
  @IBAction func handleRobotLookAhead(_ sender : UISlider)
  {
    robotLookAhead = Int( robotLookAheadSlider.value + 0.5 )
    robotLookAheadText.text = robotLookAhead.description
  }
  
  @IBAction func handlePlayButton(_ sender : UIButton)
  {
    configView.isHidden = true
    
    robotPlayer  = robotSelector.selectedSegmentIndex
    playerOneIsX = firstPlayerSelector.selectedSegmentIndex == 0
    
    if( sender === replayButton )
    {
      (player1,player2) = (player2,player1) // default is to alternate

      if nextPlayerSelector.selectedSegmentIndex < 2
      {
        if case VMGameState.Winner(let winner as Player) = board.state
        {
          let loser = ( player1 === winner ? player2 : player1)
          
          if nextPlayerSelector.selectedSegmentIndex == 0
          {
            player1 = winner
            player2 = loser
          }
          else
          {
            player1 = loser
            player2 = winner
          }
        }
      }
    }
    else
    {
      player1 = Player( playerOneIsX ? .X : .O, as: robotPlayer == 0 ? .Robot : .Human )
      player2 = Player( playerOneIsX ? .O : .X, as: robotPlayer == 1 ? .Robot : .Human )
    }
    
    setupNewGame()
  }
  
  @IBAction func handleNewGameButton(_ sender : UIButton)
  {
    configView.isHidden = false
    replayButton.isHidden = true
    newGameButton.isHidden = true
  }
  
  func setupNewGame()
  {
    
    board = Board(player1, player2)
    boardView.board = board
    
    replayButton.isHidden = true
    newGameButton.isHidden = true
    
    gameBot = nil
    if robotPlayer != 2
    {
      gameBot = VMGameBot(play: board)
      gameBot!.maxSearchDepth = robotLookAhead
    }
    
    if case VMGamePlayerType.Robot = player1.type
    {
      gameBot?.takeTurn(self)
    }
  }
  
  func handleGameCompletion()
  {
    replayButton.isHidden = false
    newGameButton.isHidden = false
  }
  
  func updateView()
  {
    boardView.setNeedsDisplay()
  }
  
  @IBAction func handleTap(_ sender: UITapGestureRecognizer)
  {
    guard let  board = self.board else { return }
    guard case VMGameState.PlayerTurn(let player as Player) = board.state else { return }
    guard case VMGamePlayerType.Human = player.type else { return }
    
    // note that because UIView and NSView use different coordinate systems,
    //  North is actually at the bottom of the view
    if let cell = boardView.cell(at:sender.location(in: boardView)), board.open(at:cell)
    {    
      board.mark(cell, for: player)
      boardView.setNeedsDisplay(boardView.bounds)
      if board.state.done {
        replayButton.isHidden = false
        newGameButton.isHidden = false
      }
      
      gameBot?.takeTurn(self)
    }
  }
}

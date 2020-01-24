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
  
  @IBOutlet weak var boardView    : BoardView!
  @IBOutlet weak var configView   : ConfigView!
  @IBOutlet weak var replayButton : UIButton!
  
  @IBOutlet weak var firstPlayerSelector  : UISegmentedControl!
  @IBOutlet weak var robotSelector        : UISegmentedControl!
  @IBOutlet weak var robotLookAheadSlider : UISlider!
  @IBOutlet weak var robotLookAheadText   : UILabel!
  @IBOutlet weak var robotLookAheadLabel  : UILabel!
  
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
      (player1,player2) = (player2,player1)
    }
    else
    {
      player1 = Player( playerOneIsX ? .X : .O, as: robotPlayer == 0 ? .Robot : .Human )
      player2 = Player( playerOneIsX ? .O : .X, as: robotPlayer == 1 ? .Robot : .Human )
    }
    
    setupNewGame()
  }
  
  func setupNewGame()
  {
    
    board = Board(player1, player2)
    boardView.board = board
    
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
  }
  
  func updateView()
  {
    boardView.setNeedsDisplay()
  }
}

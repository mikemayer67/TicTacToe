//
//  Player.swift
//
//  Created by Mike Mayer on 1/5/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import GameplayKit

class Player : VMGamePlayer
{
  enum Mark : String {
    case X = "X"
    case O = "O"
  }
  
  let mark : Mark
    
  convenience init(_ mark: Mark)
  {
    self.init(mark, as:.Human)
  }
  
  init(_ mark:Mark, as type:VMGamePlayerType)
  {
    self.mark = mark
    super.init(as: type)
  }
}


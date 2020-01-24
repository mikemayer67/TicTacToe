//
//  Indexer.swift
//  TicTacToe
//
//  Created by Mike Mayer on 1/16/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import Foundation

protocol Indexer
{
  mutating func next() -> Int
}

extension Int : Indexer
{
  mutating func next() -> Int
  {
    self = self + 1
    return self
  }
}

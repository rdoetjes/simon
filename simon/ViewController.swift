//
//  ViewController.swift
//  simon
//
//  Created by Raymond Doetjes on 16/11/2018.
//  Copyright © 2018 Raymond Doetjes. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate
{
  var moves: [Int] = []
  var isPlayersMove: Bool! = false
  var score: Int = 0
  var move: Int = 0
  var player: AVAudioPlayer!
  var donePlaying: Bool! = true
  var a: UIColor?
  
  @IBOutlet weak var lblScore: UILabel!
  
  @IBOutlet weak var btnStart: UIButton!
  
  @IBOutlet var pushButtons: [UIButton]!
  
  @IBAction func btnStartPressed(_ sender: UIButton)
  {
    reset()
    sender.isEnabled = false
    computerTurn()
  }
  
  @IBAction func pushButtonPressed(_ sender: UIButton)
  {
    let playerPressed = sender.tag
    playButtonSound(btn: playerPressed)
    
    a = pushButtons[playerPressed].backgroundColor
    pushButtons[playerPressed].backgroundColor = UIColor.white
    self.view.setNeedsDisplay()
    
    usleep(3000)
    
    if isPlayersMove && playerPressed != moves[move]{
      gameOver()
    }
    else if isPlayersMove
    {
      print(move, moves)
      checkPlayersMove(btn: moves[move])
      move += 1
    }
    else
    {
      move += 1
    }
    
    pushButtons[playerPressed].backgroundColor = a
    self.view.setNeedsDisplay()
    
  }
  
  func setScore()
  {
    lblScore.text = "SCORE: \(score)"
  }
  
  func checkPlayersMove(btn: Int){
    
    if btn != moves[move]
    {
      gameOver()
      return
    }
    
    if move == moves.count-1
    {
      score += 1
      setScore()
      computerTurn()
      return
    }
  }
  
  func gameOver()
  {
    playersTurn(value: false)
    lblScore.text="SCORE: \(score) GAME OVER"
    btnStart.isEnabled = true
    moves = []
  }
  
  func playButtonSound(btn: Int)
  {
    guard let url = Bundle.main.url(forResource: "\(btn)", withExtension: "wav") else { return }
    donePlaying = false
    do {
      player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.numberOfLoops = 0
      player.play()
    } catch let error as NSError {
      print(error.description)
    }
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
  {
    donePlaying = true
  }
  
  func playSequence(){
    print(move, moves)
    for move in moves
    {
      //pushButtons[moves[move]].sendActions(for: .touchUpInside)
    }
    
    playersTurn(value: true)
    
  }
  
  func computerTurn()
  {
    move = 0
    playersTurn(value: false)
    moves.append(Int.random(in: 0 ..< 4))
    print(moves)
    playSequence()
  }
  
  func playersTurn(value: Bool)
  {
    move = 0
    isPlayersMove = value
    for i in 0...3
    {
      pushButtons[i].isEnabled = value
    }
  }
  
  func reset()
  {
    score = 0
    moves = []
    setScore()
    btnStart.isEnabled = true
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    reset()
    btnStart.layer.cornerRadius = 35
  }
}

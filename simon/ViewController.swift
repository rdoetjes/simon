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
  var move: Int = 0
  
  var isPlayersMove: Bool! = false
  
  var level: Int = 1
  
  var highScore: Int = 0
  
  var player: AVAudioPlayer!
  
  var pushed: Int = 0
  
  @IBOutlet weak var lblScore: UILabel!
  
  @IBOutlet weak var lblHighScore: UILabel!
  
  @IBOutlet weak var btnStart: UIButton!
  
  @IBOutlet var pushButtons: [UIButton]!
  
  @IBAction func btnStartPressed(_ sender: UIButton){
    reset()
    sender.isEnabled = false
    sender.setTitle("", for: .normal)
    enablePushButtons(value: true)
    computersMove()
  }
  
  @IBAction func pushButtonPressed(_ sender: UIButton){
    pushed = sender.tag
    //let  c =  sender.backgroundColor
    sender.setImage(UIImage(named: "\(sender.tag)p"), for: .normal)
    playSound(btn: sender.tag)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      sender.setImage(UIImage(named: "\(sender.tag)"), for: .normal)
      if self.isPlayersMove{
        self.checkMove(btn: sender.tag)
      }
    }
  }
  
  func handOver(){
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.level += 1
      self.score(score: self.level, gameover: false)
      self.computersMove()
      return
    }
  }
  
  func checkMove(btn: Int){
    //prevents index out of bound by possible bouncing and out of game presses
    if move>moves.count-1{
      handOver() // handover the turn to the computer
      return
    }
    
    if btn == moves[move]{ // button pressed matches the step in sequence
      if move == moves.count-1 //whole sequence is correct
      {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.handOver() //handover the turn to the computer
        }
      }
      move += 1 // test the next step in the sequence
    } else {
      score(score: level, gameover: true)
      reset()
      return
    }
  }
  
  func playSound(btn: Int){
    let soundFilePath = Bundle.main.path(forResource: "\(btn)", ofType: "wav")
    let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
    
    do {
      try player = AVAudioPlayer(contentsOf: soundFileURL as URL)
      player.delegate = self
      player.prepareToPlay()
      player.numberOfLoops = 0
      player.play()
    }catch {
      print(error)
    }
  }
  
  func playersTurn(value: Bool){
    move = 0
    isPlayersMove = value
  }
  
  func enablePushButtons(value: Bool){
    for btn in pushButtons {
      btn.isUserInteractionEnabled = value
    }
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    if !isPlayersMove{ // let the computer play the next button of his sequence
      playSequence()
    }
  }
  
  func computersMove() {
    playersTurn(value: false)
    moves.append( Int.random(in: 0 ... 3) )
    move = 0
    playSequence()
  }
  
  func playSequence() {
    if move <= moves.count-1 {
      pushButtons[moves[move]].sendActions(for: .touchUpInside)
      move += 1
    } else {
      playersTurn(value: true)
    }
  }
  
  func score(score: Int, gameover: Bool){
    if !gameover {
      lblScore.text = "TRY LEVEL: \(level)"
      lblHighScore.text = "High Score: \(highScore)"

      if (level > highScore){
        highScore = level
      }
    }
    else {
      lblScore.text = "FAILED AT LEVEL: \(level)"
      if (level == highScore){ // only safe if a new highscore is reached
        UserDefaults.standard.set(highScore, forKey: "HIGHSCORE")
      }
      reset()
    }
  }
  
  func reset() {
    level = 1
    moves=[]
    enablePushButtons(value: false)
    btnStart.isEnabled = true
    btnStart.setTitle("PLAY", for: .normal)
    isPlayersMove = false
  }
  
  override func viewDidLoad(){
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    reset()
    btnStart.layer.cornerRadius = 35
    highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
    score(score: level, gameover: false)
  }
}

//
//  ViewController.swift
//  WordGarden
//
//  Created by Connor Goodman on 9/13/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var wordsGuessedLabel: UILabel!
    @IBOutlet weak var wordsRemainingLabel: UILabel!
    @IBOutlet weak var wordsMissedLabel: UILabel!
    @IBOutlet weak var wordsInGameLabel: UILabel!
    @IBOutlet weak var wordBeingRevealedLabel: UILabel!
    @IBOutlet weak var guessedLetterTextField: UITextField!
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusMessageLabel: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    
    var wordsToGuess = ["SWIFT", "DOG", "CAT"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongGuessesRemaining = 8
    var wordsGuessedCount = 0
    var wordsMissedCount = 0
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let text = guessedLetterTextField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        updateGameStatusLabels()
    }
    
    func playSound(name: String){
        if let sound = NSDataAsset(name: name){
            do{
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            }
            catch {
                print("ERROR: \(error.localizedDescription) Could not initialize AVAudioPlayer object 😥")
            }
        }
        else{
            print("ERROR: Could not read data from file sound0")
        }
    }
    
    func updateUIAfterGuess(){
        guessedLetterTextField.resignFirstResponder()
        guessedLetterTextField.text! = ""
        guessLetterButton.isEnabled = false
    }
    
    func updateGameStatusLabels(){
        wordsGuessedLabel.text = "Words Guessed: \(wordsGuessedCount)"
        wordsMissedLabel.text = "Words Missed: \(wordsMissedCount)"
        wordsRemainingLabel.text = "Words to Guess: \(wordsToGuess.count - (wordsGuessedCount + wordsMissedCount))"
        wordsInGameLabel.text = "Words in Game: \(wordsToGuess.count)"
    }
    
    
    func formatRevealedWord(){
        var revealedWord = ""
        for letter in wordToGuess{
            if lettersGuessed.contains(letter){
                revealedWord += String(letter)
            }
            else{
                revealedWord += "_ "
            }
        }
        wordBeingRevealedLabel.text = revealedWord
    }
    
    func updateAfterWinOrLoss(){
        currentWordIndex += 1
        guessedLetterTextField.isEnabled = false
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = false
        updateGameStatusLabels()
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed: String){
        if wordToGuess.contains(currentLetterGuessed) == false{
            wrongGuessesRemaining = wrongGuessesRemaining - 1
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                UIView.transition(with: self.flowerImageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {self.flowerImageView.image = UIImage(named: "wilt\(self.wrongGuessesRemaining)")})
                { (_) in
                    
                    if self.wrongGuessesRemaining != 0{
                        self.flowerImageView.image = UIImage(named:"flower\(self.wrongGuessesRemaining)")
                    }
                    else{
                        self.playSound(name: "word-not-guessed")
                        UIView.transition(with: self.flowerImageView,
                                          duration: 0.5,
                                          options: .transitionCrossDissolve,
                                          animations: {self.flowerImageView.image = UIImage(named:"flower\(self.wrongGuessesRemaining)")},
                                          completion: nil)
                    }
                    
                    
                }
                self.playSound(name: "incorrect")
            }
        }
        
        else{
            playSound(name: "correct")
        }
    }
    
    func guessLetter() {
        let currentLetterGuessed = guessedLetterTextField.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        
        formatRevealedWord()
        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)
        
        guessCount += 1
        
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessageLabel.text = "You've Made \(guessCount) \(guesses)."
        
        if wordBeingRevealedLabel.text!.contains("_") == false{
            playSound(name: "word-guessed")
            gameStatusMessageLabel.text = "You Guessed It! It Took You \(guessCount) Guesses To Guess The Word."
            wordsGuessedCount += 1
            updateAfterWinOrLoss()
        }
        else if wrongGuessesRemaining == 0{
            gameStatusMessageLabel.text = "So Sorry. You're All Out Of Guesses."
            wordsMissedCount += 1
            updateAfterWinOrLoss()
        }
        if currentWordIndex == wordsToGuess.count{
            gameStatusMessageLabel.text! += "\n\nYou've Tried All Of The Words! Restart From The Beginning?"
        }
    }

    @IBAction func guessedLetterFieldChanged(_ sender: UITextField) {
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessLetter()
        updateUIAfterGuess()
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: Any) {
        guessLetter()
        updateUIAfterGuess()
    }
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        if currentWordIndex == wordsToGuess.count{
            currentWordIndex = 0
            wordsGuessedCount = 0
            wordsMissedCount = 0
        }
        
        playAgainButton.isHidden = true
        guessedLetterTextField.isEnabled = true
        guessLetterButton.isEnabled = false
        wordToGuess = wordsToGuess[currentWordIndex]
        wrongGuessesRemaining = maxNumberOfWrongGuesses
        wordBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        guessCount = 0
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        lettersGuessed = ""
        updateGameStatusLabels()
        gameStatusMessageLabel.text = "You've Made Zero Guesses."
    }
    
    
    

}


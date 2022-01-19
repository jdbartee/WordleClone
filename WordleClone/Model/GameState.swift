//
//  GameState.swift
//  WordleClone
//
//  Created by JD Bartee on 1/17/22.
//

import Foundation


class WordleStore: ObservableObject {
    @Published var state: GameState
    
    init() {
        self.state = GameState()
    }
    
    func dispatch(event: Event) {
        self.state = WordleStore.reduce(state: self.state, event: event)
    }
    
    static func demo() -> WordleStore {
        let store = WordleStore()
        store.state.word = "HELLO"
        store.state.guessIndex = 1
        store.state.guesses[0].guessCharacters = [
            .incorrect(of: "Q"),
            .incorrect(of: "U"),
            .partial(of: "E"),
            .incorrect(of: "S"),
            .incorrect(of: "T")
        ]
        store.state.keyboard.keyDict["E"] = .partial(of: "E")
        store.state.keyboard.keyDict["Q"] = .incorrect(of: "Q")
        store.state.keyboard.keyDict["U"] = .incorrect(of: "U")
        store.state.keyboard.keyDict["S"] = .incorrect(of: "S")
        store.state.keyboard.keyDict["T"] = .incorrect(of: "T")

        
        return store
    }
    
    private static func reduce(state: GameState, event: Event) -> GameState {
        var state = state
        
        switch event {
        case .reset:
            state = GameState()
            state.word = words.prefix(300).randomElement()!.uppercased()
        case .clearError:
            state.error = .none
        case .character(let char):
            guard !state.won && !state.lost else {
                break
            }
            guard state.guessIndex >= 0 && state.guessIndex < 5 else {
                break
            }
            var guess = state.guesses[state.guessIndex]
            guard guess.guessIndex < 5 else {
                break
            }
            guess.guessCharacters[guess.guessIndex] = .input(of: char)
            guess.guessIndex += 1
            state.guesses[state.guessIndex] = guess
        case .backspace:
            guard !state.won && !state.lost else {
                break
            }
            guard state.guessIndex >= 0 && state.guessIndex < 5 else {
                break
            }
            var guess = state.guesses[state.guessIndex]
            guard guess.guessIndex > 0 else {
                break
            }
            guess.guessIndex -= 1
            guess.guessCharacters[guess.guessIndex] = .input(of: nil)
            state.guesses[state.guessIndex] = guess
        case .submit:
            guard !state.won && !state.lost else {
                break
            }
            guard state.guessIndex >= 0 && state.guessIndex < 5 else {
                break
            }
            let guess = state.guesses[state.guessIndex]
            var newGuess = Guess()
            guard guess.guessIndex == 5 else {
                break
            }
            let gstr = String( guess.guessCharacters.map() { gc -> Character in
                if case .input(of: let char) = gc {
                    return char ?? "-"
                } else {
                    return Character("-")
                }
            })
            guard words.contains(gstr.lowercased()) else {
                state.error = .notAWord(of: gstr)
                break
            }
            var won = true
            for (i, c) in guess.guessCharacters.enumerated() {
                if case .input(of: let char) = c {
                    if (state.word[state.word.index(state.word.startIndex, offsetBy: i)] == char) {
                        newGuess.guessCharacters[i] = .correct(of: char!)
                        state.keyboard.keyDict[char!] = .correct(of: char!)
                        continue
                    }
                    won = false
                    if state.word.contains(char!) {
                        newGuess.guessCharacters[i] = .partial(of: char!)
                        state.keyboard.keyDict[char!] = .partial(of: char!)
                        continue
                    }
                    newGuess.guessCharacters[i] = .incorrect(of: char!)
                    state.keyboard.keyDict[char!] = .incorrect(of: char!)
                    
                }
            }
            state.won = won
            state.guesses[state.guessIndex] = newGuess
            state.guessIndex += 1
            
            if state.guessIndex == 5 {
                state.lost = true
            }
            
            
        }
        return state
    }
    
}

struct GameState: Hashable {
    var guessIndex: Int
    var word: String
    var won: Bool
    var lost: Bool
    var guesses: [Guess]
    var keyboard: Keyboard
    var error: ErrorMessage
    
    init() {
        self.word = words.randomElement()!.uppercased()
        self.guessIndex = 0
        self.won = false
        self.lost = false
        self.guesses = .init(
            repeating: Guess(),
            count: 5)
        self.keyboard = Keyboard()
        self.error = .none
    }
    
    var hasError: Bool {
        get {
            if case .none = self.error {
                return false
            } else {
                return true
            }
        }
        set {}
    }
}

struct Keyboard: Hashable {
    var keyDict: [Character: CharacterOption]
    
    var rows: [[CharacterOption]] {
        get {
            ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"].map() { r in
                r.map() { c in
                    self.keyDict[c]!
                }
            }
        }
        set {  }
    }
    
    init() {
        self.keyDict = [:]
        for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            self.keyDict[c] = .normal(of: c)
        }
    }
    
}

struct Guess: Hashable {
    var guessIndex: Int
    var guessCharacters: [GuessCharacterState]
    
    init() {
        self.guessIndex = 0
        self.guessCharacters = .init(
            repeating: .inactive,
            count: 5)
    }
    
    
    
}

enum ErrorMessage: Hashable {
    case none
    case notAWord(of: String)
}

enum GuessCharacterState: Hashable {
    case inactive
    case input(of: Character?)
    case correct(of: Character)
    case partial(of: Character)
    case incorrect(of: Character)
}

enum CharacterOption: Hashable {
    case correct(of: Character)
    case incorrect(of: Character)
    case partial(of: Character)
    case normal(of: Character)
}

enum Event: Hashable {
    case character(of: Character)
    case backspace
    case submit
    case clearError
    case reset
}

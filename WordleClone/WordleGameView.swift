//
//  WordleGameView.swift
//  WordleClone
//
//  Created by JD Bartee on 1/17/22.
//

import SwiftUI

struct WordleGameView: View {
    @EnvironmentObject
    var gameStore: WordleStore
    
    var winScreen: some View {
        VStack {
            Text("You win! : )")
            Text("The word was \"\(gameStore.state.word)\"")
            Button("Retry") {
                self.gameStore.dispatch(event: .reset)
            }
        }
    }
    
    var loseScreen: some View {
        VStack {
            Text("You lose. : (")
            Text("The word was \"\(gameStore.state.word)\"")
            Button("Retry") {
                self.gameStore.dispatch(event: .reset)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("WORDLE CLONE")
            ForEach(gameStore.state.guesses.indices) { idx in
                GuessView(guess: $gameStore.state.guesses[idx])
            }
            Spacer()
            KeyboardView()
            Spacer()
        }.sheet(isPresented: $gameStore.state.won, onDismiss: {self.gameStore.dispatch(event: .reset)}) {
            winScreen
        }.sheet(isPresented: $gameStore.state.lost, onDismiss: {self.gameStore.dispatch(event: .reset)}) {
            loseScreen
        }.alert(isPresented: self.$gameStore.state.hasError, content: {
            switch self.gameStore.state.error {
            case .notAWord(of: let word):
                return Alert(title: Text("Error"),
                      message: Text("\(word) not found in word list."),
                      dismissButton: .default(
                        Text("OK"),
                        action: { self.gameStore.dispatch(event: .clearError)}))
            default:
                return Alert(title: Text("Error"),
                      message: Text("Unknown Error"),
                      dismissButton: .default(
                        Text("OK"),
                        action: { self.gameStore.dispatch(event: .clearError)}))
            }
        })
    }
}

struct KeyboardView: View {
    @EnvironmentObject
    var gameStore: WordleStore
    
    var body: some View {
        VStack {
            ForEach($gameStore.state.keyboard.rows, id: \.self) {r in
                HStack {
                    ForEach(r, id: \.self) {k in
                        KeyView(char: k)
                    }
                }
            }
            HStack {
                Spacer().frame(width: 10)
                Image(systemName: "delete.backward")
                    .frame(width: 25, height: 40, alignment: .center)
                    .foregroundColor(.black)
                    .onTapGesture {
                        gameStore.dispatch(event: .backspace)
                    }
                Spacer()
                Image(systemName: "arrow.turn.down.right")
                    .frame(width: 25, height: 40, alignment: .center)
                    .foregroundColor(.black)
                    .onTapGesture {
                        gameStore.dispatch(event: .submit)
                    }
                Spacer().frame(width: 10)
            }
        }
    }
}

struct KeyView: View {
    @Binding
    var char: CharacterOption
    
    private struct IKeyView: View {
        @EnvironmentObject
        var gameStore: WordleStore
        
        var char: Character
        var color: Color
        
        var body: some View {
            Text(String(char))
                .frame(width: 25, height: 40, alignment: .center)
                .foregroundColor(color)
                .onTapGesture {
                    gameStore.dispatch(event: .character(of: char))
                }
        }
    }
    
    var body: some View {
        switch char {
        case .correct(let of):
            IKeyView(char: of, color: .green)
        case .incorrect(let of):
            IKeyView(char: of, color: .red)
        case .partial(let of):
            IKeyView(char: of, color: .yellow)
        case .normal(let of):
            IKeyView(char: of, color: .black)
        }
    }
}

struct GuessView: View {
    @Binding
    var guess: Guess
    
    var body: some View {
        HStack {
            ForEach($guess.guessCharacters.indices) { idx in
                GuessCharacterView(guessCharacter: $guess.guessCharacters[idx])
            }
        }
    }
}

struct GuessCharacterView: View {
    @Binding
    var guessCharacter: GuessCharacterState
    
    private struct IGuessCharView: View {
        var guessChar: Character?
        var color: Color
        
        var body: some View {
            Text(String(guessChar ?? " "))
                .font(.largeTitle)
                .frame(width: 50, height: 50, alignment: .center)
                .background(color)
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        switch guessCharacter {
        case .inactive:
            IGuessCharView(guessChar: " ", color: .gray)
        case .input(let char):
            IGuessCharView(guessChar: char, color: .gray)
        case .correct(let char):
            IGuessCharView(guessChar: char, color: .green)
        case .partial(let char):
            IGuessCharView(guessChar: char, color: .yellow)
                .foregroundColor(.white)
        case .incorrect(let char):
            IGuessCharView(guessChar: char, color: .red)
        }
    }
    
}

struct WordleGameView_Previews: PreviewProvider {
    static var previews: some View {
        WordleGameView().environmentObject(WordleStore.demo())
    }
}

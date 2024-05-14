import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: GameService
    @Environment(\.dismiss) var dismiss
    @State private var guessedLetter: String = ""
    @State private var wordToGuess: String = ""
    @State private var guessedWord: [String] = []
    @State private var remainingAttempts = 6
    @State private var isGameStarted = false
    @State private var wordPlayer: String = ""
    @State private var guessPlayer: String = ""
    @State private var pickPlayer = false
    @State private var disableTextField = false
    @State private var incorrectGuesses: Set<Character> = []
    
    @State private var selectedArrays: [String] = []
    @State private var isBotReady = false
    
    @FocusState private var wordFieldFocused: Bool
    @FocusState private var letterFieldFocused: Bool
    
    var body: some View {
        VStack {
            
            if !selectedArrays.isEmpty {
                            HStack {
                                ForEach(selectedArrays, id: \.self) { category in
                                    Text(category)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                            .padding(.top)
                        }
            
            if isGameStarted {
                
                if game.player1.score > 0 || game.player2.score > 0 {
                    Text("\(game.player1.name) = \(game.player1.score)")
                    Text("\(game.player2.name) = \(game.player2.score)")
                }
                Text("\(guessPlayer), Guess the word: \(guessedWord.joined(separator: " "))")
                    .padding()
                Text("Attempts Remaining: \(remainingAttempts)")
                
                TextField("Enter a letter", text: $guessedLetter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($letterFieldFocused)
                    .disabled(remainingAttempts == 0 || !guessedWord.contains("_") && isGameStarted == true)
                    .padding()
                    .onChange(of: guessedLetter) { newValue in
                            if newValue.count > 0 {
                                guessedLetter = String(newValue.prefix(1))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                        guessedLetter = ""
                                    }
                            }
                            checkLetter(letter: guessedLetter)
    
                    }
    
                
            } else if pickPlayer == false && game.gameType != .bot {
                Text("\(game.player1.name) = \(game.player1.score)")
                Text("\(game.player2.name) = \(game.player2.score)")
                    .padding()
                Text("Select a player to start with their word: ")
                HStack {
                    Button(game.player1.name) {
                        wordPlayer = game.player1.name
                        guessPlayer = game.player2.name
                        pickPlayer = true
                        wordFieldFocused = true
                    }
                    .buttonStyle(.borderedProminent)
                    .background(.black)
                    Button(game.player2.name) {
                        wordPlayer = game.player2.name
                        guessPlayer = game.player1.name
                        pickPlayer = true
                        wordFieldFocused = true
                    }
                    .buttonStyle(.borderedProminent)
                    .background(.black)
                }
                .disabled(game.gameStarted)
                .padding()
                .background(Rectangle()
                    .fill(.white)
                    .frame(width: 200))
                .background(Rectangle()
                    .fill(.orange)
                    .frame(width: 500, height: 60))
            } else if game.gameType == .bot {
                
                VStack {
                    HStack {
                        ForEach(["Brands","Famous People", "Sports"], id: \.self) { arrayName in
                            Button(action: {
                                toggleArraySelection(arrayName)
                            }) {
                                Text(arrayName)
                                    .padding()
                                    .background(selectedArrays.contains(arrayName) ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    HStack {
                        ForEach(["TV Shows", "Cereal"], id: \.self) { arrayName in
                            Button(action: {
                                toggleArraySelection(arrayName)
                            }) {
                                Text(arrayName)
                                    .padding()
                                    .background(selectedArrays.contains(arrayName) ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }

                
                // Button to pick random word
                Button("Pick Random Word") {
                    pickRandomWord()
                    startGame()
                    letterFieldFocused = true
                    guessPlayer = game.player1.name
                }
                
                
            } else {
                Text("\(game.player1.name) = \(game.player1.score)")
                Text("\(game.player2.name) = \(game.player2.score)")
                TextField("\(wordPlayer), Enter a word for Hangman", text: Binding(
                    get: {
                        return wordToGuess
                    },
                    set: { newValue in
                        wordToGuess = newValue.uppercased()
                    }
                ))
                    .autocapitalization(.allCharacters)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($wordFieldFocused)
                    .padding()
                
                Button("Start Guessing") {
                    startGame()
                    letterFieldFocused = true
                }
                .padding()
            }
                VStack {
                    if remainingAttempts > 0 && isGameStarted {
                        Text("Letters tried: \(incorrectGuesses)")
                    }
                    if remainingAttempts == 0 {
                        Text("You Lose. The word was \(wordToGuess)")
                        Button("Play Again") {
                            updateScores(winner: wordPlayer)
                            resetGame()
                        }
                    } else {
                        if !guessedWord.contains("_") && isGameStarted == true {
                            Text("You won!")
                            Button("Play Again") {
                                updateScores(winner: guessPlayer)
                                resetGame()
                            }
                        }
                    }
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("End Game") {
                    dismiss()
                    game.player1.score = 0
                    game.player2.score = 0
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("HangMan")
        .inNavigationstack()
        .onAppear {
                    // Automatically focus on the appropriate text field
                    if isGameStarted == false {
                        wordFieldFocused = true
                        letterFieldFocused = true
                    } else {    }
                }
    }
    
    func checkLetter(letter: String) {
        guard letter.count == 1 else { return }
        
        let char = Character(letter.uppercased())
        if !wordToGuess.contains(char) {
            if remainingAttempts > 0 {
                if guessedLetter != " " {
                    if !incorrectGuesses.contains(char) {
                        incorrectGuesses.insert(char)
                        remainingAttempts -= 1
                        if remainingAttempts == 0 {
                            print("You lose! The word was \(wordToGuess)")
                        }
                    }
                }
            }
        } else {
            var updatedWord = guessedWord
            for (index, character) in wordToGuess.enumerated() {
                if character == char {
                    updatedWord[index] = String(char)
                }
            }
            guessedWord = updatedWord
            if !guessedWord.contains("_") {
                print("Correct! You guessed the word \(wordToGuess)")
            }
        }
    }
    
    /*
    func checkBotLetter(letter: String) {
        guard letter.count == 1 else { return }
        
        let char = Character(letter.uppercased())
        if !guessedRandomWord.contains(char) {
            if remainingAttempts > 0 {
                if guessedLetter != " " {
                    remainingAttempts -= 1
                    if remainingAttempts == 0 {
                        print("You lose! The word was \(guessedRandomWord)")
                    }
                }
            }
        } else {
            var updatedWord = randomWord
            for (index, character) in guessedRandomWord.enumerated() {
                if character == char {
                    updatedWord[index] = String(char)
                }
            }
            randomWord = updatedWord
            if !randomWord.contains("_") {
                print("Correct! You guessed the word \(guessedRandomWord)")
            }
        }
    }
     */
    
    func startGame() {
        guard !wordToGuess.isEmpty else { return }
        
        guessedWord = wordToGuess.map { character in
                if character.isWhitespace {
                    return " "
                } else {
                    return "_"
                }
            }
        //guessedWord = Array(repeating: "_", count: wordToGuess.count)
        isGameStarted = true
    }

    func resetGame() {
            wordPlayer = ""
            guessPlayer = ""
            wordToGuess = ""
            guessedLetter = ""
            guessedWord = []
            remainingAttempts = 6
            isGameStarted = false
            pickPlayer = false
            incorrectGuesses = []
        }
    
    let cereal = ["CHEERIOS", "FROSTED", "HONEYCOMB", "CORNFLAKES", "LUCKY CHARMS", "FROOT LOOPS", "COCOA PUFFS", "RAISIN BRAN", "SPECIAL K", "CINNAMON TOAST", "HONEY NUT CHEERIOS", "CAPN CRUNCH", "RICE KRISPIES", "COOKIE CRISP", "CINNAMON TOAST CRUNCH", "APPLE JACKS", "GOLDEN GRAHAMS", "TRIX", "KIX", "REESES PUFFS", "COUNT CHOCULA", "FROSTED MINI WHEATS", "WHEATIES", "COCOA PEBBLES", "HONEY BUNCHES OF OATS", "LIFE", "CORN POPS", "ALPHA BITS", "QUAKER OATS", "RAISIN NUT BRAN", "SHREDDED WHEAT", "BRAN FLAKES", "TOTAL", "CHEX", "SMACKS", "POPS", "CORN BRAN", "MINI WHEATS", "RAISIN SQUARES"];

    let tvShows = ["BREAKING BAD", "FRIENDS", "THE SIMPSONS", "STRANGER THINGS", "GAME OF THRONES", "THE OFFICE", "GREYS ANATOMY", "SPONGEBOB", "THE MANDALORIAN", "BROOKLYN NINE NINE", "RICK AND MORTY", "THE WALKING DEAD", "DOCTOR WHO", "PARKS AND RECREATION", "THE BIG BANG THEORY", "HOW I MET YOUR MOTHER", "FAMILY GUY", "SOUTH PARK", "DEXTER", "ARRESTED DEVELOPMENT", "HOMELAND", "WESTWORLD", "BLACK MIRROR", "STRANGER THINGS", "THE CROWN", "THE GOOD PLACE", "BOJACK HORSEMAN", "THE WITCHER", "THE BOYS", "FARGO", "THE HANDMAID'S TALE", "OZARK", "PEAKY BLINDERS", "THE UMBRELLA ACADEMY", "COBRA KAI", "THE MANDALORIAN"];

    let sports = ["BASKETBALL", "FOOTBALL", "BASEBALL", "VOLLEYBALL", "BADMINTON", "TABLE TENNIS", "GYMNASTICS", "SKATEBOARDING", "SNOWBOARDING", "WRESTLING", "TENNIS", "GOLF", "RUGBY", "CRICKET", "HOCKEY", "LACROSSE", "SWIMMING", "TRACK", "FIELD", "ARCHERY", "FENCING", "JUDO", "TAEKWONDO", "KARATE", "BOXING", "MMA", "SAILING", "ROWING", "CANOEING", "EQUESTRIAN", "TRIATHLON", "SKIING", "BOBSLEIGH", "LUGE", "SKELETON", "CURLING", "SQUASH", "POLO", "SURFING", "SKATEBOARDING"];

    let famousPeople = ["EINSTEIN", "SHAKESPEARE", "MOZART", "LEONARDO", "BEETHOVEN", "DA VINCI", "NAPOLEON", "CLEOPATRA", "ARISTOTLE", "LINCOLN", "NEWTON", "GALILEO", "EDISON", "TESLA", "GANDHI", "MANDELA", "CHURCHILL", "PICASSO", "MICHELANGELO", "VAN GOGH", "MOZART", "BACH", "BEETHOVEN", "CHOPIN", "WAGNER", "FRANKLIN", "CURIE", "OPPENHEIMER", "HAWKING", "DARWIN", "FREUD", "MARX", "GANDHI", "MANDELA", "MOTHER TERESA", "KENNEDY", "ROOSEVELT", "GANDHI", "MANDELA"];

    let brands = ["COCA COLA", "MCDONALDS", "NIKE", "ADIDAS", "MICROSOFT", "SAMSUNG", "AMAZON", "STARBUCKS", "TOYOTA", "DISNEY", "APPLE", "GOOGLE", "FACEBOOK", "TWITTER", "INSTAGRAM", "PORSCHE", "FERRARI", "LAMBORGHINI", "BMW", "MERCEDES", "AUDI", "VOLKSWAGEN", "TESLA", "SONY", "LG", "PANASONIC", "BOSE", "BEATS", "SONY", "PHILIPS", "HP", "DELL", "LENOVO", "ACER", "ASUS", "IBM", "ORACLE", "ADOBE", "CISCO", "INTEL"];

    
        
    private func toggleArraySelection(_ arrayName: String) {
            if let index = selectedArrays.firstIndex(of: arrayName) {
                selectedArrays.remove(at: index)
            } else {
                selectedArrays.append(arrayName)
            }
        }
    
    private func pickRandomWord() -> String {
            var allWords: [String] = []
            if selectedArrays.contains("Brands") {
                allWords += brands
            }
            if selectedArrays.contains("Famous People") {
                allWords += famousPeople
            }
            if selectedArrays.contains("Sports") {
                allWords += sports
            }
            if selectedArrays.contains("TV Shows") {
                allWords += tvShows
            }
            if selectedArrays.contains("Cereal") {
                allWords += cereal
            }
            wordToGuess = allWords.randomElement() ?? "HANG MAN IN THE FLESH"
            return wordToGuess
        }
    
     

/*
 } else if game.gameType == .bot && !isBotReady {
 
 HStack {
 ForEach(["Fruits", "Animals", "Colors"], id: \.self) { arrayName in
 Button(action: {
 toggleArraySelection(arrayName)
 }) {
 Text(arrayName)
 .padding()
 .background(selectedArrays.contains(arrayName) ? Color.blue : Color.gray)
 .foregroundColor(.white)
 .cornerRadius(5)
 }
 }
 }
 
 // Button to pick random word
 Button("Pick Random Word") {
 guessedRandomWord = pickRandomWord()
 isBotReady = true
 startBot()
 }
 
 } else if game.gameType == .bot && isBotReady {
 Text("\(game.player1.name) = \(game.player1.score)")
 Text("\(game.player2.name) = \(game.player2.score)")
 .padding()
 Text("\(game.player1.name), Guess the word: \(randomWord.joined(separator: " "))")
 //instead of guessedWord, botWords
 .padding()
 Text("Attempts Remaining: \(remainingAttempts)")
 .padding()
 
 TextField("Enter a letter", text: $guessedLetter)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 .focused($letterFieldFocused)
 .disabled(remainingAttempts == 0)
 .padding()
 .onChange(of: guessedLetter) { newValue in
 if newValue.count > 0 {
 guessedLetter = String(newValue.prefix(1))
 DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
 guessedLetter = ""
 }
 }
 checkBotLetter(letter: guessedLetter)
 }
 */
    
    func updateScores(winner: String) {
        if winner == game.player1.name {
            game.player1.score += 1
            } else {
                game.player2.score += 1
            }
        }
}



struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(GameService())
    }
}


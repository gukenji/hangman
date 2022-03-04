require_relative 'hangman_display.rb'

module DisplayText
    include HangmanDisplay
    def self.guess_word(array)
        puts "#{array.join(' ')}"
        puts "  #{array.length} letras"
    end

    def self.hangman_display(mistakes)
        puts HANGMANPICS[mistakes]
    end
end
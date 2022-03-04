require_relative 'display_text.rb'
require 'json'

class Hangman
    include DisplayText
    @@serializer = JSON

    def initialize
        @filename = 'google-10000-english-no-swears.txt'
        @mistakes = 0 
        @attempted_words = []
        start_game
    end

    def start_game
        puts "Deseja carregar um jogo exitente? Selecione S ou N"
        @load_state = gets.chomp.downcase
        until @load_state == "s" || @load_state == "n"
            puts "Selecione apenas S ou N!"
            @load_state = gets.chomp.downcase
        end

        if @load_state == "s"
            @save_states = Hash.new(0)
            Dir["savefiles/*"].length.times do |index|
                 @save_states[index] = Dir["savefiles/*"][index]
            end
            puts "Saves existentes:"
            @save_states.each do |value,key|
                puts "#{value} - #{key}"
            end
            puts "Escolha seu save:"
            @load_states = gets.chomp.to_i
            until @save_states.any? {|key,value| key == @load_states} 
                puts "Escolha um save existente!"
                @load_states = gets.chomp.to_i
            end
            @save_name = @save_states[@load_states].gsub("savefiles/","")
            @save_name
            load_game(@save_name)
            puts "Ok! Continuando o jogo:"
            new_attempt
        else
            puts "Por favor, digite o nome do seu jogo para salvar quando quiser:"
            @save_name = gets.chomp.downcase

            generate_random_word(@filename)
            @player_word = hide_words(@random_word)
            puts "Ok! Iremos começar o jogo. A sua palavra contém a seguinte configuração:"
            new_attempt
        end

    end

    private
    def hide_words(array)
        hidden_word = Array.new()
        array.length.times do
            hidden_word << "_"
        end
        hidden_word
    end

    private
    def unhide_words(original_word, actual_word,letter)
        @right_guesses = 0
        original_word.each_with_index do |value,index|
            if value == letter
                @right_guesses += 1
                actual_word[index] = value
            end
        end
        actual_word
    end

    def new_game
        puts "Quer jogar um novo jogo? Digite S ou N"
        choice = gets.chomp.downcase
        until (choice == "s" || choice == "n")
            puts "Selecione apenas S ou N!"
            choice = gets.chomp.downcase
        end
        choice == "s" ? Hangman.new() : puts("Obrigado por jogar!")
    end

    def end_game?
        if @mistakes == 6
            puts "Você perdeu! A palavra correta era '#{@random_word.join.upcase}'"
            new_game
        elsif @random_word == @player_word
            puts "Parabéns! Você venceu! A palavra correta era '#{@random_word.join.upcase}'"
            new_game
        else
            save_game
            new_attempt
        end
    end

    private
    def new_attempt
        puts HANGMANPICS[@mistakes]
        DisplayText.guess_word(@player_word)
        puts "Escolha uma letra:"
        letter = gets.chomp.downcase
        while letter.length != 1 || check_words(letter)
            if letter.length != 1
                puts "Escolha apenas uma letra!"
                letter = gets.chomp.downcase
            else 
                puts "Escolha uma letra diferente! A letra '#{letter.upcase}'' já foi escolhida!"
                puts "Tentativas: #{@attempted_words.join('|').upcase}"
                letter = gets.chomp.downcase
            end
        end
        @attempted_words << letter
        puts "Tentativas: #{@attempted_words.join('|').upcase}"
        @player_word =  unhide_words(@random_word,@player_word,letter)
        check_attempt(@right_guesses)
    end

    private
    def check_attempt(right_guesses)
        if right_guesses >=1
            puts "Muito bem! Você acertou #{right_guesses} palavra(s)"
            end_game?
        else 
            puts "Você errou!"
            @mistakes +=1
            end_game?
        end
    end
    
    private
    def check_words(letter)
        @attempted_words.include?(letter) ? true : false
    end

    private
    def save_game
        puts "Salvar jogo?"
        save_game = gets.chomp.downcase
        if save_game == "s"
            obj = {}
            instance_variables.map do |var|
                obj[var] = instance_variable_get(var)
            end
            @@serializer.dump obj
            File.open("savefiles/#{@save_name}.json","w") {|f| f.puts(obj.to_json)}
        else
            puts "Ok, continuando sem salvar."
        end
    end


    def load_game(filename)
        file = File.read("savefiles/#{filename}")
        data = JSON.parse(file)
        data.keys.each do |key|
            instance_variable_set(key,data[key])
        end
    end

    private
    def generate_random_word(filename)
        file = File.open(filename,"r")
        number_of_lines = file.readlines.size
        @random_word = ""
        until (@random_word.length >= 5 && @random_word.length <= 12) do
            @random_word = File.readlines(filename, chomp:true)[rand(0..number_of_lines)].split('')
        end
        file.close
    end

end


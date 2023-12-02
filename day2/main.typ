#set page(width: auto, height: auto, margin: 1cm)

// input
#let input = read("./input.txt")
// #let input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
// Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
// Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
// Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
// Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

// parsing
#let input = input.trim().split("\n").enumerate().map(((idx, game)) => {
  game = game.trim(regex("Game \d+: "), at: start)
  let sets = game.split("; ").map(s => s.split(", ").map(color => {
    let (count, name) = color.split(" ")
    let a = (:)
    a.insert(name, int(count))
    a
  }).join())
  (id: idx + 1, sets: sets)
})

// part 1
#input.filter(game => game.sets.all(s =>
  s.at("red", default: 0) <= 12
  and s.at("green", default: 0) <= 13
  and s.at("blue", default: 0) <= 14
)).map(game => game.id).sum()

// part 2
#input.map(game => {
  let min-red = 0
  let min-green = 0
  let min-blue = 0
  for s in game.sets {
    min-red = calc.max(min-red, s.at("red", default: 0))
    min-green = calc.max(min-green, s.at("green", default: 0))
    min-blue = calc.max(min-blue, s.at("blue", default: 0))
  }
  min-red * min-green * min-blue
}).sum()

#set page(width: auto, height: auto, margin: 1cm)

#let input = read("./input.txt").trim()
// #let input = "
// Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
// Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
// Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
// Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
// Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
// Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
// ".trim()

// parse
#let cards = input.split("\n").map(line => {
  let (winning, mine) = line.trim(regex("Card +\d+: *"), at: start).split(" | ").map(nums => {
    nums.split(regex(" +")).filter(n => n.trim() != "").map(int)
  })
  ((count: 1, winning: winning, mine: mine),)
}).join()

// part 1
#cards.map(card => {
  let winning-count = card.mine.filter(num => num in card.winning).len()
  if winning-count == 0 { 0 } else { calc.pow(2, winning-count - 1) }
}).sum()

// part 2
#let i = 0
#while i < cards.len() {
  let card = cards.at(i)
  let winning-count = card.mine.filter(num => num in card.winning).len()
  for j in range(winning-count) {
    cards.at(i + j + 1).count += card.count
  }
  i += 1
}
#cards.map(card => card.count).sum()

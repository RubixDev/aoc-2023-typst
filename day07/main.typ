// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()
// #let input = "
// 32T3K 765
// T55J5 684
// KK677 28
// KTJJT 220
// QQQJA 483
// ".trim()

// parse
#let hands = input.split("\n").map(line => {
  let (hand, bid) = line.split(" ")
  // types are:
  // 6: five of a kind
  // 5: four of a kind
  // 4: full house
  // 3: three of a kind
  // 2: two pair
  // 1: one pair
  // 0: high card
  let card-counts = (:)
  for card in hand {
    if card in card-counts {
      card-counts.at(card) += 1
    } else {
      card-counts.insert(card, 1)
    }
  }
  let type = if card-counts.values().any(count => count == 5) {
    6
  } else if card-counts.values().any(count => count == 4) {
    5
  } else if card-counts.values().any(count => count == 3) and card-counts.values().any(count => count == 2) {
    4
  } else if card-counts.values().any(count => count == 3) {
    3
  } else if card-counts.values().filter(count => count == 2).len() == 2 {
    2
  } else if card-counts.values().any(count => count == 2) {
    1
  } else {
    0
  }
  (hand: hand, bid: int(bid), type: type)
})

// part 1
#let ranked = hands.sorted(key: hand => str(hand.type) + hand.hand
  .replace("A", "Z")
  .replace("K", "Y")
  .replace("Q", "X")
  .replace("J", "W")
  .replace("T", "V")
)
#ranked.enumerate().map(((rank, hand)) => (rank + 1) * hand.bid).sum()

// part 2
// - re-evaluate types
#let hands = hands.map(hand => {
  let card-counts = (:)
  for card in hand.hand {
    if card in card-counts {
      card-counts.at(card) += 1
    } else {
      card-counts.insert(card, 1)
    }
  }
  let j-count = card-counts.remove("J", default: 0)
  hand.type = if card-counts.values().any(count => count + j-count == 5) or j-count == 5 {
    6
  } else if card-counts.values().any(count => count + j-count == 4) {
    5
  } else if (card-counts.values().any(count => count == 3) and card-counts.values().any(count => count == 2)
      or card-counts.values().filter(count => count == 2).len() == 2 and j-count == 1) {
    4
  } else if card-counts.values().any(count => count + j-count == 3) {
    3
  } else if card-counts.values().filter(count => count == 2).len() == 2 {
    2
  } else if card-counts.values().any(count => count + j-count == 2) {
    1
  } else {
    0
  }
  hand
})
#let ranked = hands.sorted(key: hand => str(hand.type) + hand.hand
  .replace("A", "Z")
  .replace("K", "Y")
  .replace("Q", "X")
  .replace("J", "0")
  .replace("T", "V")
)
#ranked.enumerate().map(((rank, hand)) => (rank + 1) * hand.bid).sum()

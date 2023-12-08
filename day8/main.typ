// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()
// #let input = "
// RL
//
// AAA = (BBB, CCC)
// BBB = (DDD, EEE)
// CCC = (ZZZ, GGG)
// DDD = (DDD, DDD)
// EEE = (EEE, EEE)
// GGG = (GGG, GGG)
// ZZZ = (ZZZ, ZZZ)
// ".trim()
// #let input = "
// LLR
//
// AAA = (BBB, BBB)
// BBB = (AAA, ZZZ)
// ZZZ = (ZZZ, ZZZ)
// ".trim()
// #let input = "
// LR
//
// 11A = (11B, XXX)
// 11B = (XXX, 11Z)
// 11Z = (11B, XXX)
// 22A = (22B, XXX)
// 22B = (22C, 22C)
// 22C = (22Z, 22Z)
// 22Z = (22B, 22B)
// XXX = (XXX, XXX)
// ".trim()

// parse
#let sequence = input.split("\n\n").first().trim()
#let nodes = input.split("\n\n").last().trim().split("\n").map(line => {
  let (name, left, right) = line.match(regex("^(\w{3}) = \((\w{3}), (\w{3})\)")).captures
  let a = (:)
  a.insert(name, (left: left, right: right))
  a
}).join()
// #nodes

// part 1
#let step = 0
#let curr = "AAA"
#while curr != "ZZZ" {
  for instruction in sequence.clusters() {
    curr = nodes.at(curr).at(if instruction == "L" { "left" } else { "right" })
    step += 1
  }
}
#step

// part 2
#{
nodes.keys().filter(node => node.ends-with("A")).map(curr => {
  let step = 0
  while not curr.ends-with("Z") {
    for instruction in sequence.clusters() {
      curr = nodes.at(curr).at(if instruction == "L" { "left" } else { "right" })
      step += 1
      if curr.ends-with("Z") {
        break
      }
    }
  }
  step
}).fold(1, (acc, num) => calc.lcm(acc, num))
}

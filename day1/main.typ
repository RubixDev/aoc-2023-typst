#let input = read("./input.txt").trim().split("\n")
// #let input = "two1nine
// eightwothree
// abcone2threexyz
// xtwone3four
// 4nineeightseven2
// zoneight234
// 7pqrstsixteen".trim().split("\n")

#input.map(line => {
  let digits = line.replace(regex("[^0-9]"), "")
  digits.first()
  digits.last()
}).map(int).sum()

#input.map(line => {
  let digits = range(line.len()).map(index => {
    let char = line.at(index)
    if char.contains(regex("[0-9]")) {
      int(char)
    }
    if line.len() - index >= 3 and char in "ots" {
      if line.slice(index, count: 3) == "one" { 1 }
      else if line.slice(index, count: 3) == "two" { 2 }
      else if line.slice(index, count: 3) == "six" { 6 }
    }
    if line.len() - index >= 4 and char in "fn" {
      if line.slice(index, count: 4) == "four" { 4 }
      else if line.slice(index, count: 4) == "five" { 5 }
      else if line.slice(index, count: 4) == "nine" { 9 }
    }
    if line.len() - index >= 5 and char in "tse" {
      if line.slice(index, count: 5) == "three" { 3 }
      else if line.slice(index, count: 5) == "seven" { 7 }
      else if line.slice(index, count: 5) == "eight" { 8 }
    }
  }).filter(digit => digit != none)
  digits.first() * 10 + digits.last()
}).sum()

// #let input = read("./input.txt").trim().split("\n")
// #let input = "two1nine
// eightwothree
// abcone2threexyz
// xtwone3four
// 4nineeightseven2
// zoneight234
// 7pqrstsixteen".trim().split("\n")
//
// #let get-num(line) = {
//   let digits = line.replace(regex("[^0-9]"), "")
//   digits.first()
//   digits.last()
// }
//
// // #input.map(get-num).map(int).sum()
// #input.map(line =>
//   line.replace(regex("one|two|three|four|five|six|seven|eight|nine"), m => "<" + m.text + ">")
//     .replace("<one>", "1")
//     .replace("<two>", "2")
//     .replace("<three>", "3")
//     .replace("<four>", "4")
//     .replace("<five>", "5")
//     .replace("<six>", "6")
//     .replace("<seven>", "7")
//     .replace("<eight>", "8")
//     .replace("<nine>", "9")
// )//.map(get-num).map(int).sum()

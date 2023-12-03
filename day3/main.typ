#set page(width: auto, height: auto, margin: 1cm)

#let input = read("./input.txt").trim()
// #let input = "
// 467..114..
// ...*......
// ..35..633.
// ......#...
// 617*......
// .....+.58.
// ..592.....
// ......755.
// ...$.*....
// .664.598..
// ".trim()

#let lines = input.split("\n")
#let adjacents = for (line-idx, line) in lines.enumerate() {
  let i = 0
  while i < line.len() {
    let char = line.at(i)
    if char in "0123456789" {
      let num = char
      let start-idx = i
      while line.at(i + 1, default: ".") in "0123456789" {
        i += 1
        num += line.at(i)
      }
      // check adjacent positions for symbols
      let adjacent-symbols = ()
      for y in range(line-idx - 1, line-idx + 2) {
        for x in range(start-idx - 1, i + 2) {
          if x >= 0 and x < line.len() and y >= 0 and y < lines.len() and lines.at(y).at(x) not in "0123456789." {
            adjacent-symbols.push((char: lines.at(y).at(x), x: x, y: y))
          }
        }
      }
      ((num: int(num), symbols: adjacent-symbols),)
    }
    i += 1
  }
}

#adjacents.filter(pair => pair.symbols.len() != 0).map(pair => pair.num).sum()

#let flipped-adjacents = for (idx-1, pair) in adjacents.enumerate() {
  for symbol in pair.symbols {
    let adjacent-nums = (pair.num,)
    for pair-2 in adjacents.slice(idx-1 + 1) {
      for symbol-2 in pair-2.symbols {
        if symbol.x == symbol-2.x and symbol.y == symbol-2.y {
          adjacent-nums.push(pair-2.num)
        }
      }
    }
    ((symbol: symbol.char, nums: adjacent-nums),)
  }
}

#flipped-adjacents.filter(pair => pair.symbol == "*" and pair.nums.len() == 2).map(pair => pair.nums.product()).sum()

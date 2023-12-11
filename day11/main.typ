// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()

#let input = "
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
".trim()

// functions
#let show-space(space) = {
  set par(leading: 0.3em)
  space.map(row => raw(row.join()) + "\n").join()
}

// parse
#let space = input.split("\n").map(str.clusters)
// expand rows
#for y in range(space.len()).rev() {
  if space.at(y).all(tile => tile == ".") {
    space.insert(y, space.at(y))
  }
}
// expand columns
#for x in range(space.first().len()).rev() {
  if space.all(row => row.at(x) == ".") {
    for y in range(space.len()) {
      space.at(y).insert(x, ".")
    }
  }
}

// #show-space(space)

// part 1
#let galaxies = ()
#for (y, row) in space.enumerate() {
  for (x, tile) in row.enumerate() {
    if tile == "#" {
      galaxies.push((id: galaxies.len() + 1, x: x, y: y))
    }
  }
}
// #galaxies
#let distances = ()
#for (i, galaxy-1) in galaxies.enumerate() {
  for galaxy-2 in galaxies.slice(i + 1) {
    // for each distinct pair of galaxies
    let distance = calc.abs(galaxy-1.x - galaxy-2.x) + calc.abs(galaxy-1.y - galaxy-2.y)
    distances.push(distance)
  }
}
#distances.sum()

// part 2
// - re-parse input
#let space = input.split("\n").map(str.clusters)
#let expand-rows = for y in range(space.len()) {
  if space.at(y).all(tile => tile == ".") {
    (y,)
  }
}
#let expand-cols = for x in range(space.first().len()) {
  if space.all(row => row.at(x) == ".") {
    (x,)
  }
}
// #expand-rows
// #expand-cols

#let galaxies = ()
#for (y, row) in space.enumerate() {
  for (x, tile) in row.enumerate() {
    if tile == "#" {
      galaxies.push((id: galaxies.len() + 1, x: x, y: y))
    }
  }
}
// #galaxies
#let distances = ()
#let multiplier = 1000000
#for (i, galaxy-1) in galaxies.enumerate() {
  for galaxy-2 in galaxies.slice(i + 1) {
    // for each distinct pair of galaxies
    let bigger-x = calc.max(galaxy-1.x, galaxy-2.x)
    let bigger-y = calc.max(galaxy-1.y, galaxy-2.y)
    let smaller-x = calc.min(galaxy-1.x, galaxy-2.x)
    let smaller-y = calc.min(galaxy-1.y, galaxy-2.y)
    let distance = (bigger-x - smaller-x) + (bigger-y - smaller-y)
    let cols = expand-cols.filter(col => col >= smaller-x and col <= bigger-x).len()
    let rows = expand-rows.filter(row => row >= smaller-y and row <= bigger-y).len()
    distance += cols * (multiplier - 1)
    distance += rows * (multiplier - 1)
    // [- #galaxy-1.id, #galaxy-2.id --- #distance]
    distances.push(distance)
  }
}
#distances.sum()

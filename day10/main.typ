// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()
// #let input = "
// -L|F7
// 7S-7|
// L|7||
// -L-J|
// L|-JF
// ".trim()
// #let input = "
// 7-F7-
// .FJ|7
// SJLL7
// |F--J
// LJ.LJ
// ".trim()
// #let input = "
// ...........
// .S-------7.
// .|F-----7|.
// .||.....||.
// .||.....||.
// .|L-7.F-J|.
// .|..|.|..|.
// .L--J.L--J.
// ...........
// ".trim()
// #let input = "
// .F----7F7F7F7F-7....
// .|F--7||||||||FJ....
// .||.FJ||||||||L7....
// FJL7L7LJLJ||LJ.L-7..
// L--J.L7...LJS7F-7L7.
// ....F-J..F7FJ|L7L7L7
// ....L7.F7||L7|.L7L7|
// .....|FJLJ|FJ|F7|.LJ
// ....FJL-7.||.||||...
// ....L---J.LJ.LJLJ...
// ".trim()
// #let input = "
// FF7FSF7F7F7F7F7F---7
// L|LJ||||||||||||F--J
// FL-7LJLJ||||||LJL-77
// F--JF--7||LJLJ7F7FJ-
// L---JF-JLJ.||-FJLJJ7
// |F|F-JF---7F7-L7L|7|
// |FFJF7L7F-JF7|JL---7
// 7-L-JL7||F7|L7F-7F7|
// L.L7LFJ|||||FJL7||LJ
// L7JLJL-JLJLJL--JLJ.L
// ".trim()

// parse
#let area = input.split("\n").map(line => line.clusters())
#let start-pos
#for (y, row) in area.enumerate() {
  for (x, tile) in row.enumerate() {
    if tile == "S" {
      start-pos = (x: x, y: y)
      // replace S with actual tile
      let connects-top = y != 0 and area.at(y - 1).at(x, default: ".") in "|7F"
      let connects-bottom = area.at(y + 1, default: "").at(x, default: ".") in "|LJ"
      let connects-left = x != 0 and row.at(x - 1) in "-LF"
      let connects-right = row.at(x + 1, default: ".") in "-J7"
      assert((connects-top, connects-left, connects-bottom, connects-right).filter(it => it).len() == 2)
      area.at(y).at(x) = if connects-top and connects-right {
        "L"
      } else if connects-top and connects-bottom {
        "|"
      } else if connects-top and connects-left {
        "J"
      } else if connects-right and connects-bottom {
        "F"
      } else if connects-right and connects-left {
        "-"
      } else {
        "7"
      }
    }
  }
}
// #area.map(line => raw(line.join())).join("\n")
// #start-pos
#let connection-map = (
  "|": (top, bottom),
  "-": (left, right),
  "L": (top, right),
  "J": (top, left),
  "7": (left, bottom),
  "F": (right, bottom),
  ".": (),
)

// part 1
#let move(pos, dir) = {
  if dir == top {
    (x: pos.x, y: pos.y - 1)
  } else if dir == left {
    (x: pos.x - 1, y: pos.y)
  } else if dir == bottom {
    (x: pos.x, y: pos.y + 1)
  } else if dir == right {
    (x: pos.x + 1, y: pos.y)
  } else {
    panic("invalid direction: " + repr(dir))
  }
}
#let inverse(dir) = {
  if dir == top {
    bottom
  } else if dir == left {
    right
  } else if dir == bottom {
    top
  } else if dir == right {
    left
  } else {
    panic("invalid direction: " + repr(dir))
  }
}
#let steps = 0
#let prev-dir = connection-map.at(area.at(start-pos.y).at(start-pos.x)).first()
#let moves = ((tile: area.at(start-pos.y).at(start-pos.x), dir: prev-dir),)
#let pos = move(start-pos, prev-dir)
// work around Typst's 10_000 iteration limit
#while pos != start-pos {
  let steps-inner = 0
  while steps-inner < 10000 and pos != start-pos {
    prev-dir = connection-map.at(area.at(pos.y).at(pos.x)).find(it => it != inverse(prev-dir))

    // save the moves to replay in part 2
    moves.push((tile: area.at(pos.y).at(pos.x), dir: prev-dir))
    // and mark the main loop for part 2
    area.at(pos.y).at(pos.x) = "x"

    pos = move(pos, prev-dir)
    steps-inner += 1
  }
  steps += steps-inner
}
#((steps + 1) / 2)

// part 2
#{ area.at(start-pos.y).at(start-pos.x) = "x" }
#let spread-area(start, kind, area) = {
  let to-visit = (start,)
  while to-visit.len() > 0 {
    let pos = to-visit.remove(0)
    if pos.x < 0 or pos.y < 0 or pos.x >= area.at(0).len() or pos.y >= area.len() or area.at(pos.y).at(pos.x) in "ABx" {
      continue
    }
    area.at(pos.y).at(pos.x) = kind
    for dir in (top, left, bottom, right) {
      let new-pos = move(pos, dir)
      if new-pos.x < 0 or new-pos.y < 0 or new-pos.x >= area.at(0).len() or new-pos.y >= area.len() {
        continue
      }
      if area.at(new-pos.y).at(new-pos.x) not in "ABx" {
        to-visit.push(new-pos)
      }
    }
  }
  return area
}
#let ab-map = (
  "|top": (a: (left,), b: (right,)),
  "|bottom": (a: (right,), b: (left,)),
  "-right": (a: (top,), b: (bottom,)),
  "-left": (a: (bottom,), b: (top,)),
  "Ltop": (a: (bottom, left), b: ()),
  "Lright": (a: (), b: (bottom, left)),
  "Jtop": (a: (), b: (bottom, right)),
  "Jleft": (a: (bottom, right), b: ()),
  "7bottom": (a: (top, right), b: ()),
  "7left": (a: (), b: (top, right)),
  "Fbottom": (a: (), b: (top, left)),
  "Fright": (a: (top, left), b: ()),
)
#let pos = start-pos
#for m in moves {
  let ab = ab-map.at(m.tile + repr(m.dir))
  for dir in ab.a {
    area = spread-area(move(pos, dir), "A", area)
  }
  for dir in ab.b {
    area = spread-area(move(pos, dir), "B", area)
  }
  pos = move(pos, m.dir)
}
// hope that the outside area touches the top edge somewhere
#let outside = area.first().find(tile => tile != "x")
#let inside = if outside == "A" { "B" } else { "A" }
#area.join().filter(tile => tile == inside).len()

// #area.map(line => raw(line.join())).join("\n")

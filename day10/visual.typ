// page setup
#set page(width: auto, height: auto, margin: 1cm)

#let frames-start = int(read("./frames-start.txt").trim())
#let frames-count = 200
#let frame-counter = 0

// read input
#let input = read("./input.txt").trim()

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

#let mark-map = (
  "|": "┃",
  "-": "━",
  "L": "┗",
  "J": "┛",
  "7": "┓",
  "F": "┏",
)
#let show-area(area, frame-counter, lel: false) = {
  if frame-counter < frames-start or frame-counter >= frames-start + frames-count {
    return
  }
  if calc.rem(frame-counter, 10) != 0 { return }
  pagebreak(weak: true)
  set par(leading: 0.3em)
  for row in area {
    for tile in row {
      let color = if tile == "." {
        gray
      } else if tile in "|-LJ7F" {
        orange
      } else if tile in mark-map.values() {
        blue
      } else if tile == "█" {
        red
      } else if tile == " " {
        tile = "█"
        green
      }
      set text(fill: color)
      raw(tile)
    }
    linebreak()
  }
}

#show-area(area, frame-counter)
#(frame-counter += 1)
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
    let tile = area.at(pos.y).at(pos.x)
    prev-dir = connection-map.at(tile).find(it => it != inverse(prev-dir))

    // save the moves to replay in part 2
    moves.push((tile: tile, dir: prev-dir))
    // and mark the main loop for part 2
    area.at(pos.y).at(pos.x) = mark-map.at(tile)
    show-area(area, frame-counter)
    frame-counter += 1

    pos = move(pos, prev-dir)
    steps-inner += 1
  }
  steps += steps-inner
}

// part 2
#{ area.at(start-pos.y).at(start-pos.x) = mark-map.at(area.at(start-pos.y).at(start-pos.x)) }
#show-area(area, frame-counter)
#(frame-counter += 1)
#let spread-area(start, kind, area, frame-counter) = {
  let inner-frame-counter = 0
  let to-visit = (start,)
  let content = while to-visit.len() > 0 {
    let pos = to-visit.remove(0)
    if pos.x < 0 or pos.y < 0 or pos.x >= area.at(0).len() or pos.y >= area.len() or area.at(pos.y).at(pos.x) in "█ " + mark-map.values().join() {
      continue
    }
    area.at(pos.y).at(pos.x) = kind
    show-area(area, frame-counter + inner-frame-counter)
    inner-frame-counter += 1
    for dir in (top, left, bottom, right) {
      let new-pos = move(pos, dir)
      if new-pos.x < 0 or new-pos.y < 0 or new-pos.x >= area.at(0).len() or new-pos.y >= area.len() {
        continue
      }
      if area.at(new-pos.y).at(new-pos.x) not in "█ " + mark-map.values().join() {
        to-visit.push(new-pos)
      }
    }
  }
  return (area, content, inner-frame-counter)
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
    let (new-area, frames, added-frame-count) = spread-area(move(pos, dir), "█", area, frame-counter)
    area = new-area
    frame-counter += added-frame-count
    frames
  }
  for dir in ab.b {
    let (new-area, frames, added-frame-count) = spread-area(move(pos, dir), " ", area, frame-counter)
    area = new-area
    frame-counter += added-frame-count
    frames
  }
  pos = move(pos, m.dir)
}

#set page(width: auto, height: auto, margin: 1cm)

#let input = read("./input.txt").trim()
// 79..=92
// (52 50 48) -> 81..=94
// -          -> 81..=94
// -          -> 81..=94
// (18 25 70) -> 74..=87
// (68 64 13) -> 78..=80, (45 77 23) -> 45..=55
// -          -> 78..=80, ( 1  0 69) -> 46..=56
// (60 56 37) -> 82..=84, -          -> 46..=55, (60 56 37) -> 60..=60
// 55..=67
// (52 50 48) -> 57..=69
// -          -> 57..=69
// (49 53  8) -> 53..=56, -          -> 61..=69
// (18 25 70) -> 46..=49, (18 25 70) -> 54..=62
// (81 45 19) -> 82..=85, (81 45 19) -> 90..=98
// -          -> 82..=85, -          -> 90..=98
// (60 56 37) -> 86..=89, (60 56 37) -> 94..=96, (56 93  4) -> 56..=59, -    -> 97..=98
// seeds: 79 14 55 13
#let input = "
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
".trim()
// #let input = "
// seeds: 1 10
//
// seed-to-soil map:
// 10 0 20
//
// soil-to-fertilizer map:
// 0 6 10
//
// fertilizer-to-water map:
// 100 0 8
//
// water-to-light map:
// 150 106 1
//
// light-to-temperature map:
//
// temperature-to-humidity map:
//
// humidity-to-location map:
// ".trim()
// #let input = "
// seeds: 0 90
//
// seed-to-soil map:
// 200 0 30
// 100 30 30
// 300 100 30
//
// soil-to-fertilizer map:
// 500 100 200
//
// fertilizer-to-water map:
//
// water-to-light map:
//
// light-to-temperature map:
//
// temperature-to-humidity map:
//
// humidity-to-location map:
// ".trim()

#let start-seeds = input.split("\n\n").first().split("seeds: ").last().split(" ").map(int)
#let maps = input.split("\n\n").slice(1).map(map => {
  let (source, dest) = map.match(regex("^(\w+)-to-(\w+) map:")).captures
  let ranges = map.split("\n").slice(1).map(line => {
    let (dest-start, src-start, len) = line.split(" ").map(int)
    (dest-start: dest-start, src-start: src-start, len: len)
  })
  let a = (:)
  a.insert(source, (dest: dest, ranges: ranges))
  a
}).join()

#calc.min(..for seed in start-seeds {
  let dest = "seed"
  while dest != "location" {
    let map = maps.at(dest)
    for range in map.ranges {
      if seed >= range.src-start and seed < range.src-start + range.len {
        seed = range.dest-start + (seed - range.src-start)
        break
      }
    }
    dest = map.dest
  }
  (seed,)
})

#let seed-ranges = range(start-seeds.len(), step: 2).map(i => {
  let range = (start: start-seeds.at(i), len: start-seeds.at(i + 1))
  (..range, initial: range, stage: "seed")
})
#let finished-ranges = ()
#let prev-stage = ""
#while seed-ranges.len() > 0 {
  let range = seed-ranges.remove(0)

  // if on last stage, add to finished ranges and continue
  if range.stage == "location" {
    finished-ranges.push(range)
    continue
  }

  // if range.stage != prev-stage {
  //   prev-stage = range.stage
  //   [- #range.stage: #((range,) + seed-ranges)]
  // }
  [- #((range,) + seed-ranges)]

  let range-end = range.start + range.len
  let any-overlap = false
  for map-range in maps.at(range.stage).ranges {
    let map-range-end = map-range.src-start + map-range.len
    if range.start >= map-range.src-start and range-end <= map-range-end {
      // [- e #range]
      // the range is fully contained in the map range
      // -> adjust the start and add it to the queue in the next stage
      range.start += map-range.dest-start - map-range.src-start
      range.stage = maps.at(range.stage).dest
      seed-ranges.push(range)
      any-overlap = true
      // [- f #range]
      break
    }
    if range.start >= map-range.src-start and range.start < map-range-end {
      // [- c #range]
      // the range start is within the map range, the end is outside
      // -> split the range, advance the first half, continue looking for the second half
      let split-len = map-range-end - range.start
      seed-ranges.push((
        start: range.start + (map-range.dest-start - map-range.src-start),
        len: split-len,
        initial: (
          start: range.initial.start,
          len: split-len,
        ),
        stage: maps.at(range.stage).dest,
      ))
      range.start += split-len
      range.len -= split-len
      range.initial.start += split-len
      range.initial.len -= split-len
      seed-ranges.insert(0, range)
      any-overlap = true
      // [- d #range]
      break
    }
    if range-end > map-range.src-start and range-end <= map-range-end {
      // [- a #range]
      // the range end is within the map range, the start is outside
      // -> split the range, advance the second half, continue looking for the first half
      let split-len = map-range.src-start - range.start
      seed-ranges.push((
        start: map-range.dest-start,
        len: range.len - split-len,
        initial: (
          start: range.initial.start + split-len,
          len: range.len - split-len,
        ),
        stage: maps.at(range.stage).dest,
      ))
      range.len = split-len
      range.initial.len = split-len
      seed-ranges.insert(0, range)
      any-overlap = true
      // [- b #range #map-range]
      break
    }
    if range.start < map-range.src-start and range-end > map-range-end {
      // the range fully contains the map range
      // -> split at both intersection points, advance the middle part, keep looking for the other two
      let split-1 = map-range.src-start - range.start
      let split-2 = map-range-end - range.start
      seed-ranges.push((
        start: map-range.dest-start,
        len: map-range.len,
        initial: (
          start: range.initial.start + split-1,
          len: split-2 - split-1,
        ),
        stage: maps.at(range.stage).dest,
      ))
      seed-ranges.insert(0, (
        start: range.start,
        len: split-1,
        initial: (
          start: range.initial.start,
          len: split-1,
        ),
        stage: range.stage,
      ))
      seed-ranges.insert(1, (
        start: map-range-end,
        len: range-end - map-range-end,
        initial: (
          start: range.initial.start + split-2,
          len: range-end - map-range-end,
        ),
        stage: range.stage,
      ))
      any-overlap = true
      break
    }
  }
  if not any-overlap {
    // [- XXXXXXXXx #range]
    range.stage = maps.at(range.stage).dest
    seed-ranges.push(range)
  }
}
#finished-ranges
#finished-ranges.sorted(key: range => range.start).first().initial.start

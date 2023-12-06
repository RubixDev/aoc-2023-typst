// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()
// #let input = "
// Time:      7  15   30
// Distance:  9  40  200
// ".trim()

// parse
#let races = input.split("\n").first().trim("Time:", at: start).trim().split(regex(" +")).map(int).zip(
  input.split("\n").last().trim("Distance:", at: start).trim().split(regex(" +")).map(int)
).map(((time, distance)) => (time: time, distance: distance))
#races

// part 1
#let res = 1
#for race in races {
  let count-winning = 0
  for press-duration in range(race.time) {
    if (race.time - press-duration) * press-duration > race.distance {
      count-winning += 1
    }
  }
  res *= count-winning
}
#res

// part 2
// - re-parse the input
#let race = (
  time: int(input.split("\n").first().trim("Time:").replace(" ", "")),
  distance: int(input.split("\n").last().trim("Distance:").replace(" ", "")),
)
// #let race = (time: 10, distance: 10)
#race
// what we know:
// - duration of 0 and max time result in distance of zero
// - distance results are symmetrical
//   -> go from middle?
//   - from middle is too slow, instead start at 0 and look for first winning time
// #for press-duration in range(race.time + 1) {
//   enum.item(press-duration)[#((race.time - press-duration) * press-duration)]
// }
// not optimal (ran for 1 minute), binary search would be faster
#if calc.rem(race.time, 2) == 0 {
  // the middle exists once
  let result
  for press-duration in range(race.time) {
    if (race.time - press-duration) * press-duration > race.distance {
      result = ((race.time / 2) - press-duration) * 2 + 1
      break
    }
  }
  result
}
// missing impl for non-even race times

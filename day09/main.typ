// page setup
#set page(width: auto, height: auto, margin: 1cm)

// read input
#let input = read("./input.txt").trim()
// #let input = "
// 0 3 6 9 12 15
// 1 3 6 10 15 21
// 10 13 16 21 30 45
// ".trim()

// parse
#let report = input.split("\n").map(line => line.split(" ").map(int))
#let get-diffs(sequence) = {
  sequence.slice(1).enumerate().map(((idx-num1, num2)) => num2 - sequence.at(idx-num1))
}
#let full-report = report.map(history => {
  let histories = (history,)
  while not history.all(num => num == 0) {
    history = get-diffs(history)
    histories.push(history)
  }
  histories
})

// part 1
#full-report.map(histories => {
  histories.last().push(0)
  for i in range(1, histories.len()) {
    i = histories.len() - 1 - i
    histories.at(i).push(histories.at(i).last() + histories.at(i + 1).last())
  }
  histories.first().last()
}).sum()

// part 2
// i did not expect this to just work. i fully expected some kind of trickery in part 2
#full-report.map(histories => {
  histories.last().push(0)
  for i in range(1, histories.len()) {
    i = histories.len() - 1 - i
    histories.at(i).insert(0, histories.at(i).first() - histories.at(i + 1).first())
  }
  histories.first().first()
}).sum()

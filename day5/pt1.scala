import scala.io.Source
import scala.util.chaining.scalaUtilChainingOps

def parseLines(lines: List[String]): (List[(Long, Long)], List[Long]) = {
  lines.foldLeft((List[(Long, Long)](), List[Long]())) { (acc, line) =>
    val (ranges, ids) = acc
    line match
      case line if line.contains("-") => {
        val parts = line.split("-").map(_.toLong)
        assert(parts.size == 2)
        (ranges :+ (parts(0), parts(1)), ids)
      }
      case line if line != "" => (ranges, ids :+ line.toLong)
      case _ => acc
  }
}

def sortAndMerge(data: (List[(Long, Long)], List[Long])): (List[(Long, Long)], List[Long]) = {
  println(s"before merge $data")
  val (ranges, ids) = data
  val (sortedRanges, sortedIds) = (ranges.sortBy(_._1), ids.sorted)
  val mergedRanges = sortedRanges.tail.foldLeft(List(sortedRanges.head)) { (acc, current) =>
    // previous ends after current starts and before current ends
    val last = acc.head
    if (last._2 >= current._1) {
      acc.tail.prepended(Math.min(last._1, current._1), Math.max(last._2, current._2))
    } else {
      acc.prepended(current)
    }
  }.reverse
  (mergedRanges, sortedIds)
}

def countFresh(data: (List[(Long, Long)], List[Long])): Long = {
  println(s"counting fresh on $data")
  val (ranges, ids) = data
  var rangeIdx = 0
  ids.foldLeft(0) { (acc, id) =>
    println(s"checking if $id is valid")
    var range = ranges(rangeIdx)
    println(s"starting range $range")
    while (rangeIdx < ranges.size - 1 && range._2 < id) {
      rangeIdx += 1
      range = ranges(rangeIdx)
      println(s"skipping to next range $range")
    }
    if (id >= range._1 && id <= range._2) {
      println(s"id $id is fresh, part of $range")
      acc + 1
    } else {
      println(s"id $id is spoiled")
      acc
    }
  }
}

@main def main(): Unit = 
  Source.stdin.getLines.toList
    .pipe(parseLines)
    .pipe(sortAndMerge)
    .pipe(countFresh)
    .pipe(println)

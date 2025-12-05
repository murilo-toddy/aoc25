import scala.io.Source
import scala.util.chaining.scalaUtilChainingOps

def parseLines(lines: List[String]): List[(Long, Long)] = {
  lines.foldLeft((List[(Long, Long)]())) { (acc, line) =>
    line match
      case line if line.contains("-") => {
        val parts = line.split("-").map(_.toLong)
        assert(parts.size == 2)
        acc :+ (parts(0), parts(1))
      }
      case _ => acc
  }
}

def sortAndMerge(ranges: List[(Long, Long)]): List[(Long, Long)] = {
  val sortedRanges = ranges.sortBy(_._1)
  sortedRanges.tail.foldLeft(List(sortedRanges.head)) { (acc, current) =>
    // previous ends after current starts and before current ends
    val last = acc.head
    if (last._2 >= current._1) {
      val merged = (Math.min(last._1, current._1), Math.max(last._2, current._2))
      acc.tail.prepended(merged)
    } else {
      acc.prepended(current)
    }
  }.reverse
}

def countFreshIds(ranges: (List[(Long, Long)])): Long = {
  ranges.foldLeft(0.toLong) { (acc, range) =>
    val validIds = range._2 - range._1 + 1
    acc + validIds
  }
}

@main def main(): Unit = 
  Source.stdin.getLines.toList
    .pipe(parseLines)
    .pipe(sortAndMerge)
    .pipe(countFreshIds)
    .pipe(println)

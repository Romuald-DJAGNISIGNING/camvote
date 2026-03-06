package chapter2.milestones

data class CourseStudent(
    val name: String,
    val matricule: String,
    val ca: Double,
    val exam: Double,
)

interface GradePolicy {
    fun letterFor(score: Double): String
}

class StrictGradePolicy : GradePolicy {
    override fun letterFor(score: Double): String = when {
        score >= 85 -> "A"
        score >= 80 -> "B+"
        score >= 75 -> "B"
        score >= 70 -> "C+"
        score >= 65 -> "C"
        score >= 60 -> "D+"
        score >= 55 -> "D"
        else -> "F"
    }
}

abstract class ScoreComponent(
    private val weight: Double,
) {
    abstract fun value(student: CourseStudent): Double

    fun weighted(student: CourseStudent): Double = value(student) * weight
}

class ContinuousAssessment : ScoreComponent(weight = 0.30) {
    override fun value(student: CourseStudent): Double = student.ca
}

class FinalExam : ScoreComponent(weight = 0.70) {
    override fun value(student: CourseStudent): Double = student.exam
}

class StudentGradeCalculator(
    private val policy: GradePolicy,
    private val components: List<ScoreComponent>,
) {
    fun compute(student: CourseStudent): Pair<Double, String> {
        // Components are polymorphic, so this stays open for new score types later.
        val score = components.fold(0.0) { acc, component -> acc + component.weighted(student) }
        return score to policy.letterFor(score)
    }
}

fun runMilestone3Demo() {
    println("[Milestone 3 Demo]")

    val students = listOf(
        CourseStudent("Alice", "ST001", ca = 26.0, exam = 78.0),
        CourseStudent("Brian", "ST002", ca = 18.0, exam = 62.0),
        CourseStudent("Carla", "ST003", ca = 28.0, exam = 84.0),
    )

    val calculator = StudentGradeCalculator(
        policy = StrictGradePolicy(),
        components = listOf(ContinuousAssessment(), FinalExam()),
    )

    students
        .map { student -> student to calculator.compute(student) }
        .forEach { (student, result) ->
            val (score, letter) = result
            println("${student.name} (${student.matricule}) -> ${"%.2f".format(score)} [$letter]")
        }
}

fun main() = runMilestone3Demo()

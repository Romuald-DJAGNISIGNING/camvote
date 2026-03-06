package chapter2.milestones

data class StudentRecord(
    val name: String?,
    val matricule: String?,
    val score: Double?,
) {
    fun hasIdentity(): Boolean = !name.isNullOrBlank() || !matricule.isNullOrBlank()

    fun displayName(): String = name?.trim().takeUnless { it.isNullOrEmpty() }
        ?: matricule?.trim().takeUnless { it.isNullOrEmpty() }
        ?: "Unknown"
}

// I keep this generic so I can reuse the same helper for filtering or mapping.
fun <T> customProcess(items: List<StudentRecord>, transform: (StudentRecord) -> T): List<T> =
    items.map(transform)

fun runMilestone2Demo() {
    println("[Milestone 2 Demo]")

    val students = listOf(
        StudentRecord(name = "Alice", matricule = "ST001", score = 82.0),
        StudentRecord(name = null, matricule = "ST002", score = 67.5),
        StudentRecord(name = "", matricule = null, score = null),
        StudentRecord(name = "Brian", matricule = "ST004", score = 91.0),
    )

    val validStudents = students.filter(StudentRecord::hasIdentity)
    val passed = validStudents.filter { (it.score ?: 0.0) >= 65.0 }
    val scoreSum = validStudents.mapNotNull { it.score }.fold(0.0, Double::plus)
    val average = if (validStudents.isEmpty()) 0.0 else scoreSum / validStudents.size

    val labels = customProcess(validStudents) { "${it.displayName()} -> ${it.score ?: "X"}" }

    println("Total records: ${students.size}")
    println("Valid records: ${validStudents.size}")
    println("Passed records: ${passed.size}")
    println("Average score: ${"%.2f".format(average)}")
    println("Custom HOF output: ${labels.joinToString()}")
}

fun main() = runMilestone2Demo()

package chapter2.functions

data class Person(
    val name: String,
    val age: Int,
)

fun processList(numbers: List<Int>, predicate: (Int) -> Boolean): List<Int> =
    numbers.filter(predicate)

fun mapWordLengths(words: List<String>): Map<String, Int> =
    words.associateWith(String::length)

fun averageAgeStartingWith(people: List<Person>, initials: Set<Char>): Double {
    val ages = people
        .filter { it.name.firstOrNull()?.uppercaseChar() in initials }
        .map(Person::age)

    return if (ages.isEmpty()) 0.0 else ages.average()
}

fun runFunctionExercises() {
    println("[Functions/Collections Exercises]")

    val numbers = listOf(2, 5, 8, 11, 14, 17)
    val evenNumbers = processList(numbers) { value -> value % 2 == 0 }
    println("Exercise 1 - filtered even numbers: $evenNumbers")

    val words = listOf("kotlin", "map", "filter", "class", "ui")
    val lengths = mapWordLengths(words)
    val longerThanFour = lengths.filterValues { it > 4 }
    println("Exercise 2 - word lengths: $lengths")
    println("Exercise 2 - length > 4: $longerThanFour")

    val people = listOf(
        Person("Alice", 20),
        Person("Brian", 24),
        Person("Carla", 22),
        Person("Ben", 26),
        Person("David", 21),
    )
    val avgAge = averageAgeStartingWith(people, setOf('A', 'B'))
    println("Exercise 3 - average age for A/B names: ${"%.2f".format(avgAge)}")
}

fun main() = runFunctionExercises()

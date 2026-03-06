package chapter2.classes

import kotlin.math.PI

abstract class Animal(
    val name: String,
    val legs: Int,
) {
    abstract fun sound(): String

    fun describe(): String = "$name has $legs legs and says '${sound()}'"
}

class Dog(name: String) : Animal(name, legs = 4) {
    override fun sound(): String = "Woof"
}

class Cat(name: String) : Animal(name, legs = 4) {
    override fun sound(): String = "Meow"
}

sealed class NetworkState {
    data object Loading : NetworkState()
    data class Success(val payload: String) : NetworkState()
    data class Error(val reason: String) : NetworkState()
}

fun handleState(state: NetworkState): String = when (state) {
    NetworkState.Loading -> "Loading..."
    is NetworkState.Success -> "Success: ${state.payload}"
    is NetworkState.Error -> "Error: ${state.reason}"
}

interface Drawable {
    fun area(): Double
}

class Circle(private val radius: Double) : Drawable {
    override fun area(): Double = PI * radius * radius
}

class Square(private val side: Double) : Drawable {
    override fun area(): Double = side * side
}

fun runClassExercises() {
    println("[Classes/OOP Exercises]")

    val zoo: List<Animal> = listOf(Dog("Rex"), Cat("Milo"))
    println("Exercise 1 - zoo: ${zoo.joinToString { it.describe() }}")

    val states = listOf(
        NetworkState.Loading,
        NetworkState.Success("Report downloaded"),
        NetworkState.Error("Timeout"),
    )
    println("Exercise 2 - network states: ${states.joinToString { handleState(it) }}")

    val shapes: List<Drawable> = listOf(Circle(3.0), Square(4.0))
    val areas = shapes.map { it.area() }
    println("Exercise 3 - shape areas: ${areas.joinToString { "%.2f".format(it) }}")
}

fun main() = runClassExercises()

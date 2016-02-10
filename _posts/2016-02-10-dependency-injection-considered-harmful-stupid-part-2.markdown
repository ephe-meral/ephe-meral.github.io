---
layout: post
title: "Dependency Injection Considered <del>Harmful</del> Stupid - Part 2"
date: 2016-02-10T05:56:34+01:00
tags:
- programming
- elixir
- entity_systems
---
After messing around with dependency injection frameworks in the [first part]({% post_url 2016-01-15-dependency-injection-considered-harmful-stupid %}), lets see how we can take our LotR example and unclutter it by using data-oriented functional programming in [Elixir](http://elixir-lang.org/)!

<!--more-->

Remember Frodo from last time? I already mentioned that Frodo's data can be merged with Sam's because they basically do almost everything together - which means that when we use their data for calculations, we will most likely need both of them for meaningful results.<br/>
But not only that, no, we also have duplicated data! It's hidden (well, on purpose) in the AbstractHobbit superclass: The two of them have a certain value for hunger and for miles walked. Since they always march together, however, these two values will more or less stay the same - or at least we'd have to make sure to keep them in sync, so that Frodo for example doesn't hunger more and walk less while Sam is already at the Mount Doom.

Let's revisit the data structure from last time:

```elixir title: "The Baggins/Gamgee Complex, Revisited"
defmodule Companions do
  defstruct(
    hunger_level: 0,         # they hunger together
    miles_walked: 0,         # they march together
    ring:         :the_ring, # ...hm... this should be stored somewhere else
    provisions:   100)       # and they share their bread!
end
```

_Note that this small elixir snippet tells the compiler to structurally check maps annotated with `Companions`. It's not very crucial for our logic later on, since we'll treat input as any kind of map having defined certain keys. However, it illustrates nicely how to define named datastructures in Elixir. They are still a map - but define an additional `__struct__` key that holds the atom of the module (`Companions` in this case)._

Now, with object oriented thinking, while designing the methods for marching and eating etc., you would probably come up with some kind of functionality that is shared between the two Hobbit objects and put that in the AbstractHobbit class, and some kind of functionality that is very Frodo or Sam specific and pack that in their respective classes. You would also need to reason about the dependency between Frodo and Sam, and how provisions are distributed between them etc.<br/>
By reducing the data we work with to a minimum, however, and by arranging it in a very simple datastructure, we can implement this logic in a rather straightforward way without ever having to think of inheritance, encapsulation etc.

But before we do that, let's make very sure - down to a specification of sorts - that we know exactly what kind of functionality we need. As opposed to thinking in terms of objects and taking their point of view (i.e. what they can do, whom they can interact with, what kind of state they have etc.), we want to think like a computer, that is, in terms of data transformations (what do I have as an input, what do I need to produce as an output).

* we want the Hobbits to reach mount doom by marching (e.g. let's define the goal to be at 100 miles)
  * marching a mile will increase the hunger level, let's say by 2 units, but
  * marching is only possible if the hunger level does not exceed a certain value, let's say 100
  * if the hobbits are too hungry (see above) they die and cannot complete their mission _\*BAM BAM BAM!\*_
* the hunger level can be decreased by eating provisions, which should be measured in the same units as hunger
  * comsuming X provisions decreases the hunger by X
  * the hobbits cannot eat all of their provisions at once, let's say the maximum is 2 units
* in all the above points, common sense applies (i.e. hunger and provisions can not be negative etc.)

In [Elixir](http://elixir-lang.org/), we can more or less take specifications like this and put it into code:

```elixir title: "'Specification-Driven-Programming' ?"
defmodule Walking do
  # the hunger level should not exceed 100, otherwise fail!
  def walk(%{hunger_level: hunger}) when hunger > 100,
  do: {:error, "Unable to walk! Dying of hunger - GAME OVER"}

  # marching increases the hunger level
  def walk(%{hunger_level: hunger, miles_walked: miles} = creature) do
    {:ok, %{creature |
      hunger_level: hunger + 2,
      miles_walked: miles + 1}}
  end
end

defmodule Feeding do
  # common sense and such
  def feed(%{hunger_level: hunger, provisions: provisions} = creature)
  when hunger <= 0 or provisions <= 0, do: creature

  # consuming provisions decreases the hunger
  def feed(%{hunger_level: hunger, provisions: provisions} = creature) do
    # we cannot eat more than 2 provisions at a time (if available and needed)
    eaten = 2 |> min(hunger) |> min(provisions)
    %{creature |
      hunger: hunger - eaten,
      provisions: provisions - eaten}
  end
end
```

Okay, let's take a step back. So where is Sam? And, more importantly, where are Frodo, Gandalf and the rest?

Who cares? We now only require datasets that can store hunger and miles values for walking around - it doesn't really matter whether they are associated with a Hobbit-like entity or something like an Orc.<br/>
This means we just enabled Saurons army to march around, given enough provisions. We also decoupled walking from food consumption - if you're modelling a magical being that feeds on the souls of its enemies, it can still use our walking logic, provided that it can actually hunger.

In a real application this can be used in many different ways. Consider a Hobbit situation:

```elixir title: "The Journey"
defmodule Journey do
  import Feeding
  import Walking

  def time_passes(%Companions{} = companions), do: time_passes({:ok, companions})

  def time_passes({:ok, %Companions{miles_walked: miles}})
  when miles >= 100, do: "Ring destroyed, all good! - GAME OVER"

  def time_passes({:ok, %Companions{} = companions) do
    companions
    |> consider_eating
    |> walk
    |> time_passes
  end

  def time_passes({:error, reason}), do: reason

  def consider_eating(%Companions{
      hunger_level: hunger,
      provisions: provisions} = companions)
  when (hunger > 10) and provisions > 0, do: feed(companions)

  def consider_eating(companions), do: companions
end

# start the journey and wait for what happens...
Journey.time_passes(
  %Companions{
    hunger_level: 0,
    miles_walked: 0,
    provisions: 100})
# "Unable to walk! Dying of hunger - GAME OVER"

# ...guess how much provisions we need to provide
# the Hobbits with to survive the journey...

```


Alright, this concludes my little rant about dependency injection and object orientation. If you'd like to read more about the design approach used in this article, I'd recommend looking into entity-component-systems, which is covered in great detail and with loads of examples by Adam on [his blog](http://t-machine.org/index.php/category/entity-systems/).



---
title: Dependency Injection Considered ~~Harmful~~ Stupid
slug: di-considered-stupid-pt1
date: 2016-01-15T10:56:34Z
tags:
- dependency_injection
- programming
- java
- rant
---

Ever used a dependency injection framework? Yes? In an object oriented language?

<!--more-->

If it hadn't been clear before: I dislike object-oriented programming.
Its my personal opinion that OOP is an unnecessary overhead **in most cases**. Yes, there might be some systems that benefit from it, but most of the time (see its usage in Java for example) it is exactly that: Abstraction with no benefit.

Now let's make one thing clear. This opinion is not based on the fact that I haven't spent much time with OOP or that I am simply better with other paradigms. I have worked several years with OOP and design patterns and clever hierarchies and composition and encapsulation and whatnot - to what effect? Boilerplate code that protects developers from other developers just so nothing in the brittle mess of a system breaks and brings it to fall.

_Hm. I didn't want to write about OOP actually... let's save that for another post._

The little introduction, however, was necessary to understand why dependency injection basically is nothing more than a little bit of air-freshener ontop of the unmaintainable pile of s\*\*t that an object-oriented-design most probably produced.

> **DISCLAIMER:** Forgive me for **a)** using Java in this post and **b)** for probably making syntactic mistakes. I use it here because it illustrates its own crappyness pretty nicely, and the mistakes might stem from me luckily not using it very often these days.

### The idea of dependency injection (DI)

Suppose you have two objects, Frodo and Sam. _(For a real setup, suppose you have 5k classes and around 50k objects)_ Now, suppose object Frodo depends on object Sam for its initialization. _(Again, for a real setup, suppose one of those objects depends on 10 others that each depend on 10 others and so forth)_ The Frodo object carries the heavy burden of the Ring datastructure, so it needs a supporting companion to take care of the provisions for the long march. _(And again, for a real setup, add at least one Gollum dependency as well)_

What we want to focus on, is how Frodo would get introduced to Sam and the Ring.<br/>
Let's illustrate this unusefully trivial example with a bit of good old Java, and mix in some object-oriented design stuff to make it more obfuscated (and more real...):

{{< code-title "The Fellowship" >}}{{< highlight java "linenos=inline" >}}
public abstract class AbstractHobbit {
  protected Integer hungerLevel = 0;
  protected Integer milesWalked = 0;
  // incomplete at this point. might define provision etc.
}

public class Frodo extends AbstractHobbit {
  private final Ring theRing;
  private AbstractHobbit companion;

  public Frodo(Ring theRing, AbstractHobbit companion) {
    this.theRing = theRing;
    this.companion = companion;
  }
}

public class Sam extends AbstractHobbit {
  // let's give Sam a purpose too...
  private Food provisions = new LembasBreadLoaf();
}
{{< /highlight >}}

*Note that I introduced AbstractHobbit, because keeping the code [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself) like this is considered a 'good practice' in Java... and because it looks funny.*

Now, in order to wire this up, all you need is an object that knows both Frodo and Sam:

{{< code-title "The Sorcerer" >}}{{< highlight java "linenos=inline" >}}
public class Gandalf {
  private Hobbit ringBearer;

  // for obvious reasons, a Gandalf object is
  // a loner and doesn't have dependencies!
  public Gandalf() {
    Ring theRing = new Ring(); // actually stolen from Bilbo, but who cares

    // initializing Frodo and Sam *within* a Gandalf
    // might be a bit semantically weird,
    // but we do it for illustrative purposes
    Sam sam = new Sam();
    this.ringBearer = new Frodo(theRing, sam);
  }
}
{{< /highlight >}}

This is what is commonly known as manual 'constructor-based dependency injection': Instead of letting Frodo create a Sam instance, we have another object that creates a Frodo and 'injects' a Sam into it. _I just love this metaphor!_

Generally speaking, you could consider any call to a function and passing of parameters as 'dependency injection' - the function depends on its parameters and doesn't know about how they were created and by whom. This leads to the conclusion that actually, all purely functional programming languages 'use dependency injection', or, if you put it the other way round, using dependency injection extensively will make your object-oriented program a bit more functional in some sense. _Which is a good thing, IMHO_

The reason to use this principle or pattern instead of simply creating a Sam inside a Frodo is that the latter is now decoupled from the concrete instance of its companion - it could also be given an instance of a Pippin instead. This makes the Frodo easier to test as you can inject any kind of mocked AbstractHobbit, and it also makes the whole code base easier to maintain, as Frodo doesn't need to be changed when Sam changes. (Though Gandalf might have to change in that case...)

### Dependency-injection frameworks

Alright, so far so good. Now, let's do the same thing with Sauron and let him initialize a List of 10000 Orcs with different features, armor, weapons and hierarchies...

{{< code-title "Sauron and the Orcs" >}}{{< highlight java "linenos=inline" >}}
public class Orc extends Creature {
  private Armor armor;
  private Weapon weapon;
  private Creature boss;

  public Orc(Armor armor, Weapon weapon, Creature boss) {
    this.armor = armor;
    this.weapon = weapon;
    this.boss = boss;
  }
}

public class Sauron extends Creature {
  private Orc leader;
  private List<Orc> orcs = new ArrayList<Orc>();

  public void createOrcs() {
    // the topmost orc in the hierarchy only reports to us!
    this.leader = new Orc(new ChainArmor(), new WarHorn(), this);

    // let's give it some minions to play with...
    orcs.add(new Orc(new LeatherArmor(), new IronAxe(), this.leader));
    orcs.add(new Orc(new ClothArmor(), new LongBow(), this.leader));
    // ...
    // TODO: continue till orc 10000, and don't forget
    // to include some more sub-hierarchies! Divide et impera, HARR!
  }
}
{{< /highlight >}}

As we see, it takes quite some lines of code to wire up all the Orcs by doing a manual dependency injection here - and don'f forget the Orcs that depend on them, and then the Orcs depend on _them_ and then...

It takes so much code, in fact, that clever people came up with the Idea of abstracting it away by replacing that Sauron object with a somewhat omniscient registry of Orcs and other objects - in the following referred to as Tolkien (or dependency injection framework).

Each Orc object would then declare a list of stuff it needs, go to Tolkien, hand it that list, and get the actual 'stuff' back.

Let's see how this can be done with the help of [Guice](https://github.com/google/guice):

So, all it takes to inject armor, weapon and boss into an Orc now is to place the `@Inject` annotation above its constructor and off we go!

Oh wait, thats not true...

Yes, the DI framework can figure out some instance of Armor, Weapon and Boss. But no, it's not guaranteed to be the instance that we want. What if the Orc object gets the wrong Armor? Or the wrong boss? The battle would be over before it began.

So, necessary configuration doesn't magically go away by using DI frameworks!

{{< code-title "The Tedium of Tolkien" >}}{{< highlight java "linenos=inline" >}}
public class TolkienModule extends AbstractModule {
  @Override
  protected void configure() {
    // this should be filled with bindings from classes
    // to more concrete sub-classes, instances, providers etc.
    // however, we have interdependencies between instances of
    // the same class (Orc) which requires some extra work...
  }

  // this provider method will get the Sauron object injected, how cool!
  // (that is, if we bound it to type Creature and annotated it
  // with the name "Sauron" in some other DI module)
  @Provides @Named("Boss")
  Creature createBoss(@Named("Sauron") Creature sauron) {
    Orc boss = new Orc(new ChainArmor(), new WarHorn(), sauron);
    // looks like a cyclic dependency to me:
    sauron.setLeader(boss);
    return boss;
  }

  @Provides @Named("Soldiers")
  List<Orc> createSoldiers(@Named("Boss") Creature boss) {
    List<Orc> orcs = new ArrayList<Orc>();
    orcs.add(new Orc(new LeatherArmor(), new IronAxe(), boss));
    orcs.add(new Orc(new ClothArmor(), new LongBow(), boss));
    // ...
    // erm. wait a second. we still declare all that stuff explicitly?
    // also, we only have one level of army hierarchy so far...
    // we could probably somehow make this work with nice tools like
    // Multibindings and AssistedInject and FactoryModuleBuilder
    // but it gives me the chills only thinking about that!

    return orcs;
  }
}
{{< /highlight >}}

I can't guarantee that the code above works (it's incomplete anyways). This specific scenario is generally hard to realize with DI frameworks, since their common use case is more the injection of singleton service-like objects.

What I tried to show, though, is that once you use this or that design pattern or have a more non-standard object dependency hierarchy, you quickly get into the same or worse trouble that you'd get into when injecting the dependencies manually.

Although it looks as if these two approaches have the potential to simplify the initialization of objects in complex dependency-trees, they still both introduce extra code that does all this messy wiring-up.

Why, though? What makes code-decoupling and dependency management so hard? Well, let's see...

### The root of the evil <span>\\(\sqrt{-1}\\)</span>

In the Lord of the Rings, that would be Sauron, but in our case it is something else:<br/>
It's the deficits that come with using abstractions on top of abstractions to handle the complexity imposed by abstractions.

What have we done thus far? No logic. Just boilerplate code and declaring datastructures. We can just as well kick out the earlier, unclutter the code and strip it from its object-oriented parts. Revisit the classes and see what fields they have. I'll throw in a bit of pseudo code here to make it clearer:

{{< code-title "The Lord of the Rings, Abridged" >}}{{< highlight yaml "linenos=inline" >}}
Hobbit:
  hungerLevel: Integer
  milesWalked: Integer

Frodo: Hobbit with
  theRing: Ring
  companion: Hobbit

Sam: Hobbit with
  provisions: Food

# Gandalf is just needed for DI in our example,
# so we leave that out here - it doesnt contain any logic

Orc: Creature with
  armor: Armor
  weapon: Weapon
  boss: Creature

# Sauron and Tolkien are left aside as well
{{< /highlight >}}

For the following we want to consider `Ring`, `Food`, `Weapon` and `Armor` to just be more datastructure declarations. Think of them as the 'stats' of a weapon or the amount of kalories in the food - it can be as simple as an integer sometimes!


These definitions are all we need for our calculations of the fighting orcs and marching companions who need provisions to stay alive on the way. The rest of the code from the beginning of this post does have no purpose other than filling these fields with data, in an environment where it is (seemingly) hard and complicated to do so. It does not even implement any of the logic of marching and fighting, just the abstract relationships between objects like Frodo and Sam.<br/>Actually, for our scenario, we might argue that it is not even important to know about the relationship of those two, and might just consider them as one unit like so:

{{< code-title "The Baggins/Gamgee Complex" >}}{{< highlight yaml "linenos=inline" >}}
Companions:
  hungerLevel: Integer # they hunger together
  milesWalked: Integer # they march together
  theRing: Ring        # ...hm...
  provisions: Food     # and they share their bread!
{{< /highlight >}}

This might be counter intuitive. But as a developer we know the whole story. We can decide what kind of datastructure still obeys the semantics and makes implementing the business logic as simple as possible. By doing so, we can avoid complex dependencies right from the start, and filling these few fields with data initially is also not very difficult.<br/>
Remember that this initial configuration (especially if we are dealing with something as diverse as the orc-army) is **almost always** required and no tool can make it magically disappear.

That's a good thing! If you know what kind of data is fed into a program when it starts, you have a better chance of understanding the behaviour of it! If that data is split into pieces, mixed with logic and spread all over the object-tree though, constantly changing and producing states that are complex to trace and understand, then you easily end up in an unmaintainable mess of a project. Throwing a DI framework onto that might help in some cases, but why not making it less complex right from the start?

_Note at this point that you can **always** refactor code to contain **either** logic **or** datastructures, so defining something like the example above is not impossible under real conditions. The only reason why we didn't do it right from the start is because OOP is all about mixing up data and logic._

In a nutshell, if you're using DI because you think it is crucial for a project to be maintainable in the long run, you're probably not doing something harmful, but simply something unnecessary. That's not because DI is intrinsically bad, but because the weird principles of OOP force you to use something like that to manage all the dependencies of your objects. In carefully designing the datastructures outside of the context of an object, it might, however, be possible to avoid all that. So why not using a simpler, more data-oriented approach instead?

*For the OOP & DI lovers: If you find this post offensive, you probably suffer from a phenomenon known as the '[golden hammer](https://en.wikipedia.org/wiki/Law_of_the_instrument)'. Please take some time and think the arguments through. A classical program is never more than data-input -> computation -> data-output.*

And some famous last words: I'll give an example of a useful data-oriented functional implementation of the situation described above in a follow-up post, promised! In the meantime, I recommend reading [Noel's article](http://gamesfromwithin.com/data-oriented-design) about further aspects of data-oriented design, like performance gain - especially for games.

UPDATE:<br/>
As promised, here's the [follow-up post]({{< relref "2016-02-10-dependency-injection-considered-harmful-stupid-part-2.md" >}}).

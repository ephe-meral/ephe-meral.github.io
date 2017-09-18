---
title: "The Idea of the Unix Programming Environment"
date: 2016-07-01T14:55:24+01:00
tags:
- unix
- programming
---

Ever heard of the Unix principle? There are several actually, but the most well-known is the concept of "do one thing and do it well".

<!--more-->

This concept is something that, especially when it comes to programming, a lot of people would agree on. But why is this so seemingly universally true?<br/>
If you look at the concept from a distance it's almost mathematical: Think of functions. Want a complex wave function? Take the parts that you want encoded and combine them. Complexity as it occurs in nature is (and we can say that with more and more confidence) something that arises from the combination of a few, simple constructs.

Human made complexity, however, is usually going in the other direction: Complex systems, common in software engineering, are not composed of simple parts with some kind of higher-level algebra. No, usually, these systems just grew out of the fact that the engineering process required the engineers to add features on top of each other instead of combining existing ones.

### An engineer's perspective

Let's face it: In software architecture (and I'd argue in most other engineering disciplines) what we actually aim for is creating modular designs that are composed of re-usable components taking whatever shape. In reality though, changing requirements, tight deadlines, inexperienced system designers and inappropriate tools lead - very often - to error-prone, hard to maintain and generally unintelligible systems.

How do you recognize a highly reusable component? Make a thought experiment: If you would have to describe what the component does with a few, simple sentences, could you do so without referring to other parts of the system? Is the explanation self-contained and does it include a short, precise description of the interface of the component? You might notice that it's tough to obtain these properties.

Simplicity is _hard_ to achieve and complexity is created _easily_ - simplicity is usually also (intersubjectively) more elegant and aesthetic.

### Unix (a.k.a. a good idea)

_Note that in the following, whenever I am talking about a Unix system, I am actually referring to any kind of descendant from the original Unix or a unixoid system like Linux etc._

This elegance of simplicity is easily to be found in a Unix system. Where? In the most basic tools that it ships with. Ever heard of `sed`? Or of `awk`, `grep`, `cat` and so on and so forth. These tools are well known for their commitment to the idea of doing one thing and doing it well. The question for us as a user of a Unix system is now simply how to make use of them.

The view we often have of our operating system is that it's merely something that provides the basics (which are assumed to already include a GUI and related tools). I have rarely seen people who really appreciate and make use of the whole infrastructure of their operating system and all the functionality that it comes with.

Why would you want to do that? After all, we are living in the 21st century - there are nice GUI IDEs filled with magic and automating away your brain almost entirely. Who on earth would ever want to go back to text-based programs? It seems not only counter-productive in nature, but also really damaging the evolution of graphical solutions.

Well, why then? The answer is almost trivial: Because we as software developers don't produce nice graphics, we create and herd source code in precise and expressive plain-text. (To super progressive model-driven-development people who never actually touch text - of course this doesn't concern you...)

It might come as a surprise for some, but the tools that are shipped with a Unix system are specialised to work with text (or more generally, byte streams). The whole idea of e.g. `sed` and `awk` is to edit text that flows through these programs that act as filters and transformators. You create new tools by essentially placing existing ones in pipelines.

### Unix as a programming environment

How does the effort of learning and using these commands pay back? Maybe you don't want to develop your next big web project by pipelining Unix tools - this is understandable, since it might be more efficient and maintainable to use a general purpose programming language instead.

But what I am talking about is not to use these tools to for production-level engineering. No, I am referring to how developers use the operating system to create these software products. We might specialize in a single programming language (which is _really_ beneficial for the enterprise environment) and we learn to use our standard tool kit - for example IDEs - up to a point where using anything else becomes a hassle. If you achieve this point, you effectively pushed yourself to be a personified [golden hammer](https://en.wikipedia.org/wiki/Law_of_the_instrument).

### Text is the developer's magic wand

I recently discovered the [ACME](http://acme.cat-v.org/) editor (created by - who would have guessed - the Unix creators). Apart from the way you are supposed to interface with it (a 3 button mouse basically) it's main idea is that every piece of text displayed by the editor is potentially executable. It is either interpreted directly as a command, or it is taken as input to a command, or ran through a pattern matching tool to be able to follow links and files etc.<br/>
The concept basically enables you to make full use of your shell and your tools that come with it, directly in the editor, simply by clicking around.

Take a file-system viewer for example: We already have `ls` to display the files in the current working directory. To open folders and files, use a tool that can interpret strings as file or folder names, resolve them, and pipe it to another tool that either `cd && ls`'s or `cat`'s what it gets into a new buffer.<br/>
These are only basics, but it's more or less the interaction that any GUI file-system viewer would give you, re-implemented using a few simple unix commands.

This idea struck me as being so simple, yet so effective that I'm now looking to incorporate it into my own workflow. I don't use ACME, since I'm usually working from my laptop and using a mouse would be rather annoying (at least if you only have a touchpad with you), but I'm trying to enable my [NeoVim](https://neovim.io/) instance to be able to do these kind of things. The cool thing about this is that NeoVim already **is** highly text-based and has a simple way of interfacing with the shell, so that making use of it should not be a big problem.<br/>
Additionally, the community that has formed around this editor seems to really appreciate the Unix philosophies, and keeps on adding small useful tools as plugins.

### Summing up...

Rid yourself of unnecessary abstractions and free your brain of all the loose ends it has to herd when working with complexity. And remember that you are what you eat: Overly complex programming languages and tools won't magically enable you to write elegant code. Question your believes if you think that the OS has no other purpose than to provide the basic requirements for your full-fledged IDE.<br/>
_And please don't take my words as an advertisement for any specific piece of software._

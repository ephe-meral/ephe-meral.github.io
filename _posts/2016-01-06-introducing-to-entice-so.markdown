---
layout: post
title: "Introducing 'to entice so.'"
date: 2016-01-06T00:34:09+01:00
tags:
- programming
- elixir
- mmorpg
- open_source
- entity_systems
---
Despite the misleading title of this - it could as well be a social engineering guide - I'm going to introduce a free, libre and open-source software project that I'm in charge of.
<!--more-->
It's the first thing of this sort that I'll write about and also the first real post here. One might actually say that I've gone through the lengths of creating this blog just to write about this specific project and related topics. (But I won't, promised)

### So what are we talking about?

['to entice so.'](https://github.com/entice/entice) (or just 'entice' for short) is a client/server application aiming to provide an MMORPG sandbox of sorts.
While this fact in itself might not be very interesting, the approach used and the technology involved actually are - at least in my humble opinion.

I'll split this topic up into several posts to highlight different aspects of the project, but let me at least give a little overview at this point.

The code covers both [client](https://github.com/entice/client) and [server](https://github.com/entice/web) side parts, even though this is not a complete game on its own. Actually, we're instrumenting an existing _\*cough\* commercial \*cough\*_ client and try to follow the gameplay logic more or less. To be honest it's not very difficult to figure out which game I'm talking about, but for me personally the whole point of this is less about creating a so-called private server and more about experimenting with MMORPG server designs.

### Project structure

Splitting the project up in this instrumentation part on the client side and the server part with the gameplay logic, we gain an excellent and clean way of working on each independently. I'll go into more detail about this development model in a follow-up post later. For now, lets just say that it works out perfectly for our little team, since our collaborator's schedules differ a lot.

### Technology

Technology-wise, the client part is written in C/C++ and [C#](https://msdn.microsoft.com/en-us/vstudio/hh341490.aspx) relying on standard .NET features, whereas the server is written in [Elixir](http://elixir-lang.org/) using the [Phoenix framework](http://www.phoenixframework.org/). More about the reasons for the choice of these technology stacks later.

Also, since I'm most involved with the server side code, I'll focus on those parts in the upcoming posts. If you want to learn more about the client side software design, you can either check out the code in our project [repos](https://github.com/entice), or get in touch with the main dev of these parts.

To finish up this rather short intro, be aware that all we're talking about here is freely accessible to anyone, and improvements and discussion of the code is always welcome. Feel free to join us on `#gwlpr` in the `irc.rizon.net` IRC net, and create github issues, forks and pull-requests to help improve the project.

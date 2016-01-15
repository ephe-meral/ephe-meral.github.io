---
layout: page
title: About
permalink: /about/
---

Will fill this with more content later. For now see the [Instruction Leaflet]({% post_url 2015-12-28-instruction-leaflet %})

```elixir title: "Why not?"
def fib(num),                    do: fib(num, 0, 1)
def fib(0, res, _),              do: res
def fib(n, res, nxt) when n > 0, do: fib(n-1, nxt, res + nxt)
```

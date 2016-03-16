---
title: About
slug: about
theme: herring-cove
---

Will fill this with more content later. For now see the [Instruction Leaflet]({{< relref "2015-12-28-instruction-leaflet.md" >}})

{{< code-title "Why not?" >}}{{< highlight elixir "linenos=inline" >}}
def fib(num),                    do: fib(num, 0, 1)
def fib(0, res, _),              do: res
def fib(n, res, nxt) when n > 0, do: fib(n-1, nxt, res + nxt)
{{< /highlight >}}

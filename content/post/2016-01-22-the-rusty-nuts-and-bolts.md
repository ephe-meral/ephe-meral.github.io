---
title: The Rusty Nuts and Bolts
date: 2016-01-22T00:00:34Z
tags:
- programming
- rust
---

Lately I've been messing around with the [Rust](https://www.rust-lang.org/) programming language. Here's to the why, how and what.

<!--more-->

**Some context first though:** I recently decided to refresh and build up my math skills, since the education at my former uni was rather practically oriented and also some time ago already. Additionally, I felt like I'm lacking some of the challenges of discovering and understanding new concepts, particularily the more abstract ones.<br/>
It's true that as a Scala developer I usually face new language or framework related hurdles on a daily basis, but thats a totally different level. It's not as exciting to fix a bug compared to finally getting the hang of some category theory topic.

However, just reading and understanding maths books is actually a rather dull activity. The real magic happens when you're able to apply this new knowledge onto some kind of example. Thats why I came up with the idea of simply trying to implement the concepts of my books as a small library - which is also a rather great opportunity to try out a new programming language!

### The use case for Rust

Rust claims to be a both system-level and memory-safe language. This means that you should have the ability to take full control of your hardware (you can even write operating systems) while still maintaining some principles that keep you from shooting yourself in the leg with memory related issues.

Why is this interesting? After all, you can have something very similar with managed C++ or the like.<br/>
The difference is that Rust doesn't rely on garbage collection. The language is designed in such a way that it takes the complexity of manual runtime memory management and embeds it into compile-time compiler-checked features. Essentially, it forces you to write code in a way that will prevent memory leaks, data races, accessing of freed resources and so on.

Now, _usually_ I'm very comfortable with garbage-collected languages. However, I _do_ know about the additional overhead and non-determinism caused by the GC. Systems like the latter are also one of the main reasons why software that needs to be of really high-performance is not written in e.g. Java. Wouldn't it be great, then, to have a language that *enforces* the same level of safety that a managed language has, but doesn't come with the additional overhead of it at runtime?<br/>
All of this, by the way, is combined with an extensive type system and many features you'd find in functional programming languages.

### My use case

So, on I went with happily implementing some basic matrix operations in Rust for my [brand new library](https://github.com/ephe-meral/halcyon) (or 'crate' in Rust parlance). And, immediately I got stuck fighting with the compiler... partly because I was not obeying Rusts rules, and partly because I apparently hit a current language limit.

Consider the following implementation of matrix multiplication independent of the dimension:

{{< code-title "(Don't) Try This At Home" >}}{{< highlight rust "linenos=inline" >}}
fn multiply(mat_a: &[[f32]], mat_b: &[[f32]]) -> &[[f32]] {
    let dim_i = mat_a.len();
    let dim_k = mat_b.len();
    let dim_j = mat_b[0].len();
    let mut result = [[0.0; dim_j]; dim_i]; // nope. array sizes need to be const

    for i in 0..dim_i { for j in 0..dim_j { for k in 0..dim_k {
        result[i][j] += mat_a[i][k] * mat_b[k][j];
    }}}

    &result
}
{{< /highlight >}}

This won't compile. First of all, the function 'borrows' two pointers to matrices and returns another one. Here, Rust can't infer the time  that we need these references to be alive, which is part of the [ownership](https://doc.rust-lang.org/book/ownership.html) / [lifetime](https://doc.rust-lang.org/book/lifetimes.html) semantics. We can fix that by introducing an explicit lifetime variable:

{{< code-title "Fixing the Header" >}}{{< highlight rust "linenos=inline" >}}
fn multiply<'a>(mat_a: &'a [[f32]], mat_b: &'a [[f32]]) -> &'a [[f32]] {
    // ...
{{< /highlight >}}

Now, another problem is the `&'a [[f32]]` style of declaring a two-dimensional array slice. An array slice is a pointer to a part of a statically sized array. The compiler has some trouble defining a type like that though, so we cannot use `.len()` on the variables later on. For comparison: We could without a problem call `.len()` on an array slice defined like `&'a [f32]`.

But let's ignore that problem for now. I don't really care for arbitrary array slices... What I actually want is to accept an array directly and pattern match on the deconstructed array size. The declaration for an array goes like this: `[T; N]` where `T` is the type of the elements of the array, and `N` is the size. What I'd like to do is something more like this:

{{< code-title "If Only..." >}}{{< highlight rust "linenos=inline" >}}
fn multiply<I, J, K>(mat_a: [[f32; K]; I], mat_b: [[f32; J]; K]) -> [[f32; J]; I] {
    // ...
{{< /highlight >}}

With this approach we could also drop all the `.len()` calls, since theoretically the sizes would all be known at compile time. E.g. the loop's arguments `dim_i` etc. could be filled with `I`, `J` and `K` instead, as if these were variables in a macro that will be replaced when it gets called.

Speaking of which, to implement this with arbitrary array sizes I finally put the precision tools away and took the sledgehammer: [Rust Macros](https://doc.rust-lang.org/book/macros.html). To implement this multiplication I simply insert a sub-scope that does the whole thing for us in-line, roughly like so:

{{< code-title "Taking the Sledgehammer" >}}{{< highlight rust "linenos=inline" >}}
macro_rules! multiply {
    ($mat_a:ident: [$dim_i:expr, $dim_k1:expr], $mat_b:ident: [$dim_k2:expr, $dim_j:expr]) => {{
        assert_eq!($dim_k1, $dim_k2);
        let mut res = mat![$dim_i, $dim_j];
        for i in 0..$dim_i { for j in 0..$dim_j { for k in 0..$dim_k1 {
            res[i][j] += $mat_a[i][k] * $mat_b[k][j];
        }}}
        res
    }}
}
{{< /highlight >}}

That way, we still have to give the dimensions explicitly, but thats OK in my opinion. The macro can be invoked with a special syntax:

{{< code-title "Well, It Does the Job" >}}{{< highlight rust "linenos=inline" >}}
let a = [[0.3, 1.2], [3.2, 9.5], [6.0, 0.8]];
let b = [[7.0, 3.1], [4.3, 0.1]];

let result = mul!(a: [3, 2], b: [2, 2])
{{< /highlight >}}

As always with macros: Don't use macros - they're like abstractions and we don't use abstractions. Well, only if we must. In this case we do, until Rust implements something like arbitrating over the array size.

### Conclusion

All in all, it's an interesting language. It has loads of concepts that I think are going in the right direction of control _AND_ safety. After the tiny bits and pieces (nuts and bolts) that I saw of this, I think I'll keep it in mind for when a fast system-level language is needed and C is not an option.

By the way, with the given example I didn't want to complain about the language. It was just to illustrate my own first steps with Rust, and how quickly I hit borders.

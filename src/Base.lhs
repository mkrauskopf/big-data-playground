---
Playing with Big Data Coursera course related stuffs
---

> import Text.Printf -- will be used for pretty-printing

Method measuring the amount of information in _bits_ for an event with
probability `p`.

> informationBits :: Double -> Double
> informationBits p = -(logBase 2 p)

With increasing probability the amount of information decreases:

~~~{.haskell}
sequence_  [ printf "%.2f -> %.2f\n" a $ informationBits a | a <- [0.99, 0.8 .. 0]]
~~~

Produces:

~~~
0.99 -> 0.01 bits
0.80 -> 0.32 bits
0.61 -> 0.71 bits
0.42 -> 1.25 bits
0.23 -> 2.12 bits
0.04 -> 4.64 bits
~~~

Interesting articles
--------------------
<a href="http://www.euclideanspace.com/maths/statistics/i_theory/bits.htm">Measuring Bits of Information</a>.


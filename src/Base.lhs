Literate Haskell notes from Big Data Coursera course and related materials
==========================================================================

Just a standard prelude:

> import Data.Char(toLower)
> import Data.List(foldl')
> import Data.Maybe
> import Text.Printf(printf)
> import qualified Data.Map as M

Basics
------
Method measuring the amount of information in _bits_ for an event with
probability `p`.

> informationBits :: Double -> Double
> informationBits p = -(logBase 2 p)

With decreasing probability the amount of information increases. Following
snippet:

~~~{.haskell}
sequence_  [ printf "%.2f -> %.2f\n" p $ informationBits p | p <- [0.99, 0.8 .. 0]]
~~~

produces:

~~~
0.99 -> 0.01 bits
0.80 -> 0.32 bits
0.61 -> 0.71 bits
0.42 -> 1.25 bits
0.23 -> 2.12 bits
0.04 -> 4.64 bits
~~~

Interesting articles
[Measuring Bits of Information](http://www.euclideanspace.com/maths/statistics/i_theory/bits.htm)


TF-IDF and related stuffs
-------------------------
Define few type aliases for further type-signatures to be clearer.

> type Document = String
> type Term = String
> type DocumentFrequency = M.Map String Integer

Text Frequency
---

> -- Computes /term frequency/ a number of a term occurrences in a given
> -- document.
> tf :: Term -> Document -> Double
> tf term doc = termOcc / docLen
>   where (termOcc, docLen) = foldl' f (0,0) (words doc)
>         f (to, dl) term' = (if term == term' then to + 1 else to, dl + 1)

Running `tfSample`:

> tfSample :: IO ()
> tfSample = mapM_ printOcc ["the", "course", "non-existing"]
>   -- TODO: "media" gives zero since "media," token is given
>     where docs' = map toLower docs
>           docs = "The course is about building `web-intelligence' applications \
>                  \exploiting big data sources arising social media, mobile \
>                  \devices and sensors, using new big-data platforms based on the \
>                  \'map-reduce' parallel programming paradigm. The course is \
>                  \being offered"
>           printOcc term = printf "%s -> %.2f\n" term $ tf term docs'

produces:

~~~
the -> 0.09
course -> 0.06
non-existing -> 0.00
~~~

Inverse Document Frequency
---

Define some sample data used in samples below:

> sampleTerms :: [Term]
> sampleTerms = ["car", "auto", "insurance", "best"]

> sampleDF :: DocumentFrequency
> sampleDF = M.fromList [ ("car", 18165)
>                       , ("auto", 6723)
>                       , ("insurance", 19241)
>                       , ("best", 25235)
>                       ]

> sampleDoc1, sampleDoc2, sampleDoc3 :: Document
> sampleDoc1 = add 27 "car "  ++ add 3  "auto " ++ add 0  "insurance " ++ add 14 "best "
> sampleDoc2 = add 4  "car "  ++ add 33 "auto " ++ add 33 "insurance " ++ add 0  "best "
> sampleDoc3 = add 24 "car "  ++ add 0  "auto " ++ add 29 "insurance " ++ add 17 "best "
> add n w = concat $ replicate n w

> sampleN :: Integer
> sampleN = 806791

Explanations and points to resources are given as the data are used in
individual samples.

> -- Computes /inverse document frequency/ of a given term. For rarely
> -- occurring terms the result will be high whereas for frequently occurring
> -- ones will be low.
> idf :: Term
>     -> DocumentFrequency
>     -> Integer -- ^ total number of documents
>     -> Double
> idf t df n = logBase 2 (fromInteger n / fromInteger dft)
>   where dft = fromMaybe 1 $ M.lookup t df
> -- TODO: probably we should return Maybe Double instead cheating with default '1'

Following snippet computes _Inverse Document Frequency_ on a sample used it the
[ItIR] book in [chapter][ItIR-IDF] dedicated to the topic.

Running `idfSample`:

> idfSample :: IO ()
> idfSample = mapM_ printIDF sampleTerms
>     where
>       printIDF term = printf "%s -> %.2f\n" term $ idf term sampleDF sampleN


produces:

~~~
car -> 5.47
auto -> 6.91
insurance -> 5.39
best -> 5.00
~~~

tf-idf weighting
---

> -- Computes _tf-idf_ for a given term in a document using given document
> -- frequency and total number of documents.
> tfIdf :: Term -> Document -> DocumentFrequency -> Integer -> Double
> tfIdf t d df n = tf t d * idf t df n

Running `tfIdfSample`:

> tfIdfSample :: IO ()
> tfIdfSample = mapM_ printTfIdfForDoc docs
>     where
>       docs = [sampleDoc1, sampleDoc2, sampleDoc3]
>       printTfIdfForDoc :: Document -> IO ()
>       printTfIdfForDoc doc = putStrLn "---------" >> mapM_ (printTfIdf doc) sampleTerms
>       printTfIdf :: Document -> Term -> IO ()
>       printTfIdf doc term = printf "%s -> %.2f\n" term $ tfIdf term doc sampleDF sampleN

produces results for each sample document:

~~~
---------
car -> 3.36
auto -> 0.47
insurance -> 0.00
best -> 1.59
-----------
car -> 0.31
auto -> 3.26
insurance -> 2.54
best -> 0.00
-----------
car -> 1.88
auto -> 0.00
insurance -> 2.23
best -> 1.21
~~~

[ItIR-IDF]: http://nlp.stanford.edu/IR-book/html/htmledition/inverse-document-frequency-1.html "Inverse document frequency"
[ItIR-TF-IDF]: http://nlp.stanford.edu/IR-book/html/htmledition/tf-idf-weighting-1.html "Tf-idf weighting"
[ItIR]: http://nlp.stanford.edu/IR-book/html/htmledition/irbook.html "Introduction to Information Retrieval"


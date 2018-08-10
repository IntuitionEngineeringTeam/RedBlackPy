<center> <h1>RedBlackPy </h1> </center>
<center> <h4>Fast and scalable data structures for scientific and quantitative research in Python </h4> </center>

<h3>Now available for Python 3.6+ on MacOS and Linux (Windows in near future).</h3>

RedBlackPy is a light Python library that provides data structures aimed to fast insertion, removal and self sorting to manipulating ordered data in efficient way. The core part of the library had been written on C++ and then was wrapped in <a href="http://cython.org">Cython</a>. Hope that many would find the primary data structures of this library very handy in working with time series. One of the main feature of this structures is an access by arbitrary  key using interpolation, what makes processing of multiple non synchronized time series very simple. All data structures based on red black trees.


<center> <h3>Installation </h3> </center>
Now RedBlackPy requires Cython installation. If you have not Cython, run in your command line:

~~~shell
>> pip install cython
~~~

<h5> 1. Build and install from source </h5>
Download project source and run in your command line

~~~shell
>> python setup.py install
~~~

<h5> 2. Via pip </h5>
Run in your command line

~~~shell
>> pip install redblackpy
~~~

<center> <h3>Package content</h3> </center>
The first release is presented by two classes: Series and SeriesIterator. See documnetation and user guide for usage.

<br>
<center> <h3>Cython Users</h3> </center>
We have include pxd files for Cython users. See source.

<br>
<center> <h3>Contact us</h3> </center>

Feel free to contact us about any questions. Website of our team [IntuitionEngineering](https://intuition.engineering).

Core developer email: hypo@intuition.engineering.

Intuition dev email: dev@intuition.engineering.


# YLPaintShop
<a href="https://github.com/yuhuili">![Yuhui Li](https://githubtools.yuhuili.com/kagami/yuhuili/Yuhui%20Li/)</a>

YLPaintShop is a Swift library for simple image effects. It is written in Swift 3 and uses Core Graphics.

It is inspired by Stanford CS106B Spring 2016 Assignment Fauxtoshop, which requires a simple photo editor to be built in C++ with Stanford's own library. Same effects are achieved by YLPaintShop in Swift.

## Effects
* Scatter
```
img.scatter(radius)
```

* Paint Edge
```
img.paintEdge(threshold)
```

* Gaussian Blur
```
img.gaussianBlur(radius)
```

## Examples
<img src="GitHub/14351.png" width="400">

```
img.scatter(10)
```

------

<img src="GitHub/15236.png" width="400">

```
img.paintEdge(140)
```

------

<img src="GitHub/18718.png" width="400">

```
img.gaussianBlur(10)
```

------

<img src="GitHub/13150.png" width="400">

```
img.scatter(8).gaussianBlur(5)
```

------

<img src="GitHub/16109.png" width="400">


```
img.paintEdge(140).gaussianBlur(3)
```

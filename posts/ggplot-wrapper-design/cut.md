
# Cut

## Summary

There are multiple ways to reuse ggplot2 recipes, including writing wrapper functions. However, wrapper functions that return complete ggplots often obscure the underlying ggplot2 syntax. This opacity can make it frustratingly difficult for users to produce even slight variations on default plots, and often requires learning plot-specific arguments rather than modifying ggplot components in familar ways. The proper solution would be to create new ggplot2 components that are consistent with the grammar of graphics framework and philosophy. However, designing and implementing a proper solution is not feasible for most people. An alternative partial solution is to design wrapper functions for ggplot2 recipes according to the following principles:

- separate data transformation steps from ggplot construction
- expose as much of the internal ggplot2 construction syntax as possible. I suggest doing this with list inputs to “layer” arguments.
- explicitly document the internal workings of the wrapper function

I show how I used these principles to design functions in the package `ggtilecal`.

## Don't Repeat Yourself for `{ggplot2}` code

There are a few ways to package and reuse `ggplot2` code:

- copying and pasting, changing arguments as needed
- lists of layers, or functions that return lists of layers
- wrapper functions like [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html), which provide all-in-one
- "proper" grammar-of-graphics consistent components:
	- data transformation via stats,
	- geometries or combinations of geometries via geoms
	- scale, coord, positions, facets
	- theme
- ggplot2 extensions packages, which can include any combination of lists, wrapper functions and new ggplot2 components.

Copying and pasting is pretty self-explanatory, but very quickly fails the DRY (Don't Repeat Yourself) principle for writing clean code and scripts.

Lists work particularly well for sharing non-data layers between multiple related plots ^[See this [StackOverflow question](https://stackoverflow.com/a/44721060) for example], and can support some customisation via function arguments. For example, the following variation on a [StackOverflow answer](https://stackoverflow.com/a/56990160) adds two point geoms to the left and right of a specified `x_val`, with the same `color`.

### ASIDE: *Tailoring plots to particular data types* in ggplot2

While writing this article, I discovered that `ggplot2` provides some guidance on designing wrapper functions in the documentation for [`automatic-plotting`](https://ggplot2.tidyverse.org/reference/automatic_plotting.html) which covers:

- `fortify()` for data preparation
- `autolayer()` to return a list of layers
- `autoplot()` to return a complete plot

The design advice is somewhat hidden by the framing of `autoplot()` as a extension mechanism to making plotting particular data types (e.g. S3 objects) easier. However, it seems to follow the same principle of separating data prepation (i.e. via `fortify()`) from ggplot construction (i.e. `autolayer()` and `autoplot()`)


## Notes
Don't repeat yourself --> 5 are building on top, 1 is different (philosophy)

Not why, but how to do it better

Making building on top of the grammar less bad
Extending ggplot2 is not necessarily extending grammar of graphics
Building with ggplot2 --
Extensions that use ggplot vs extending ggplot
 - confusion / conflation

Need, problem, solution (ggtilecal)

Design problem -- wrapper functions with application to ggplot2
	- alternative example: being able to replace the battery -- iPhone
A better design of wrapper function --
	- modularising internals of a wrapper function
	- here's all the stuff that goes to geoms, themes etc.
	- same for model
	- passed to the right place
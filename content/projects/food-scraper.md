+++
title = "New project: Food price scraper"
date = 2022-11-12T17:51:38Z
description = "A Git scraper that tracks Ocado product prices."
tags = ["Git"]
+++

I've created a deeply middle-class [Git scraper][git_scraper_definition] project
which tracks the prices of a basket of goods sold by the British online
supermarket, [Ocado][ocado].

For example, Lurpak butter:

![image](/images/product-price-graph.png)

[git_scraper_definition]: https://simonwillison.net/2020/Oct/9/git-scraping/
[ocado]: https://www.ocado.com/

I've been looked for an excuse to use Git scraping for ages, and this idea came
up as my wife and I were commiserating over how much food prices are increasing
at the moment.

The project is the [`codeinthehole/food-scraper` repo][repo_food_scraper] — see,
in particular, the [product overview file][overview_file].

It uses Github actions to call a Python CLI application once a day that:

1. Fetches prices for a list of products.
2. Updates a price archive file if any prices have changed.
3. Builds a price chart image file for each product (using `matplotlib`).
4. Updates an `overview.md` file that collates all the chart images.

Any changes are committed back to the repo.

Ultimately, it's an act of contortion, but it's neat to be able to build a
simple scheduler project that doesn't require a database and runs for free on
Github.

[repo_food_scraper]: https://github.com/codeinthehole/food-scraper
[overview_file]: https://github.com/codeinthehole/food-scraper/tree/master/overview.md

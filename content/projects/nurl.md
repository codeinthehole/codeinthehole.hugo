---
{
    "aliases": [
        "/writing/nurl-an-immutable-url-object-for-nodejs"
    ],
    "description": "A URL value object for node.js",
    "title": "nurl - an immutable URL object for node.js",
    "slug": "nurl-an-immutable-url-object-for-nodejs",
    "date": "2010-11-10",
    "tags": [
        "node",
        "javascript"
    ]
}
---


I'm a big fan of [Value Objects](http://c2.com/cgi/wiki?ValueObject) -
some of the most useful classes I've ever written have been lightweight
wrappers around strings.

For my first contribution to the [node.js](http://nodejs.org/)
ecosystem, I've published a simple, immutable URL object to the Node
package manager (npm) directory. It provides a light-weight, immutable
URL object that encapsulates the functionality of the existing 'url' and
'querystring' modules in a single object as well as offering various
extension methods that make working with URLs easy.

Source and detailed docs available at
<http://github.com/codeinthehole/nurl> -but here's some sample usage for
dynamically building a URL:

``` javascript
var nurl = require('nurl');
var baseUrl = (new nurl.Url()).setProtocol('http')
                              .setHostname('api.example.com')
                              .setPathname('search');
var searchUrl = baseUrl.setPathSegment(1, 'my search term');
searchUrl.toString() // => 'http://api.example.com/search/my%20search%20term
```

All components of a URL are exposed as read-only properties as well as
through getter functions.

``` javascript
var u = nurl.parse('http://www.example.com/path/to/somewhere?q=node.js');
u.getSubdomains() // ['www', 'example', 'com']
u.getPathSegment(0) // 'path'
u.getQueryParam('q') // 'node.js'
u.getQueryParam('p', 'a default value') // 'a default value'
```

All very simple but potentially quite useful thanks to the ubiquity of
the humble URL.

Writing this module introduced me to some of the excellent software
already available for node.js. Firstly, the package management system
[npm](http://github.com/isaacs/npm) is brilliantly simple to get started
with, and to publish modules for all to use. Secondly, I'm a huge fan of
the [Vows BDD package](http://vowsjs.org/). Writing tests in javascript
offers some cunning possibilities such as dynamically building
test-suites at run-time - this is great for this package as I can create
a fixture object of URL strings and their decomposition into components,
then build the context dynamically.

![Screenshot of vows in action](/images/screenshots/vows.png)

All feedback, forks and pull requests gratefully accepted.

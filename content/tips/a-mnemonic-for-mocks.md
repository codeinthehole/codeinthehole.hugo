+++
date = "2017-08-26"
title = "A mnemonic for mock decorators"
tags = ["python", "testing"]
description = "An easy way to remember the order arguments get injected."

+++

Using both `@mock.patch` decorators and
[py.test fixtures](https://docs.pytest.org/en/latest/fixture.html) can be
confusing as it's not always clear what order arguments are being injected.

For instance, which of these is right? This:

```python
@mock.patch.object(module, 'collaborator_1')
@mock.patch.object(module, 'collaborator_2')
def test_something_in_module(collaborator_1, collaborator_2, some_pytest_fixture):
    pass
```

Or this?

```python
@mock.patch.object(module, 'collaborator_2')
@mock.patch.object(module, 'collaborator_1')
def test_something_in_module(collaborator_1, collaborator_2, some_pytest_fixture):
    pass
```

Or this?

```python
@mock.patch.object(module, 'collaborator_2')
@mock.patch.object(module, 'collaborator_1')
def test_something_in_module(some_pytest_fixture, collaborator_1, collaborator_2):
    pass
```

I've wasted considerable time using PDB to work out what is being injected
where.

Not any more though. Here's how I remember:

- The py.test fixtures always go at the end of the argument list. Their order
  doesn't matter.

- The `@mock.patch` decorators inject arguments sequentially so the inner
  decorator injects the first argument, then the next outer decorator injects
  the second argument and so on. Like this:

```python
@mock.patch.object(module, 'collaborator_3')
@mock.patch.object(module, 'collaborator_2')
@mock.patch.object(module, 'collaborator_1')
def test_something_in_module(collaborator_1, collaborator_2, collaborator_3):
    pass
```

The things to remember is that it's a _symmetrical_ arrangement with the test
function or method in the centre.

So the correct arrangement above is:

```python
@mock.patch.object(module, 'collaborator_2')
@mock.patch.object(module, 'collaborator_1')
def test_something_in_module(collaborator_1, collaborator_2, some_pytest_fixture):
    pass
```

--

<div class="admonition warning">
    <strong>Postscript:</strong> The <a
    href="https://pypi.python.org/pypi/pytest-mock">pytest-mock</a> plugin can
    mitigate the confusion described above by providing the mock module as a
    pytest fixture - thanks to Floris Bruynooghe for <a href="https://twitter.com/flubdevork/status/901507766262648832">pointing this out</a>.
</div>

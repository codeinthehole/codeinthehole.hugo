---
{
  "aliases": ["/writing/continuously-re-build-your-project"],
  "slug": "continuously-re-build-your-project",
  "description": "Using CI to avoid pain for new team members",
  "tags": ["django"],
  "title": "Continuously rebuild your project",
  "date": "2014-06-18",
}
---

New developers joining a project will often find that the project won't build
cleanly on their machine, and hours of time will be sunk into setting up the
project so work can start. This is sad and expensive for all concerned.

This is a particular menace in agencies (or anywhere with lots of small
projects) where a large team of developers need to jump between projects. Tools
like [Vagrant](http://www.vagrantup.com) and [Docker](http://www.docker.com/)
can help but aren't the panacea they first seem to be[^1].

Counter this by using continuous integration to build your project from scratch.
Then any changes that break the build process (such as database schema changes
not applying correctly) will be spotted early. New team members will be dishing
out high-fives when their development environment is built and primed with
sample data sixty seconds after cloning the repo.

### Tips

It should be trivial to get a project working locally. At
[Tangent](http://www.tangentsnowball.com/), projects use a `makefile` for common
tasks. Setting up a working version of the project is as simple as:

```bash
make
```

It's helpful if you can template new projects to embed good practices like this.
We frequently use Django and maintain a
[boilerplate Django project](https://github.com/tangentlabs/tangent-django-boilerplate/)
for this purpose. It includes a
[makefile](https://github.com/tangentlabs/tangent-django-boilerplate/blob/master/makefile)
along these lines:

```make
# Build a working version of the project
build: clean virtualenv database

# Delete all temporary or untracked files
clean:
    -find . -type f -name "*.pyc" -delete
    -rm -rf www/public/media/*

# Update the virtualenv
virtualenv:
    pip install -r www/deploy/requirements.txt

# Create a database populated with data
database:
    python www/manage.py reset_db --router=default --noinput
    python www/manage.py syncdb --noinput
    python www/manage.py migrate
    # Load any project fixtures to pre-populate the initial database
    python www/manage.py loaddata fixtures/*.json

test:
    cd www && py.test

ci: test database
```

Witness the `ci` target which runs the test suite _and_ builds the database,
effectively smoke-testing that the migrations apply correctly and the fixtures
load (which is where we've historically had pain).

We use [Travis](https://travis-ci.com/) for CI and our template `.travis.yml`
looks a little like this:

```yaml
language: python

python:
  - "2.7"

install:
  - make virtualenv

# Use the same database as used in production
before_script:
  - psql -c 'CREATE ROLE test_role login createdb superuser;' -U postgres
  - psql -c 'CREATE DATABASE test_db OWNER test_role;' -U postgres

script:
  - make ci
```

which means that, _by default_, all new projects will be built from scratch as
part of continuous integration. You should do this.

### Django-specific issues

For the record, here's some of the build issues we've encountered in Django
projects (both internal and external) Most stem from South migrations, which
worked fine when applied piecemeal by the incumbent team but fail when run on a
blank database. For instance:

- Migrations fail to apply as there are dependencies between migrations which
  haven't been captured. This is easily solved by employing South's support for
  dependent migrations (eg adding `depends_on` to the relevant migration class).
- Migrations fail as they import models directly rather than using the
  reconstituted models that South provides. This is a beginner mistake really
  but still quite common. Fortunately, it's trivial to fix.
- Migrations import and call functions that are no longer defined (but did exist
  when the migration was originally written).
- Migrations create instances of models from _other_ apps where South's
  serialised version is out of sync with the database schema. This can be tricky
  to fix as you can get circular dependencies between migrations. Often you'll
  need to rewrite migrations to create models in the migrations of their own
  apps.

[^1]:
    For instance, it's not trivial to share folders with a Docker container on
    OSX. See <https://gist.github.com/codeinthehole/7ea69f8a21c67cc07293>

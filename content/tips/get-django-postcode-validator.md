---
{
  "aliases": ["/writing/validating-international-postcodes-in-django"],
  "slug": "validating-international-postcodes-in-django",
  "tags": ["django", "python"],
  "title": "Validating international postcodes in Django",
  "date": "2012-03-13",
  "description": "Using dynamic imports to leverage Django's localflavor",
}
---

### Problem

You want to validate a post/zip-code when you only know the country at runtime.

### Solution

Use this snippet to dynamically fetch a validation method from Django's suite of
"localflavor" form fields using the
[ISO 3166-1](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) two character
country code.

```python
def get_postcode_validator(country_code):
    # Django 1.3 uses 'UK' instead of GB - this changes in 1.4
    if country_code == 'GB':
        country_code = 'UK'
    module_path = 'django.contrib.localflavor.%s' % country_code.lower()
    try:
        module = __import__(module_path, fromlist=['forms'])
    except ImportError:
        # No forms module for this country
        return lambda x: x

    fieldname_variants = ['%sPostcodeField',
                          '%sPostCodeField',
                          '%sPostalCodeField',
                          '%sZipCodeField',]
    for variant in fieldname_variants:
        fieldname = variant % country_code.upper()
        if hasattr(module.forms, fieldname):
            return getattr(module.forms, fieldname)().clean
    return lambda x: x
```

As these validators are from forms, they will raise
`django.forms.ValidationError` if the passed postcode is invalid. Hence your
client code should look something like:

```python
from django.forms import ValidationError

def is_postcode_valid(postcode, country_code):
    try:
        get_postcode_validator(country_code)(postcode)
    except ValidationError:
        return False
    return True
```

### Discussion

As you can see, this is a touch messy as:

- Django 1.3 uses the incorrect code for the UK (it should be 'GB')
- There are a variety of different class names used for the appropriate field.
  We simply iterate over the possibilities and test to see if the class exists
  in the forms module.

This code is used within an internal Tangent geocoding webservice.

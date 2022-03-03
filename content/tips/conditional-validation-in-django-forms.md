---
{
  "aliases": ["/writing/conditional-logic-in-django-forms"],
  "tags": ["django", "python"],
  "title": "Conditional logic in Django forms",
  "slug": "conditional-logic-in-django-forms",
  "date": "2013-06-01",
  "description": "Radio buttons can be tamed",
}
---

### The problem

It's common for UX professionals to design forms like the following:

![image](/images/screenshots/radio-form-wire.png)

where radio buttons are employed to split the form into sections, each of which
can have its own fields which are only mandatory if the parent radio button is
checked. Thus the validation logic is conditional on the submitted form data.

Such requirements are slightly tricky to capture in Django as they tread
slightly outside the normal path of form validation. Specifically:

- It's not documented how to render radio buttons separately. The default
  behaviour is to render an unordered list. The
  [guidance on fine-grained template control](https://docs.djangoproject.com/en/dev/ref/forms/widgets/#radioselect)
  only covers looping over the choices.
- It's not obvious how to change the validation properties of a form field
  dynamically, depending on the submitted data.

### A solution

Start with this form class:

```python
from django import forms

class ScheduleForm(forms.Form):
    NOW, LATER = 'now', 'later'
    SCHEDULE_CHOICES = (
        (NOW, 'Send immediately'),
        (LATER, 'Send later'),
    )
    schedule = forms.ChoiceField(choices=SCHEDULE_CHOICES, widget=forms.RadioSelect)
    send_dt = forms.DateTimeField(label="", required=False)
```

Note the `send_dt` field has `required=False` as it is only mandatory if the
'Send later' radio button is selected. For simplicity, we are are only using a
single datetime field for the send date rather than the split-widget field of
the wireframe.

We can render this as follows:

```html
<form action="." method="post">
  {% csrf_token %} {{ form.non_field_errors }}

  <h3>Send schedule</h3>
  {{ form.schedule.errors }}

  <div class="span4">
    {{ form.schedule.0 }}<br />
    <span class="help-text">(Once you've checked out)</span>
  </div>

  <div class="span4">
    {{ form.schedule.1 }}<br />
    {{ form.send_dt }} {{ form.send_dt.errors }}
  </div>

  <button type="submit">Save</button>
</form>
```

Note:

- The radio buttons are rendered individually by referring to the index of each
  option (this works in Django 1.4+).

- We don't render the errors for the `schedule` next to one particular radio
  button, but above the container elements.

Next we add conditional validation to the form class:

```python
from django import forms

class ScheduleForm(forms.Form):
    NOW, LATER = 'now', 'later'
    SCHEDULE_CHOICES = (
        (NOW, 'Send immediately'),
        (LATER, 'Send later'),
    )
    schedule = forms.ChoiceField(choices=SCHEDULE_CHOICES, widget=forms.RadioSelect)
    send_dt = forms.DateTimeField(label="", required=False)

    def __init__(self, data=None, *args, **kwargs):
        super().__init__(data, *args, **kwargs)

        # If 'later' is chosen, mark send_dt as required.
        if data and data.get('schedule', None) == self.LATER:
            self.fields['send_dt'].required = True
```

Here, we override `__init__` and inspect the raw submitted data so that we can
set `required=True` on the `send_dt` field appropriately. This is the
conventional way of adding conditional logic to form validation, although it's
more common to use an additional argument to `__init__` to determine the field
adjustments.

### Discussion

This solution is not perfect. It's a little odd to use the raw form data to
change validation rules. However, I'm not aware of a cleaner alternative.

You also want to use Javascript to hide form widgets that aren't relevant until
their parent radio button has been checked.

Related links:

- [Advanced Django Form Usage](http://www.slideshare.net/pydanny/advanced-django-forms-usage) -
  A decent overview of various issues around forms from DjangoCon 2011.

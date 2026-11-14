# random_names

`random_names` turns an integer into a repeatable, word-based name and can recover
the integer from that name. This can make an identifier easier to read or type
while keeping the numeric value available to your application.

```python
from random_names.make_name import number_from_name, number_to_name

name = number_to_name(48342342, "id", "q")
assert name == "id_q_cut_jami"
assert number_from_name(name) == 48342342
```

Install with `pip install random_names`. Python 3.11 or newer is required.

Read the [user guide](guide.md) for the functions' arguments and constraints.
The [source repository](https://github.com/matthewdeanmartin/random_names)
contains tests and the word-list preparation notes.

# User guide

## Convert an integer to a name

```python
from random_names.make_name import number_to_name

name = number_to_name(100, "prefix", "q")
assert name == "prefix_q_activated"
```

`number_to_name(value, prefix, post_type)` uses a bundled 10,000-word list.
The output starts with the supplied prefix and post type, followed by one or
more words. Given the same integer and arguments, it returns the same name.

## Recover the integer

```python
from random_names.make_name import number_from_name

assert number_from_name("prefix_q_activated") == 100
```

The parser recognizes `_q_` and `_a_` between the prefix and generated words.
Use one of those markers if you need the reverse conversion. Names generated
with different word lists may not decode to the same value, so keep the
package's word list consistent wherever you exchange names.

The name is an identifier aid, not a secret or a cryptographic token. The
mapping is reversible by design.

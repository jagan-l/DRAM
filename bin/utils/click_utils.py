#!/usr/bin/env python
def validate_comma_separated(ctx, param, value, split=(",", " "), converter=None):
    if not value or value == "[]":
        return []
    if isinstance(value, (list, tuple)):
        s = split if isinstance(split, str) else split[0]
        value = s.join(value)
    if isinstance(split, str):
        split = [split]
        return value.split(split)
    if isinstance(split, (list, tuple)):
        sentinel = "|SENTINEL|"
        for s in split:
            value = value.replace(s, sentinel)
        ls = []
        for val in value.split(sentinel):
            val = val.strip()
            if converter:
                val = converter(val)
            ls.append(val)
        return ls

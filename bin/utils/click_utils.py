def validate_comma_separated(ctx, param, value, split=(",", " ")):
    if not value:
        return []
    if isinstance(value, (list, tuple)):
        s = split if isinstance(split, str) else split[0]
        value = s.join(value)
    if isinstance(split, str):
        return value.split(split)
    if isinstance(split, (list, tuple)):
        for s in split:
            value = value.replace(s, ",")
        return [val.strip() for val in value.split(",")]
    
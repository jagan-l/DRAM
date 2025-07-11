def validate_comma_separated(ctx, param, value):
    if not value:
        return []
    return value.split(',')
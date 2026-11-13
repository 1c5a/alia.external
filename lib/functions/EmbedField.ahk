EmbedField(name, value, inline) {
    return "{""name"":""" JsonEsc(name) """,""value"":""" JsonEsc(value) """,""inline"":" (inline ? "true" : "false") "}"
}


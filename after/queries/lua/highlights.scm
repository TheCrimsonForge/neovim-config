; extends

; Table KEYS, normalised onto one capture -- same problem and same fix as
; after/queries/typescript/highlights.scm, which carries the full reasoning.
;
; Lua's base query files a bare key as @property and a bracketed string key as
; @string, so `{ bare = 1, ["quoted"] = 2 }` showed its two keys in two colours.
;
; `dot_index_expression` is deliberately untouched: `t.bare` is member ACCESS and
; keeps @variable.member, so it stays on the member colour.
(field
  name: (identifier) @variable.member.key)

(field
  (string) @variable.member.key
  (#has-ancestor? @variable.member.key field))

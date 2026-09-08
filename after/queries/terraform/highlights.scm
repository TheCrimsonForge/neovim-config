; extends

; Object KEYS and block attribute names, normalised onto one capture -- same
; problem and same fix as after/queries/typescript/highlights.scm, which carries
; the full reasoning.
;
; Terraform's base query files a bare key as @variable.member and a quoted one as
; @string, so `{ Name = "x", "Quoted Key" = "y" }` showed its two keys in two
; colours. `object_elem` wraps both in an `expression`, so the key is captured
; through that field rather than by node type.
;
; `get_attr` / `variable_expr` are deliberately untouched: `var.environment` and
; `aws_s3_bucket.artifacts.id` are member ACCESS and keep @variable.member.
; The key must be captured at the LEAF, not at the wrapping `expression`: the
; base query captures `identifier` / `string_lit` inside it, and a capture on the
; wrapper does not override a deeper one.
(object_elem
  key: (expression
    (variable_expr
      (identifier) @variable.member.key)))

(object_elem
  key: (expression
    (literal_value
      (string_lit) @variable.member.key)))

(attribute
  (identifier) @variable.member.key)

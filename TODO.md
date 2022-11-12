
Documentation:
- all entries in docs/Configuration.md gets examples
Performance:
- precompile built in config
Features:
- transform gsub/sub
- proc transform
- some kind of scope awareness
- split rspec into component gems
- rename all matchers with has_


has_block
has_block_argument


---
```yml
dynamic:
  - name: store
    has_signature:
      0:
        required: true
        value:
          type: [String, Symbol]
      accessors:
        required: true
        value:
          type: Array
      [prefix, suffix]:
        required: false
        any:
          type: [String, Symbol]
      coder:
        required: false
    call:
      - itself:
        if:
      - arguments:
        at: '*':
        defines:
          - original
          - add_suffix: '='
          - add_suffix: _changed?
          - add_suffix: _was
          - add_suffix: _change
```

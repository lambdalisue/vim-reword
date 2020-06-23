# reword.vim

Keep case in substututions.

**In alpha stage**

## Usage (Command)

When `:Reword/HelloWorld/FooBarHoge` has executed, the following substitutions will be applied

| From          | To             | Disable flag |
| ------------- | -------------- | ------------ |
| `HelloWorld`  | `FooBarHoge`   | -            |
| `helloWorld`  | `fooBarHoge`   | `l`          |
| `hello_world` | `foo_bar_hoge` | `s`          |
| `hello-world` | `foo-bar-hoge` | `k`          |

## Usage (Preview)

Use `:RewordPreview` to start reword.

### Shortcut

Use `:R` or `:%R` and delimiter (e.g. `/`) to start preview automatically.


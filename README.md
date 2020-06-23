# 🧬 reword.vim

Keep case in substututions.

[![Reword preview](https://user-images.githubusercontent.com/546312/85360557-66839080-b554-11ea-9db8-4c2ebb021203.gif)](https://asciinema.org/a/OeVFw18uPAT8MAm9VaTEdLmd2)

**In alpha stage**

## Usage (Command)

When `:Reword/HelloWorld/FooBarHoge/g` has executed, the following substitutions will be applied

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

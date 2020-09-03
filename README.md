# 🧬 reword.vim

![vim](https://github.com/lambdalisue/reword.vim/workflows/vim/badge.svg)
![neovim](https://github.com/lambdalisue/reword.vim/workflows/neovim/badge.svg)
![reviewdog](https://github.com/lambdalisue/reword.vim/workflows/reviewdog/badge.svg)

![Support Vim 8.1 or above](https://img.shields.io/badge/support-Vim%208.1%20or%20above-yellowgreen.svg)
![Support Neovim 0.4 or above](https://img.shields.io/badge/support-Neovim%200.4%20or%20above-yellowgreen.svg)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Doc](https://img.shields.io/badge/doc-%3Ah%20reword-orange.svg)](doc/reword.txt)

Replace words in a buffer in case preserving manner, with live preview feature for Vim and Neovim.

![Reword preview](https://user-images.githubusercontent.com/546312/85490727-3fd56080-b60d-11ea-9a8b-4571c3279dcd.gif)

## Usage

Use `Reword` command to replace the first word in a current line like:

```
:Reword/HelloWorld/FooBarHoge
```

And use `/g` flags to replace all words in a current line like:

```
:Reword/HelloWorld/FooBarHoge/g
```

Prepend `%` to replace all words in a buffer like:

```
:%Reword/HelloWorld/FooBarHoge/g
```

Note that the following substitutions will be applied as well with `:Reword` command

| Name             | From          | To             | Disable flag |
| ---------------- | ------------- | -------------- | ------------ |
| `lowerCamelCase` | `helloWorld`  | `fooBarHoge`   | `l`          |
| `snake_case`     | `hello_world` | `foo_bar_hoge` | `s`          |
| `kebab-case`     | `hello-world` | `foo-bar-hoge` | `k`          |
| `lower`          | `helloworld`  | `foobarhoge`   | `i`          |
| `UPPER`          | `HELLOWORLD`  | `FOOBARHOGE`   | `i`          |

Use above disable flags to disable each cases.

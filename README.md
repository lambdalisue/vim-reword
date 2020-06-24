# 🧬 reword.vim

![Support Vim 8.1 or above](https://img.shields.io/badge/support-Vim%208.1%20or%20above-yellowgreen.svg)
![Support Neovim 0.4 or above](https://img.shields.io/badge/support-Neovim%200.4%20or%20above-yellowgreen.svg)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Doc](https://img.shields.io/badge/doc-%3Ah%20reword-orange.svg)](doc/reword.txt)

Keep case in substututions.

[![Reword preview](https://user-images.githubusercontent.com/546312/85360557-66839080-b554-11ea-9db8-4c2ebb021203.gif)](https://asciinema.org/a/OeVFw18uPAT8MAm9VaTEdLmd2)

**In alpha stage**

## Usage

When `:%Reword/HelloWorld/FooBarHoge/g` has executed, the following substitutions will be applied

| From          | To             | Disable flag |
| ------------- | -------------- | ------------ |
| `HelloWorld`  | `FooBarHoge`   | -            |
| `helloWorld`  | `fooBarHoge`   | `l`          |
| `hello_world` | `foo_bar_hoge` | `s`          |
| `hello-world` | `foo-bar-hoge` | `k`          |

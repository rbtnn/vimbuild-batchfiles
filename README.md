
# vim-vimbuild

This plugin is to build vim for me on Windows.

## Usage

```
" set vim/src directory
let g:vimbuild_cwd = '~/Desktop/vim/src'

" build vim for x64
VimBuild x64

" build vim for x86
VimBuild x86

" run vim.exe in vim's terminal
VimBuildVimInTerminal

" run Vim script on current buffer in terminal and call term_dumpwrite()/term_dumpload()
VimBuildTermDump
```


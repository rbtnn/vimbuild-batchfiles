
let g:loaded_vimbuild = 1

if !has('win32') || !has('terminal')
    finish
endif

let s:batfile = resolve(expand('<sfile>:h:h') .. '\vimbuild.bat')

function! s:configuration() abort
    let g:vimbuild_cwd = get(g:, 'vimbuild_cwd', '')
    let g:vimbuild_buildargs = get(g:, 'vimbuild_buildargs', '')
    let g:vimbuild_term_rows = get(g:, 'vimbuild_term_rows', 100)
    let g:vimbuild_term_cols = get(g:, 'vimbuild_term_cols', 100)
    let g:vimbuild_term_waittime = get(g:, 'vimbuild_term_waittime', 3000)
    let g:vimbuild_vimargs = get(g:, 'vimbuild_vimargs', ['-u', 'NONE', '-N', '--not-a-term', '--noplugin', '--cmd', 'set noswapfile'])
    if !isdirectory(expand(g:vimbuild_cwd))
        throw "please set vim repository's src directory to g:vimbuild_cwd"
    endif
endfunction

function! s:vimbuild_viminterminal() abort
    try
        call s:configuration()
        let vimexe = expand(g:vimbuild_cwd .. '/vim.exe', v:true)
        if !filereadable(vimexe)
            throw 'could not find vim.exe'
        endif
        let cmd = [vimexe] + g:vimbuild_vimargs
        call term_start(cmd)
    catch
        echohl Error
        echo v:exception
        echohl None
    endtry
endfunction

function! s:vimbuild_termdump() abort
    let dump = tempname()
    let script = tempname()
    try
        call s:configuration()
        let vimexe = expand(g:vimbuild_cwd .. '/vim.exe', v:true)
        if !filereadable(vimexe)
            throw 'could not find vim.exe'
        endif
        let cmd = [vimexe] + g:vimbuild_vimargs + ['--cmd', ('source ' .. script)]
        let opt = #{ term_finish : 'close', term_rows : g:vimbuild_term_rows, term_cols : g:vimbuild_term_cols, }
        call writefile(getline(1, '$'), script)
        tabnew
        vsplit
        let bnr = term_start(cmd, opt)
        only
        call term_wait(bnr, g:vimbuild_term_waittime)
        call term_dumpwrite(bnr, dump)
        call job_stop(term_getjob(bnr), 'kill')
        call term_dumpload(dump)
    catch
        echohl Error
        echo v:exception
        echohl None
    finally
        for x in [dump, script]
            if filereadable(x)
                call delete(x)
            endif
        endfor
    endtry
endfunction

function! s:vimbuild(q_args) abort
    try
        call s:configuration()
        let opt = #{ cwd: expand(g:vimbuild_cwd), }
        let xs = split(a:q_args, '\s\+')
        if -1 == index(['x86', 'x64'], get(xs, 0, ''))
            let xs = ['x86'] + xs
        endif
        call term_start([(s:batfile)] + [xs[0]] + [(g:vimbuild_buildargs)] + [' ' .. join(xs[1:])], opt)
    catch
        echohl Error
        echo v:exception
        echohl None
    endtry
endfunction

command! -nargs=*   VimBuild               :call <SID>vimbuild(<q-args>)
command! -nargs=*   VimBuildVimInTerminal  :call <SID>vimbuild_viminterminal()
command! -nargs=*   VimBuildTermDump       :call <SID>vimbuild_termdump()


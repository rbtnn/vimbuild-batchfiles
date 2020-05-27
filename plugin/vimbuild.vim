
let g:loaded_vimbuild = 1

if !has('terminal')
    finish
endif

function! s:configuration() abort
    let g:vimbuild_cwd = get(g:, 'vimbuild_cwd', '')
    let g:vimbuild_buildargs = get(g:, 'vimbuild_buildargs', '')
    let g:vimbuild_testargs = get(g:, 'vimbuild_testargs', '')
    let g:vimbuild_vimargs = get(g:, 'vimbuild_vimargs', ['-u', 'NONE', '-N', '--not-a-term', '--noplugin', '--cmd', 'set noswapfile'])
    if !isdirectory(expand(g:vimbuild_cwd))
        throw "please set vim repository's src directory to g:vimbuild_cwd"
    endif
endfunction

if has('win32')
    let s:batfile_build = resolve(expand('<sfile>:h:h') .. '\vimbuild_build.bat')
    let s:batfile_test = resolve(expand('<sfile>:h:h') .. '\vimbuild_test.bat')

    function! s:vimbuild(batfile, q_args) abort
        try
            call s:configuration()
            let opt = #{ cwd: expand(g:vimbuild_cwd), curwin: v:true, }
            let xs = split(a:q_args, '\s\+')
            if -1 == index(['x86', 'x64'], get(xs, 0, ''))
                let xs = ['x86'] + xs
            endif
            if a:batfile == s:batfile_build
                tabnew
                call term_start([(a:batfile)] + [xs[0]] + [(g:vimbuild_buildargs)] + [' ' .. join(xs[1:])], opt)
            endif
            if a:batfile == s:batfile_test
                tabnew
                call term_start([(a:batfile)] + [xs[0]] + [(g:vimbuild_testargs)] + [' ' .. join(xs[1:])], opt)
            endif
        catch
            echohl Error
            echo v:exception
            echohl None
        endtry
    endfunction

    command! -nargs=*                                           VimBuild      :call <SID>vimbuild(s:batfile_build, <q-args>)
    command! -nargs=* -complete=customlist,VimBuildTestComplete VimBuildTest  :call <SID>vimbuild(s:batfile_test, <q-args>)
else
    function! s:vimbuild(q_args) abort
        try
            call s:configuration()
            let opt = #{ cwd: expand(g:vimbuild_cwd .. '/testdir'), close_cb: function('s:vimbuild_test_close_cb') }
            let cmd = filter(['make', 'VIMPROG=../vim'] + [(g:vimbuild_testargs)] + [(a:q_args)], { i,x -> !empty(x) })
            call term_start(cmd, opt)
        catch
            echohl Error
            echo v:exception
            echohl None
        endtry
    endfunction

    function! s:vimbuild_test_close_cb(a) abort
        let path = expand(g:vimbuild_cwd .. '/testdir/test.log')
        if filereadable(path)
            let lines = readfile(path)
            new
            setlocal buftype=nofile
            call setline(1, lines)
            call delete(path)
        endif
    endfunction

    command! -nargs=* -complete=customlist,VimBuildTestComplete VimBuildTest  :call <SID>vimbuild(<q-args>)
endif

function! VimBuildTestComplete(A, L, P) abort
    try
        call s:configuration()
        let xs = split(globpath(g:vimbuild_cwd, 'testdir/test_*.vim'), "\n")
        call filter(xs, { i,x -> x =~# a:A })
        call map(xs, { i,x -> fnamemodify(x, ':t:gs!\.vim$!.res!') })
        return xs
    catch
        echohl Error
        echo v:exception
        echohl None
    endtry
endfunction


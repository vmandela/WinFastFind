let g:sedscriptname = ""
let g:pathlistbuilt = 0
let g:sedscriptname = expand("<sfile>:p:h")."\\".v:servername.".sed"
let g:perlfilepath = expand("<sfile>:p:h")."\\handlesubsts.pl"
let g:winfastfind#ignorecase = 1
let g:winfastfind#matchpath = 1
let g:winfastfind#ignorefiles = "swp,o,obj,a,pp,orig"
let g:winfastfind#matchwholeword= 0
let g:winfastfind#sortbypath = 1
let g:winfastfind#escmdline = ""

" Build the command line for search
function s:BuildEsCommandLine()

	let g:winfastfind#escmdline ="es.exe" 

	if(!g:winfastfind#ignorecase)
		let g:winfastfind#escmdline = join( [g:winfastfind#escmdline,"-i"]," ")
	endif

	if(g:winfastfind#matchpath)
		let g:winfastfind#escmdline = join( [g:winfastfind#escmdline,"-p"]," ")
	endif

	if(g:winfastfind#matchwholeword)
		let g:winfastfind#escmdline = join( [g:winfastfind#escmdline,"-w"]," ")
	endif

	if(g:winfastfind#sortbypath)
		let g:winfastfind#escmdline = join( [g:winfastfind#escmdline,"-s"]," ")
	endif
endfunction

call s:BuildEsCommandLine()

function s:BuildParamList()
	let localList = [ &path, g:winfastfind#ignorecase, g:winfastfind#matchpath, g:winfastfind#ignorefiles]
	return localList
endfunction

let g:winfastfind#prevparamlist = s:BuildParamList()
"Decho g:winfastfind#prevparamlist

"Decho g:winfastfind#prevparamlist
"Decho g:sedscriptname
"Decho g:perlfilepath

"TODO Add cleanup of the generated sed script on exit.
"TODO Write a real makefile

function! g:BuildPathList()
"	Decho strftime("%c")
	let tempfilename = &path
"	Decho g:sedscriptname
	let cmdline = join(["perl",shellescape(g:perlfilepath), shellescape(&path),shellescape(g:sedscriptname),shellescape(g:winfastfind#ignorefiles),shellescape(g:winfastfind#ignorecase)]," ")
	let perlout = system(cmdline)
"	"Decho split(perlout,',')
	"call system("perl",g:perlfilepath,&path,g:sedscriptname)
	call s:BuildEsCommandLine()
	let g:pathlistbuilt = 1
endfunction

function! FastFindFile(...)

	let s:currparamlist = s:BuildParamList()

	if(!g:pathlistbuilt) || (g:winfastfind#prevparamlist!= s:currparamlist)
"		Decho "Rebuilding path script"
		call g:BuildPathList()
		let g:winfastfind#prevparamlist = s:currparamlist
	endif
	let filename = join(a:000," ")
	let sedcmd = "| sed -n -f "
	let searchresults =[]
	:try
	let pathcmdline = join([g:winfastfind#escmdline,filename,sedcmd,shellescape(g:sedscriptname)]," ")
"	Decho pathcmdline
	let searchresultsjoined = system(pathcmdline)
	call extend(searchresults,split(searchresultsjoined,nr2char(10)))
	:finally
	:endtry
"	Decho searchresults

	if empty(searchresults)
		echo "No file found"
	elseif len(searchresults)==1
		exec "edit" searchresults[0]
	else
		let fileIndex = inputlist(searchresults)
		exec "edit" searchresults[fileIndex]
	endif
endfunction

" Function mapping

" Type ff on top any file name to open it when in
" normal mode. This is similar to the gf command
map ff :call FastFindFile(expand("<cfile>"))<CR>

" Define a command Ff to execute from command file
" :Ff main.c
command -nargs=+ Ff call FastFindFile(<f-args>)

" Map the command Ff to ff for ease of use
" :ff main.c
execute 'cabbr ' . 'ff' . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . 'Ff' . '" : "' . 'ff' . '"<CR>'

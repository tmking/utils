#!/bin/zsh

ls="command /bin/ls -aAFhs --color=yes"

setopt SH_WORD_SPLIT

case $1 in
    -l|l)   ls_args=-l; shift 1
esac

for arg in $*; do
	case $arg in
		lib*|lib*.so*|lib*.a|-l)
	    		libpath=( $(</etc/ld.so.conf) )
            		for d in $libpath ${(F)LD_LIBRARY_PATH:gs/:/\ /}; do
                		t=( $t $d/$arg*(N*) )
				l=( $l $d/$arg*(N@) )
            		done            
		;;
            
        	*)
	    		for d in $path:gs/:/\ /; do
	    			t=( $t $d/$arg(N*) )
				l=( $l $d/$arg*(N@) )
	    		done
	esac
done	

if [ -n "$t" ]; then
    	eval $ls $ls_args $t
	[ -n "$l" ] && eval $ls -l $l
else
    	print "$arg: not found"; rc=1
fi

return $rc

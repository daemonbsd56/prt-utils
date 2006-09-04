#
# 20_evil_cmds.awk
#
# Version 0.1.2 - 2006-07-14
# J�rgen Daubert <jue at jue dot li> 
#
# Two test to find malicious rm and cd commands like 'rm -rf /usr'.
#
# Because there are often cases where we need a rm inside the workdir, 
# it's not posssible to expect always a $PKG in front of the rm parameter. 
# Best would be to interpret the whole build function to see where we are 
# in the filesystem. For now it should be sufficent to have a look at the 
# cd command too, to find something like 'cd /usr && rm -rf .'
# 
# The test for rm is a bit complicated, because we often have multiline 
# commands with rm.


loglevel_ok(FATAL) && FILENAME ~ PKGFILE {

    if (match($0, /\<rm\>/)) {

        a = substr($0, RSTART)
        
        while ($0 ~ /\\$/) {
            getline 
            a = a $0
            gsub(/\\/, "", a)
        }

        split(a, ab)

        for (i in ab) {
            if (ab[i] ~ /^\//)
                perror(FATAL, "Use of rm outside the workdir, Pkgfile line " NR)
        }
    }


    if ($0 ~ /\<cd\>/) {
        for (c=1; c<=NF; c++) {
            if ($c == "cd" && $(c+1) ~ /^\//)
                perror(FATAL, "Use of cd to go outside the workdir, Pkgfile line " NR)
        }
    }
}


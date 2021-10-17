for var in `ls data` ; do
    network=${var%.txt*}
    for distribution in uniform powerlaw norm exp ; do
        julia -O3 main.jl $network $distribution
    done
done
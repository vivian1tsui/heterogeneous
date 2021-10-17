using Base: Float64
using XLSX
using Printf

function id(D, x)
    if !haskey(D, x); D[x] = length(D)+2; end
    return D[x]
end

function runMain()
    sc2(x) = @sprintf("%.2f", parse(Float64, x))
    sc4(x) = @sprintf("%.2E", parse(Float64, x))
    D_net_time = Dict()
    D_net_err = Dict()
    XLSX.openxlsx("Results.xlsx", mode="rw") do TABLES
        time_table = TABLES[1]
        error_table = TABLES[2]
        D_dis = Dict("Uniform"=>1, "Power-law"=>2, "Normal"=>3, "Exponential"=>4)
        D_err = Dict("C(G)"=>1, "D(G)"=>2, "P(G)"=>3, "I_pd(G)"=>4)
        D_time = Dict("Exact"=>1, "Approx"=>2)
        cnt_row_time, cnt_row_error, cnt_dis = 0, 0, 0
        open("log.txt", "r") do f1
            for line in eachline(f1)
                buf = split(line)
                #println(buf)
                if size(buf, 1)==0; continue; end
                if size(buf, 1)==1
                    cnt_row_time = id(D_net_time, buf[1])
                    time_table[cnt_row_time, 1] = String(buf[1])
                    continue
                end
                if size(buf, 1)==2 && isdigit(buf[1][1])
                    n, m = parse(Int, buf[1]), parse(Int, buf[2])
                    if n<60000
                        cnt_row_error = id(D_net_err, time_table[cnt_row_time, 1])
                        error_table[cnt_row_error, 1] = time_table[cnt_row_time, 1]
                        error_table[cnt_row_error, 18] = n
                    end
                    time_table[cnt_row_time, 2] = n
                    time_table[cnt_row_time, 3] = m
                    continue
                end
                if size(buf, 1)==2 && buf[2]=="Distribution"; cnt_dis = D_dis[buf[1]]; continue; end
                if buf[2]=="Time"
                    tc = 3 + (cnt_dis-1)*2 + D_time[buf[1]]
                    time_table[cnt_row_time, tc] = sc2(buf[4])
                    continue
                end
                if buf[1]=="ERROR"
                    tc = 1 + (cnt_dis-1)*4 + D_err[buf[3]]
                    error_table[cnt_row_error, tc] = sc4(buf[5])
                    continue
                end
            end
        end
    end
end

runMain()
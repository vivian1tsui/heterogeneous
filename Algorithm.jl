include("Graph.jl")
include("Tools.jl")

using SparseArrays
using Laplacians

function Exact(G, K, s) # Returns C(G), D(G), P(G), I_pd(G)
	T = time()
	L = getSparseL(G)
	inv_LK = inv(getL(G)+K)
	inv_K = K^(-1)
	ks = K * s
	inv_ks = inv_LK * ks
	inv_ksL = L * inv_ks

	# calculate C(G)
	c_g = inv_ksL' * inv_K * inv_ksL
	# calculate D(G)
	d_g = inv_ks' * L * inv_ks
	# calculate P(G)
	p_g = inv_ks' * K * inv_ks
	# calculate I_pd(G)
	ipd_g = ks' * inv_ks

	T = time() - T
	return T, c_g, d_g, p_g, ipd_g
end

function Approx(G, K, s; eps = 1e-6) # Returns approximate values of C(G), D(G), P(G), I_pd(G)
	T = time()
	L = getSparseL(G)
	f = approxchol_sddm(L+K, tol=0.1*eps)
	inv_K = K^(-1)
	ks = K * s
	inv_ks = f(ks)
	inv_ksL = L * inv_ks

	# calculate C(G)
	c_g = inv_ksL' * inv_K * inv_ksL
	# calculate D(G)
	d_g = inv_ks' * L * inv_ks
	# calculate P(G)
	p_g = inv_ks' * K * inv_ks
	# calculate I_pd(G)
	ipd_g = ks' * inv_ks

	T = time() - T
	return T, c_g, d_g, p_g, ipd_g
end

function doExp(G, s, K, lg)
	T, c_g, d_g, p_g, ipd_g = Exact(G, K, s)
	T2, ac_g, ad_g, ap_g, aipd_g = Approx(G, K, s)
	println(lg, "Exact  Time : ", T)
	println(lg, "Approx Time : ", T2)
	println(lg, "ERROR of C(G) : ", abs(ac_g-c_g)/c_g)
	println(lg, "ERROR of D(G) : ", abs(ad_g-d_g)/d_g)
	println(lg, "ERROR of P(G) : ", abs(ap_g-p_g)/p_g)
	println(lg, "ERROR of I_pd(G) : ", abs(aipd_g-ipd_g)/ipd_g)
	println(lg)
end

function doLarge(G, s, K, lg)
	T2, ac_g, ad_g, ap_g, aipd_g = Approx(G, K, s)
	println(lg, "Approx Time : ", T2)
	println(lg)
end
